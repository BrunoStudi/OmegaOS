from __future__ import annotations

import platform
import random
from collections import deque
from dataclasses import dataclass
from datetime import datetime
from time import time
from typing import Any

try:
    import can
except ImportError:
    can = None


@dataclass(frozen=True, slots=True)
class CanFrame:
    """
    Représente une trame CAN reçue ou générée par OmegaOS.
    """

    arbitration_id: int
    data: bytes
    timestamp: float
    is_extended: bool = False
    is_remote: bool = False
    is_error: bool = False

    @property
    def dlc(self) -> int:
        return len(self.data)

    @property
    def hex_id(self) -> str:
        width = 8 if self.is_extended else 3
        return f"0x{self.arbitration_id:0{width}X}"

    @property
    def data_hex(self) -> str:
        if not self.data:
            return "--"

        return " ".join(
            f"{value:02X}"
            for value in self.data
        )

    @property
    def formatted_time(self) -> str:
        return datetime.fromtimestamp(
            self.timestamp
        ).strftime("%H:%M:%S.%f")[:-3]

    @property
    def formatted(self) -> str:
        return (
            f"{self.hex_id} "
            f"[{self.dlc}] "
            f"{self.data_hex}"
        )


@dataclass(frozen=True, slots=True)
class CanBusState:
    """
    Instantané de l'état courant du service CAN.
    """

    connected: bool
    mode: str
    interface_name: str
    bitrate: int
    frames_received: int
    frames_per_second: int
    last_frame: CanFrame | None
    last_update: str
    status_message: str
    error_message: str


class CanBusService:
    """
    Gère la connexion CAN d'OmegaOS.

    Modes actuellement disponibles :

    - simulation :
      génère des trames fictives pour le développement ;

    - socketcan :
      utilise python-can et une interface Linux telle que can0.
    """

    MODE_SIMULATION = "simulation"
    MODE_SOCKETCAN = "socketcan"

    SUPPORTED_MODES = (
        MODE_SIMULATION,
        MODE_SOCKETCAN,
    )

    SUPPORTED_BITRATES = (
        125_000,
        250_000,
        500_000,
        1_000_000,
    )

    def __init__(
        self,
        mode: str = MODE_SIMULATION,
        interface_name: str = "can0",
        bitrate: int = 500_000,
        history_limit: int = 200,
    ) -> None:
        self._mode = self._validate_mode(mode)
        self._interface_name = interface_name
        self._bitrate = self._validate_bitrate(bitrate)

        self._connected = False
        self._bus: Any | None = None

        self._frames_received = 0
        self._frames_per_second = 0
        self._last_frame: CanFrame | None = None
        self._last_update = "--:--:--"

        self._status_message = "Bus CAN déconnecté"
        self._error_message = ""

        self._history: deque[CanFrame] = deque(
            maxlen=history_limit
        )

        self._simulation_frames = (
            (0x180, b"\x02\x10\x4A\x00\x00\x00\x00\x00"),
            (0x201, b"\x4F\x10\x00\x8A\x00\x00\x00\x00"),
            (0x280, b"\x00\x00\x35\x7C\x10\x00\x00\x00"),
            (0x301, b"\x01\x00\x00\x00\x40\x00\x00\x00"),
            (0x420, b"\x7A\x01\x00\x00\x00\x00\x00\x00"),
            (0x5E8, b"\x10\x14\x00\x00\x00\x00\x00\x00"),
        )

    @property
    def mode(self) -> str:
        return self._mode

    @property
    def interface_name(self) -> str:
        return self._interface_name

    @property
    def bitrate(self) -> int:
        return self._bitrate

    @property
    def connected(self) -> bool:
        return self._connected

    def set_mode(self, mode: str) -> None:
        """
        Change le mode CAN.

        Une connexion active est d'abord fermée afin d'éviter
        de conserver un bus correspondant à l'ancien mode.
        """

        validated_mode = self._validate_mode(mode)

        if validated_mode == self._mode:
            return

        if self._connected:
            self.disconnect()

        self._mode = validated_mode
        self._reset_runtime_information()
        self._status_message = (
            f"Mode CAN sélectionné : "
            f"{self.get_display_mode()}"
        )

    def set_interface_name(
        self,
        interface_name: str,
    ) -> None:
        cleaned_name = interface_name.strip()

        if not cleaned_name:
            raise ValueError(
                "Le nom de l'interface CAN ne peut pas être vide."
            )

        if cleaned_name == self._interface_name:
            return

        if self._connected:
            self.disconnect()

        self._interface_name = cleaned_name
        self._status_message = (
            f"Interface sélectionnée : {cleaned_name}"
        )

    def set_bitrate(self, bitrate: int) -> None:
        validated_bitrate = self._validate_bitrate(
            bitrate
        )

        if validated_bitrate == self._bitrate:
            return

        if self._connected:
            self.disconnect()

        self._bitrate = validated_bitrate
        self._status_message = (
            f"Débit sélectionné : "
            f"{self.get_formatted_bitrate()}"
        )

    def connect(self) -> bool:
        """
        Connecte le mode actuellement sélectionné.
        """

        if self._connected:
            return True

        self._error_message = ""

        if self._mode == self.MODE_SIMULATION:
            return self._connect_simulation()

        if self._mode == self.MODE_SOCKETCAN:
            return self._connect_socketcan()

        self._set_error(
            f"Mode CAN inconnu : {self._mode}"
        )
        return False

    def disconnect(self) -> None:
        """
        Ferme proprement la connexion CAN.
        """

        if self._bus is not None:
            try:
                self._bus.shutdown()
            except Exception:
                pass
            finally:
                self._bus = None

        self._connected = False
        self._frames_per_second = 0
        self._status_message = "Bus CAN déconnecté"

    def update(self) -> CanBusState:
        """
        Actualise le service puis retourne son état.
        """

        if not self._connected:
            return self.get_state()

        if self._mode == self.MODE_SIMULATION:
            self._update_simulation()

        elif self._mode == self.MODE_SOCKETCAN:
            self._update_socketcan()

        self._last_update = datetime.now().strftime(
            "%H:%M:%S"
        )

        return self.get_state()

    def get_state(self) -> CanBusState:
        return CanBusState(
            connected=self._connected,
            mode=self._mode,
            interface_name=self._interface_name,
            bitrate=self._bitrate,
            frames_received=self._frames_received,
            frames_per_second=self._frames_per_second,
            last_frame=self._last_frame,
            last_update=self._last_update,
            status_message=self._status_message,
            error_message=self._error_message,
        )

    def get_last_frame(self) -> CanFrame | None:
        return self._last_frame

    def get_history(self) -> list[CanFrame]:
        """
        Retourne une copie de l'historique.

        La trame la plus récente est placée en premier.
        """

        return list(reversed(self._history))

    def clear_history(self) -> None:
        self._history.clear()
        self._frames_received = 0
        self._frames_per_second = 0
        self._last_frame = None
        self._status_message = "Historique CAN effacé"

    def get_display_mode(self) -> str:
        if self._mode == self.MODE_SOCKETCAN:
            return "SocketCAN"

        return "Simulation"

    def get_formatted_bitrate(self) -> str:
        if self._bitrate >= 1_000_000:
            value = self._bitrate / 1_000_000
            return f"{value:g} Mbit/s"

        return f"{self._bitrate // 1000} kbit/s"

    def is_socketcan_available(self) -> bool:
        return (
            platform.system() == "Linux"
            and can is not None
        )

    def _connect_simulation(self) -> bool:
        self._connected = True
        self._frames_per_second = 0
        self._status_message = (
            "Simulation CAN connectée"
        )

        return True

    def _connect_socketcan(self) -> bool:
        if platform.system() != "Linux":
            self._set_error(
                "SocketCAN est uniquement disponible "
                "sous Linux et Raspberry Pi."
            )
            return False

        if can is None:
            self._set_error(
                "Le paquet python-can n'est pas installé."
            )
            return False

        try:
            self._bus = can.interface.Bus(
                interface="socketcan",
                channel=self._interface_name,
            )

        except Exception as error:
            self._bus = None
            self._set_error(
                "Impossible d'ouvrir l'interface "
                f"{self._interface_name} : {error}"
            )
            return False

        self._connected = True
        self._frames_per_second = 0
        self._status_message = (
            f"SocketCAN connecté sur "
            f"{self._interface_name}"
        )

        return True

    def _update_simulation(self) -> None:
        generated_count = random.randint(15, 80)

        for _ in range(generated_count):
            frame = self._generate_simulated_frame()
            self._register_frame(frame)

        self._frames_per_second = generated_count
        self._status_message = (
            "Réception CAN simulée active"
        )

    def _generate_simulated_frame(self) -> CanFrame:
        arbitration_id, base_data = random.choice(
            self._simulation_frames
        )

        mutable_data = bytearray(base_data)

        # Une petite variation permet de simuler un réseau vivant
        # tout en conservant des trames cohérentes.
        byte_index = random.randrange(
            len(mutable_data)
        )

        if random.random() < 0.35:
            mutable_data[byte_index] = random.randrange(
                0,
                256,
            )

        return CanFrame(
            arbitration_id=arbitration_id,
            data=bytes(mutable_data),
            timestamp=time(),
        )

    def _update_socketcan(self) -> None:
        if self._bus is None:
            self._set_error(
                "La connexion SocketCAN n'est plus disponible."
            )
            return

        received_count = 0

        try:
            # Lecture non bloquante. On limite le nombre traité
            # à chaque cycle afin de ne jamais bloquer l'interface.
            for _ in range(500):
                message = self._bus.recv(timeout=0.0)

                if message is None:
                    break

                frame = CanFrame(
                    arbitration_id=message.arbitration_id,
                    data=bytes(message.data),
                    timestamp=float(message.timestamp),
                    is_extended=bool(
                        message.is_extended_id
                    ),
                    is_remote=bool(
                        message.is_remote_frame
                    ),
                    is_error=bool(
                        message.is_error_frame
                    ),
                )

                self._register_frame(frame)
                received_count += 1

        except Exception as error:
            self._set_error(
                f"Erreur de réception SocketCAN : {error}"
            )
            return

        self._frames_per_second = received_count
        self._status_message = (
            f"Réception SocketCAN active sur "
            f"{self._interface_name}"
        )

    def _register_frame(
        self,
        frame: CanFrame,
    ) -> None:
        self._last_frame = frame
        self._history.append(frame)
        self._frames_received += 1

    def _reset_runtime_information(self) -> None:
        self._frames_per_second = 0
        self._last_update = "--:--:--"
        self._error_message = ""

    def _set_error(self, message: str) -> None:
        self._connected = False
        self._frames_per_second = 0
        self._error_message = message
        self._status_message = message

    @classmethod
    def _validate_mode(
        cls,
        mode: str,
    ) -> str:
        normalized_mode = mode.strip().lower()

        if normalized_mode not in cls.SUPPORTED_MODES:
            raise ValueError(
                f"Mode CAN non pris en charge : {mode}"
            )

        return normalized_mode

    @classmethod
    def _validate_bitrate(
        cls,
        bitrate: int,
    ) -> int:
        normalized_bitrate = int(bitrate)

        if normalized_bitrate not in cls.SUPPORTED_BITRATES:
            raise ValueError(
                f"Débit CAN non pris en charge : "
                f"{normalized_bitrate}"
            )

        return normalized_bitrate
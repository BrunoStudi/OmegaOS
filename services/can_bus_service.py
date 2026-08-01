from __future__ import annotations

import math
import platform
import random
from collections import deque
from dataclasses import dataclass
from datetime import datetime
from time import monotonic, time
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
class SimulatedVehicleState:
    """
    État cohérent du véhicule simulé.
    """

    engine_running: bool
    engine_rpm: int
    vehicle_speed: float
    coolant_temperature: float
    battery_voltage: float
    fuel_level: float


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

    engine_running: bool
    engine_rpm: int
    vehicle_speed: float
    coolant_temperature: float
    battery_voltage: float
    fuel_level: float


class CanBusService:
    """
    Gère le bus CAN simulé ou réel d'OmegaOS.
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

        self._simulation_started_at = monotonic()

        self._vehicle_state = SimulatedVehicleState(
            engine_running=False,
            engine_rpm=0,
            vehicle_speed=0.0,
            coolant_temperature=20.0,
            battery_voltage=12.4,
            fuel_level=72.0,
        )

    @property
    def connected(self) -> bool:
        return self._connected

    @property
    def mode(self) -> str:
        return self._mode

    @property
    def interface_name(self) -> str:
        return self._interface_name

    @property
    def bitrate(self) -> int:
        return self._bitrate

    def set_mode(self, mode: str) -> None:
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

        if self._mode == self.MODE_SIMULATION:
            self._vehicle_state = SimulatedVehicleState(
                engine_running=False,
                engine_rpm=0,
                vehicle_speed=0.0,
                coolant_temperature=(
                    self._vehicle_state.coolant_temperature
                ),
                battery_voltage=12.4,
                fuel_level=self._vehicle_state.fuel_level,
            )

    def update(self) -> CanBusState:
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
        vehicle = self._vehicle_state

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
            engine_running=vehicle.engine_running,
            engine_rpm=vehicle.engine_rpm,
            vehicle_speed=vehicle.vehicle_speed,
            coolant_temperature=(
                vehicle.coolant_temperature
            ),
            battery_voltage=vehicle.battery_voltage,
            fuel_level=vehicle.fuel_level,
        )

    def get_history(self) -> list[CanFrame]:
        """
        Retourne les trames les plus récentes en premier.
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
            return (
                f"{self._bitrate / 1_000_000:g} Mbit/s"
            )

        return f"{self._bitrate // 1000} kbit/s"

    def is_socketcan_available(self) -> bool:
        return (
            platform.system() == "Linux"
            and can is not None
        )

    def _connect_simulation(self) -> bool:
        self._connected = True
        self._simulation_started_at = monotonic()

        self._frames_per_second = 0

        self._vehicle_state = SimulatedVehicleState(
            engine_running=True,
            engine_rpm=850,
            vehicle_speed=0.0,
            coolant_temperature=max(
                20.0,
                self._vehicle_state.coolant_temperature,
            ),
            battery_voltage=14.2,
            fuel_level=self._vehicle_state.fuel_level,
        )

        self._status_message = (
            "Simulation du véhicule active"
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
        """
        Actualise le scénario du véhicule puis génère
        des trames CAN cohérentes.
        """

        self._update_simulated_vehicle_state()

        generated_count = random.randint(35, 70)

        frame_factories = (
            self._create_engine_frame,
            self._create_speed_frame,
            self._create_temperature_frame,
            self._create_battery_frame,
            self._create_fuel_frame,
        )

        for index in range(generated_count):
            factory = frame_factories[
                index % len(frame_factories)
            ]

            frame = factory()
            self._register_frame(frame)

        self._frames_per_second = generated_count

        self._status_message = (
            "Simulation du véhicule active"
        )

    def _update_simulated_vehicle_state(self) -> None:
        """
        Produit un trajet cyclique et cohérent.

        Le scénario alterne :
        ralenti, accélération, vitesse stabilisée,
        décélération et arrêt temporaire.
        """

        elapsed = (
            monotonic() - self._simulation_started_at
        )

        cycle_duration = 90.0
        cycle_position = elapsed % cycle_duration

        engine_running = True

        if cycle_position < 10.0:
            speed = 0.0
            rpm = 850 + int(
                25 * math.sin(elapsed * 2.0)
            )

        elif cycle_position < 30.0:
            progress = (
                cycle_position - 10.0
            ) / 20.0

            speed = progress * 90.0
            rpm = int(
                900
                + progress * 2600
                + 180 * math.sin(elapsed * 1.5)
            )

        elif cycle_position < 55.0:
            speed = (
                90.0
                + 8.0 * math.sin(elapsed / 3.0)
            )

            rpm = int(
                2350
                + 220 * math.sin(elapsed / 2.0)
            )

        elif cycle_position < 75.0:
            progress = (
                cycle_position - 55.0
            ) / 20.0

            speed = max(
                0.0,
                90.0 * (1.0 - progress),
            )

            rpm = int(
                900
                + 1900 * (1.0 - progress)
            )

        else:
            speed = 0.0
            rpm = 850

        current_temperature = (
            self._vehicle_state.coolant_temperature
        )

        if current_temperature < 89.0:
            coolant_temperature = min(
                89.0,
                current_temperature + 0.7,
            )
        else:
            coolant_temperature = (
                89.0
                + 2.0 * math.sin(elapsed / 8.0)
            )

        battery_voltage = (
            14.15
            + 0.08 * math.sin(elapsed / 4.0)
        )

        fuel_level = max(
            0.0,
            self._vehicle_state.fuel_level - 0.002,
        )

        self._vehicle_state = SimulatedVehicleState(
            engine_running=engine_running,
            engine_rpm=max(0, rpm),
            vehicle_speed=max(0.0, speed),
            coolant_temperature=(
                coolant_temperature
            ),
            battery_voltage=battery_voltage,
            fuel_level=fuel_level,
        )

    def _create_engine_frame(self) -> CanFrame:
        """
        Trame de simulation moteur.

        ID 0x1A0 :
        octets 0-1 = régime moteur, non signé,
        ordre big-endian.
        """

        rpm = self._vehicle_state.engine_rpm

        data = rpm.to_bytes(
            length=2,
            byteorder="big",
            signed=False,
        ) + bytes(6)

        return self._create_frame(
            arbitration_id=0x1A0,
            data=data,
        )

    def _create_speed_frame(self) -> CanFrame:
        """
        ID 0x300 :
        vitesse encodée en centièmes de km/h.
        """

        raw_speed = int(
            self._vehicle_state.vehicle_speed * 100
        )

        data = raw_speed.to_bytes(
            length=2,
            byteorder="big",
            signed=False,
        ) + bytes(6)

        return self._create_frame(
            arbitration_id=0x300,
            data=data,
        )

    def _create_temperature_frame(self) -> CanFrame:
        """
        ID 0x5C0 :
        température = valeur brute - 40.
        """

        raw_temperature = int(
            self._vehicle_state.coolant_temperature
            + 40
        )

        raw_temperature = max(
            0,
            min(255, raw_temperature),
        )

        data = bytes(
            [
                raw_temperature,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
            ]
        )

        return self._create_frame(
            arbitration_id=0x5C0,
            data=data,
        )

    def _create_battery_frame(self) -> CanFrame:
        """
        ID 0x510 :
        tension en centièmes de volt.
        """

        raw_voltage = int(
            self._vehicle_state.battery_voltage * 100
        )

        data = raw_voltage.to_bytes(
            length=2,
            byteorder="big",
            signed=False,
        ) + bytes(6)

        return self._create_frame(
            arbitration_id=0x510,
            data=data,
        )

    def _create_fuel_frame(self) -> CanFrame:
        """
        ID 0x520 :
        niveau de carburant sur un octet, de 0 à 100.
        """

        fuel = int(
            round(self._vehicle_state.fuel_level)
        )

        fuel = max(0, min(100, fuel))

        data = bytes(
            [
                fuel,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
            ]
        )

        return self._create_frame(
            arbitration_id=0x520,
            data=data,
        )

    @staticmethod
    def _create_frame(
        arbitration_id: int,
        data: bytes,
    ) -> CanFrame:
        return CanFrame(
            arbitration_id=arbitration_id,
            data=data,
            timestamp=time(),
        )

    def _update_socketcan(self) -> None:
        if self._bus is None:
            self._set_error(
                "La connexion SocketCAN "
                "n'est plus disponible."
            )
            return

        received_count = 0

        try:
            for _ in range(500):
                message = self._bus.recv(
                    timeout=0.0
                )

                if message is None:
                    break

                frame = CanFrame(
                    arbitration_id=(
                        message.arbitration_id
                    ),
                    data=bytes(message.data),
                    timestamp=float(
                        message.timestamp
                    ),
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
                f"Erreur de réception "
                f"SocketCAN : {error}"
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
                f"Mode CAN non pris en charge : "
                f"{mode}"
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
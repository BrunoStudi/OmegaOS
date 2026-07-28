from __future__ import annotations

import random
from dataclasses import dataclass
from datetime import datetime


@dataclass(frozen=True)
class CanBusState:
    """
    Représente un instantané de l'état du bus CAN.
    """

    connected: bool
    mode: str
    interface_name: str
    bitrate: int
    frames_received: int
    frames_per_second: int
    last_frame: str
    last_update: str


class CanBusService:
    """
    Service de gestion du bus CAN d'OmegaOS.

    Pour le moment, le service fonctionne en mode simulation.
    Plus tard, le mode réel utilisera SocketCAN sur le Raspberry Pi.
    """

    def __init__(self, simulation_enabled: bool = True) -> None:
        self._simulation_enabled = simulation_enabled

        self._connected = False
        self._interface_name = "simulated-can0"
        self._bitrate = 500_000

        self._frames_received = 0
        self._frames_per_second = 0
        self._last_frame = "Aucune trame"

        self._simulation_frames = [
            "0x180  8  02 10 4A 00 00 00 00 00",
            "0x201  8  4F 10 00 8A 00 00 00 00",
            "0x280  8  00 00 35 7C 10 00 00 00",
            "0x301  8  01 00 00 00 40 00 00 00",
            "0x420  8  7A 01 00 00 00 00 00 00",
            "0x5E8  8  10 14 00 00 00 00 00 00",
        ]

    def connect(self) -> bool:
        """
        Démarre la connexion CAN.

        En mode simulation, aucune interface matérielle n'est requise.
        """

        if self._connected:
            return True

        self._connected = True
        self._frames_per_second = 0
        self._last_frame = "En attente de trames"

        return True

    def disconnect(self) -> None:
        """
        Arrête proprement la connexion CAN.
        """

        self._connected = False
        self._frames_per_second = 0
        self._last_frame = "Bus CAN déconnecté"

    def update(self) -> CanBusState:
        """
        Actualise et retourne l'état courant du bus CAN.
        """

        if self._connected and self._simulation_enabled:
            self._generate_simulated_activity()

        return self.get_state()

    def get_state(self) -> CanBusState:
        """
        Retourne un instantané de l'état courant.
        """

        return CanBusState(
            connected=self._connected,
            mode="Simulation" if self._simulation_enabled else "Réel",
            interface_name=self._interface_name,
            bitrate=self._bitrate,
            frames_received=self._frames_received,
            frames_per_second=self._frames_per_second,
            last_frame=self._last_frame,
            last_update=datetime.now().strftime("%H:%M:%S"),
        )

    def _generate_simulated_activity(self) -> None:
        """
        Génère une activité CAN fictive pour le développement.
        """

        generated_frames = random.randint(15, 80)

        self._frames_per_second = generated_frames
        self._frames_received += generated_frames
        self._last_frame = random.choice(self._simulation_frames)
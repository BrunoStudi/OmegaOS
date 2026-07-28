from __future__ import annotations

from PySide6.QtCore import (
    QObject,
    Property,
    QTimer,
    Signal,
    Slot,
)

from services.can_bus_service import CanBusService


class CanBusViewModel(QObject):
    """
    Expose l'état du bus CAN à l'interface QML.
    """

    dataChanged = Signal()

    def __init__(self) -> None:
        super().__init__()

        self._service = CanBusService(
            simulation_enabled=True
        )

        initial_state = self._service.get_state()

        self._connected = initial_state.connected
        self._mode = initial_state.mode
        self._interface_name = initial_state.interface_name
        self._bitrate = initial_state.bitrate
        self._frames_received = initial_state.frames_received
        self._frames_per_second = initial_state.frames_per_second
        self._last_frame = initial_state.last_frame
        self._last_update = initial_state.last_update

        self._timer = QTimer(self)
        self._timer.setInterval(1000)
        self._timer.timeout.connect(
            self.update_can_information
        )
        self._timer.start()

    @Slot()
    def connect_bus(self) -> None:
        """
        Connecte le bus CAN.
        """

        self._service.connect()
        self.update_can_information()

    @Slot()
    def disconnect_bus(self) -> None:
        """
        Déconnecte le bus CAN.
        """

        self._service.disconnect()
        self.update_can_information()

    @Slot()
    def toggle_connection(self) -> None:
        """
        Inverse l'état actuel de la connexion.
        """

        if self._connected:
            self.disconnect_bus()
        else:
            self.connect_bus()

    @Slot()
    def update_can_information(self) -> None:
        """
        Actualise les informations exposées à QML.
        """

        state = self._service.update()

        self._connected = state.connected
        self._mode = state.mode
        self._interface_name = state.interface_name
        self._bitrate = state.bitrate
        self._frames_received = state.frames_received
        self._frames_per_second = state.frames_per_second
        self._last_frame = state.last_frame
        self._last_update = state.last_update

        self.dataChanged.emit()

    @Property(bool, notify=dataChanged)
    def connected(self) -> bool:
        return self._connected

    @Property(str, notify=dataChanged)
    def connection_status(self) -> str:
        return "Connecté" if self._connected else "Déconnecté"

    @Property(str, notify=dataChanged)
    def mode(self) -> str:
        return self._mode

    @Property(str, notify=dataChanged)
    def interface_name(self) -> str:
        return self._interface_name

    @Property(int, notify=dataChanged)
    def bitrate(self) -> int:
        return self._bitrate

    @Property(str, notify=dataChanged)
    def formatted_bitrate(self) -> str:
        return f"{self._bitrate // 1000} kbit/s"

    @Property(int, notify=dataChanged)
    def frames_received(self) -> int:
        return self._frames_received

    @Property(int, notify=dataChanged)
    def frames_per_second(self) -> int:
        return self._frames_per_second

    @Property(str, notify=dataChanged)
    def last_frame(self) -> str:
        return self._last_frame

    @Property(str, notify=dataChanged)
    def last_update(self) -> str:
        return self._last_update
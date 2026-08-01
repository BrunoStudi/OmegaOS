from __future__ import annotations

from PySide6.QtCore import (
    QObject,
    Property,
    QTimer,
    Signal,
    Slot,
)

from services.can_bus_service import (
    CanBusService,
    CanBusState,
)


class CanBusViewModel(QObject):
    """
    Expose le service CAN à l'interface QML.
    """

    dataChanged = Signal()

    def __init__(self) -> None:
        super().__init__()

        self._service = CanBusService(
            mode=CanBusService.MODE_SIMULATION,
            interface_name="can0",
            bitrate=500_000,
        )

        self._auto_connect = False

        self._connected = False
        self._mode = CanBusService.MODE_SIMULATION
        self._interface_name = "can0"
        self._bitrate = 500_000

        self._frames_received = 0
        self._frames_per_second = 0

        self._last_frame = "Aucune trame"
        self._last_frame_id = "--"
        self._last_frame_data = "--"
        self._last_frame_dlc = 0
        self._last_frame_time = "--:--:--.---"

        self._history_text = (
            "HEURE         ID           DLC   DONNÉES\n"
            "--------------------------------------------------------------\n"
            "Aucune trame CAN enregistrée."
        )

        self._last_update = "--:--:--"
        self._status_message = "Bus CAN déconnecté"
        self._error_message = ""

        self._timer = QTimer(self)
        self._timer.setInterval(1000)
        self._timer.timeout.connect(
            self.update_can_information
        )
        self._timer.start()

        self._apply_state(
            self._service.get_state()
        )

    @Slot()
    def connect_bus(self) -> None:
        """
        Connecte le bus CAN avec la configuration sélectionnée.
        """

        self._service.connect()

        self._apply_state(
            self._service.get_state()
        )

    @Slot()
    def disconnect_bus(self) -> None:
        """
        Déconnecte proprement le bus CAN.
        """

        self._service.disconnect()

        self._apply_state(
            self._service.get_state()
        )

    @Slot()
    def toggle_connection(self) -> None:
        """
        Inverse l'état de connexion du bus.
        """

        if self._connected:
            self.disconnect_bus()
        else:
            self.connect_bus()

    @Slot(str)
    def set_mode(self, mode: str) -> None:
        """
        Sélectionne le mode Simulation ou SocketCAN.
        """

        try:
            self._service.set_mode(mode)

        except ValueError as error:
            self._error_message = str(error)
            self.dataChanged.emit()
            return

        self._apply_state(
            self._service.get_state()
        )

    @Slot(str)
    def set_interface_name(
        self,
        interface_name: str,
    ) -> None:
        """
        Sélectionne l'interface SocketCAN.
        """

        try:
            self._service.set_interface_name(
                interface_name
            )

        except ValueError as error:
            self._error_message = str(error)
            self.dataChanged.emit()
            return

        self._apply_state(
            self._service.get_state()
        )

    @Slot(int)
    def set_bitrate(self, bitrate: int) -> None:
        """
        Sélectionne le débit du bus CAN.
        """

        try:
            self._service.set_bitrate(bitrate)

        except ValueError as error:
            self._error_message = str(error)
            self.dataChanged.emit()
            return

        self._apply_state(
            self._service.get_state()
        )

    @Slot(bool)
    def set_auto_connect(
        self,
        enabled: bool,
    ) -> None:
        """
        Active ou désactive la future connexion automatique.
        """

        self._auto_connect = enabled
        self.dataChanged.emit()

    @Slot()
    def clear_history(self) -> None:
        """
        Efface toutes les trames enregistrées.
        """

        self._service.clear_history()

        self._apply_state(
            self._service.get_state()
        )

    @Slot()
    def update_can_information(self) -> None:
        """
        Actualise les informations CAN toutes les secondes.
        """

        state = self._service.update()
        self._apply_state(state)

    def _apply_state(
        self,
        state: CanBusState,
    ) -> None:
        """
        Copie l'état du service dans les propriétés exposées à QML.
        """

        self._connected = state.connected
        self._mode = state.mode
        self._interface_name = state.interface_name
        self._bitrate = state.bitrate

        self._frames_received = state.frames_received
        self._frames_per_second = (
            state.frames_per_second
        )

        self._last_update = state.last_update
        self._status_message = state.status_message
        self._error_message = state.error_message

        frame = state.last_frame

        if frame is None:
            self._last_frame = "Aucune trame"
            self._last_frame_id = "--"
            self._last_frame_data = "--"
            self._last_frame_dlc = 0
            self._last_frame_time = "--:--:--.---"

        else:
            self._last_frame = frame.formatted
            self._last_frame_id = frame.hex_id
            self._last_frame_data = frame.data_hex
            self._last_frame_dlc = frame.dlc
            self._last_frame_time = (
                frame.formatted_time
            )

        self._history_text = self._build_history_text()

        self.dataChanged.emit()

    def _build_history_text(self) -> str:
        """
        Construit une console CAN lisible depuis l'historique du service.

        Les trames les plus récentes apparaissent en premier.
        """

        frames = self._service.get_history()

        header = (
            "HEURE         ID           DLC   DONNÉES\n"
            "--------------------------------------------------------------"
        )

        if not frames:
            return (
                f"{header}\n"
                "Aucune trame CAN enregistrée."
            )

        lines = [header]

        for frame in frames:
            lines.append(
                f"{frame.formatted_time:<13} "
                f"{frame.hex_id:<12} "
                f"{frame.dlc:<5} "
                f"{frame.data_hex}"
            )

        return "\n".join(lines)

    @Property(bool, notify=dataChanged)
    def connected(self) -> bool:
        return self._connected

    @Property(str, notify=dataChanged)
    def connection_status(self) -> str:
        return (
            "Connecté"
            if self._connected
            else "Déconnecté"
        )

    @Property(str, notify=dataChanged)
    def mode(self) -> str:
        return self._mode

    @Property(str, notify=dataChanged)
    def display_mode(self) -> str:
        if self._mode == CanBusService.MODE_SOCKETCAN:
            return "SocketCAN"

        return "Simulation"

    @Property(bool, notify=dataChanged)
    def socketcan_available(self) -> bool:
        return self._service.is_socketcan_available()

    @Property(str, notify=dataChanged)
    def interface_name(self) -> str:
        return self._interface_name

    @Property(int, notify=dataChanged)
    def bitrate(self) -> int:
        return self._bitrate

    @Property(str, notify=dataChanged)
    def formatted_bitrate(self) -> str:
        return self._service.get_formatted_bitrate()

    @Property(bool, notify=dataChanged)
    def auto_connect(self) -> bool:
        return self._auto_connect

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
    def last_frame_id(self) -> str:
        return self._last_frame_id

    @Property(str, notify=dataChanged)
    def last_frame_data(self) -> str:
        return self._last_frame_data

    @Property(int, notify=dataChanged)
    def last_frame_dlc(self) -> int:
        return self._last_frame_dlc

    @Property(str, notify=dataChanged)
    def last_frame_time(self) -> str:
        return self._last_frame_time

    @Property(str, notify=dataChanged)
    def history_text(self) -> str:
        return self._history_text

    @Property(str, notify=dataChanged)
    def last_update(self) -> str:
        return self._last_update

    @Property(str, notify=dataChanged)
    def status_message(self) -> str:
        return self._status_message

    @Property(str, notify=dataChanged)
    def error_message(self) -> str:
        return self._error_message
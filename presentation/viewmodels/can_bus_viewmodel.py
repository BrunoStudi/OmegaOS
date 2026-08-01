from __future__ import annotations

from collections import deque
from datetime import datetime
from typing import Any

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
    Expose le service CAN et les alertes véhicule à l'interface QML.
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
        self._display_paused = False

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

        self._history_text = self._empty_history_text()
        self._paused_history_text = self._history_text

        self._last_update = "--:--:--"
        self._status_message = "Bus CAN déconnecté"
        self._error_message = ""

        self._engine_running = False
        self._engine_rpm = 0
        self._vehicle_speed = 0.0
        self._coolant_temperature = 20.0
        self._battery_voltage = 12.4
        self._fuel_level = 72.0

        # Gestion des alertes
        self._alert_history: deque[dict[str, Any]] = deque(
            maxlen=200
        )
        self._next_alert_id = 1

        self._alert_active = False
        self._alert_acknowledged = False
        self._active_alert_id: int | None = None

        self._alert_severity = "info"
        self._alert_title = "Système opérationnel"
        self._alert_message = (
            "Aucune alerte active. "
            "Tous les systèmes fonctionnent normalement."
        )
        self._alert_icon = "✓"

        self._demo_alert_index = 0
        self._current_real_alert_key: str | None = None

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

        self._display_paused = False
        self._demo_alert_index = 0
        self._current_real_alert_key = None

        self._set_no_active_alert()

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

    @Slot()
    def toggle_display_pause(self) -> None:
        """
        Fige ou reprend l'affichage de la console CAN.

        La réception des trames continue pendant la pause.
        """

        if not self._display_paused:
            self._paused_history_text = (
                self._build_history_text()
            )
            self._display_paused = True
        else:
            self._display_paused = False
            self._history_text = (
                self._build_history_text()
            )

        self.dataChanged.emit()

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

        self._display_paused = False
        self._demo_alert_index = 0
        self._current_real_alert_key = None

        self._set_no_active_alert()

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
        Efface toutes les trames CAN enregistrées.
        """

        self._service.clear_history()

        empty_history = self._empty_history_text()

        self._history_text = empty_history
        self._paused_history_text = empty_history

        self._apply_state(
            self._service.get_state()
        )

    @Slot()
    def next_demo_alert(self) -> None:
        """
        Fait défiler les alertes de démonstration.

        0 : aucune alerte
        1 : carburant faible
        2 : batterie critique
        3 : température critique
        """

        self._demo_alert_index = (
            self._demo_alert_index + 1
        ) % 4

        if self._demo_alert_index == 0:
            self._set_no_active_alert()
            self._update_real_alert()
            self.dataChanged.emit()
            return

        if self._demo_alert_index == 1:
            self._activate_alert(
                severity="warning",
                title="Niveau de carburant faible",
                message=(
                    "Le niveau de carburant est inférieur à 10 %. "
                    "Un ravitaillement est conseillé."
                ),
                icon="⛽",
                source="Simulation",
            )

        elif self._demo_alert_index == 2:
            self._activate_alert(
                severity="critical",
                title="Tension batterie critique",
                message=(
                    "La tension est inférieure à 11,8 V. "
                    "Vérifiez la batterie et le circuit de charge."
                ),
                icon="⚡",
                source="Simulation",
            )

        elif self._demo_alert_index == 3:
            self._activate_alert(
                severity="critical",
                title="Température moteur élevée",
                message=(
                    "La température moteur a dépassé 105 °C. "
                    "Arrêtez le véhicule dès que possible."
                ),
                icon="!",
                source="Simulation",
            )

        self.dataChanged.emit()

    @Slot()
    def acknowledge_current_alert(self) -> None:
        """
        Acquitte l'alerte actuellement affichée.
        """

        if not self._alert_active:
            return

        self._alert_acknowledged = True
        self._alert_active = False

        if self._active_alert_id is not None:
            for alert in self._alert_history:
                if alert["id"] == self._active_alert_id:
                    alert["acknowledged"] = True
                    break

        self.dataChanged.emit()

    @Slot()
    def clear_alert_history(self) -> None:
        """
        Efface le journal des alertes véhicule.
        """

        self._alert_history.clear()
        self.dataChanged.emit()

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

        self._engine_running = state.engine_running
        self._engine_rpm = state.engine_rpm
        self._vehicle_speed = state.vehicle_speed

        self._coolant_temperature = (
            state.coolant_temperature
        )

        self._battery_voltage = state.battery_voltage
        self._fuel_level = state.fuel_level

        if not self._display_paused:
            self._history_text = (
                self._build_history_text()
            )

        self._update_real_alert()

        self.dataChanged.emit()

    def _update_real_alert(self) -> None:
        """
        Détecte automatiquement les alertes provenant du véhicule.

        Une même anomalie n'est enregistrée qu'une seule fois.
        Elle doit disparaître avant de pouvoir être enregistrée à nouveau.
        """

        if not self._connected:
            self._current_real_alert_key = None

            if self._demo_alert_index == 0:
                self._set_no_active_alert()

            return

        real_alert = self._get_real_alert()

        if real_alert is None:
            self._current_real_alert_key = None

            if self._demo_alert_index == 0:
                self._set_no_active_alert()

            return

        alert_key = real_alert["key"]

        if alert_key == self._current_real_alert_key:
            return

        self._current_real_alert_key = alert_key

        if self._demo_alert_index == 0:
            self._activate_alert(
                severity=real_alert["severity"],
                title=real_alert["title"],
                message=real_alert["message"],
                icon=real_alert["icon"],
                source="Véhicule",
            )

    def _get_real_alert(
        self,
    ) -> dict[str, str] | None:
        """
        Retourne l'alerte réelle prioritaire.
        """

        if self._coolant_temperature >= 105:
            return {
                "key": "coolant_critical",
                "severity": "critical",
                "title": "Température moteur critique",
                "message": (
                    "Température mesurée : "
                    f"{self._coolant_temperature:.1f} °C. "
                    "Arrêtez le véhicule dès que possible."
                ),
                "icon": "!",
            }

        if self._battery_voltage < 11.8:
            return {
                "key": "battery_critical",
                "severity": "critical",
                "title": "Tension batterie critique",
                "message": (
                    "Tension mesurée : "
                    f"{self._battery_voltage:.2f} V. "
                    "Vérifiez le circuit électrique."
                ),
                "icon": "⚡",
            }

        if self._coolant_temperature >= 95:
            return {
                "key": "coolant_warning",
                "severity": "warning",
                "title": "Température moteur élevée",
                "message": (
                    "Température mesurée : "
                    f"{self._coolant_temperature:.1f} °C."
                ),
                "icon": "!",
            }

        if self._battery_voltage < 12.3:
            return {
                "key": "battery_warning",
                "severity": "warning",
                "title": "Tension batterie faible",
                "message": (
                    "Tension mesurée : "
                    f"{self._battery_voltage:.2f} V."
                ),
                "icon": "⚡",
            }

        if self._fuel_level <= 10:
            return {
                "key": "fuel_reserve",
                "severity": "warning",
                "title": "Réserve de carburant",
                "message": (
                    "Carburant restant : "
                    f"{self._fuel_level:.1f} %."
                ),
                "icon": "⛽",
            }

        if self._fuel_level <= 20:
            return {
                "key": "fuel_warning",
                "severity": "warning",
                "title": "Niveau de carburant faible",
                "message": (
                    "Carburant restant : "
                    f"{self._fuel_level:.1f} %."
                ),
                "icon": "⛽",
            }

        return None

    def _activate_alert(
        self,
        *,
        severity: str,
        title: str,
        message: str,
        icon: str,
        source: str,
    ) -> None:
        """
        Active et enregistre une nouvelle alerte.
        """

        self._alert_active = True
        self._alert_acknowledged = False

        self._alert_severity = severity
        self._alert_title = title
        self._alert_message = message
        self._alert_icon = icon

        alert_id = self._next_alert_id
        self._next_alert_id += 1

        self._active_alert_id = alert_id

        self._alert_history.appendleft(
            {
                "id": alert_id,
                "time": datetime.now().strftime(
                    "%d/%m/%Y %H:%M:%S"
                ),
                "severity": severity,
                "title": title,
                "message": message,
                "source": source,
                "acknowledged": False,
            }
        )

    def _set_no_active_alert(self) -> None:
        """
        Replace le bandeau dans son état normal.
        """

        self._alert_active = False
        self._alert_acknowledged = False
        self._active_alert_id = None

        self._alert_severity = "info"
        self._alert_title = "Système opérationnel"
        self._alert_message = (
            "Aucune alerte active. "
            "Tous les systèmes fonctionnent normalement."
        )
        self._alert_icon = "✓"

    def _build_history_text(self) -> str:
        """
        Construit la console depuis l'historique du service.

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

    def _build_alert_history_text(self) -> str:
        """
        Construit le journal textuel des alertes véhicule.
        """

        header = (
            "DATE ET HEURE        GRAVITÉ        SOURCE       "
            "STATUT       ALERTE\n"
            "------------------------------------------------"
            "-----------------------------------------------"
        )

        if not self._alert_history:
            return (
                f"{header}\n"
                "Aucune alerte véhicule enregistrée."
            )

        lines = [header]

        for alert in self._alert_history:
            severity = (
                "CRITIQUE"
                if alert["severity"] == "critical"
                else "AVERT."
            )

            status = (
                "ACQUITTÉE"
                if alert["acknowledged"]
                else "ACTIVE"
            )

            lines.append(
                f"{alert['time']:<20} "
                f"{severity:<14} "
                f"{alert['source']:<12} "
                f"{status:<12} "
                f"{alert['title']}"
            )

            lines.append(
                f"{'':<61}"
                f"{alert['message']}"
            )

            lines.append("")

        return "\n".join(lines)

    @staticmethod
    def _empty_history_text() -> str:
        return (
            "HEURE         ID           DLC   DONNÉES\n"
            "--------------------------------------------------------------\n"
            "Aucune trame CAN enregistrée."
        )

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

    @Property(bool, notify=dataChanged)
    def display_paused(self) -> bool:
        return self._display_paused

    @Property(str, notify=dataChanged)
    def display_pause_status(self) -> str:
        return (
            "Affichage en pause"
            if self._display_paused
            else "Affichage en direct"
        )

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
        if self._display_paused:
            return self._paused_history_text

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

    @Property(bool, notify=dataChanged)
    def engine_running(self) -> bool:
        return self._engine_running

    @Property(int, notify=dataChanged)
    def engine_rpm(self) -> int:
        return self._engine_rpm

    @Property(float, notify=dataChanged)
    def vehicle_speed(self) -> float:
        return self._vehicle_speed

    @Property(float, notify=dataChanged)
    def coolant_temperature(self) -> float:
        return self._coolant_temperature

    @Property(float, notify=dataChanged)
    def battery_voltage(self) -> float:
        return self._battery_voltage

    @Property(float, notify=dataChanged)
    def fuel_level(self) -> float:
        return self._fuel_level

    @Property(bool, notify=dataChanged)
    def alert_active(self) -> bool:
        return self._alert_active

    @Property(str, notify=dataChanged)
    def alert_severity(self) -> str:
        return self._alert_severity

    @Property(str, notify=dataChanged)
    def alert_title(self) -> str:
        return self._alert_title

    @Property(str, notify=dataChanged)
    def alert_message(self) -> str:
        return self._alert_message

    @Property(str, notify=dataChanged)
    def alert_icon(self) -> str:
        return self._alert_icon

    @Property(int, notify=dataChanged)
    def demo_alert_index(self) -> int:
        return self._demo_alert_index

    @Property(int, notify=dataChanged)
    def alert_count(self) -> int:
        return len(self._alert_history)

    @Property(int, notify=dataChanged)
    def unacknowledged_alert_count(self) -> int:
        return sum(
            1
            for alert in self._alert_history
            if not alert["acknowledged"]
        )

    @Property(str, notify=dataChanged)
    def alert_history_text(self) -> str:
        return self._build_alert_history_text()
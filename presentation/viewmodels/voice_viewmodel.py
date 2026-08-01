from __future__ import annotations

from PySide6.QtCore import (
    QObject,
    Property,
    Signal,
    Slot,
)

from core.settings import SettingsManager
from services.voice_service import VoiceService


class VoiceViewModel(QObject):
    """
    Expose les réglages et les annonces vocales à QML.
    """

    dataChanged = Signal()

    def __init__(
        self,
        settings: SettingsManager,
        parent: QObject | None = None,
    ) -> None:
        super().__init__(parent)

        self._settings = settings
        self._service = VoiceService(self)

        self._enabled = bool(
            self._settings.get(
                "voice",
                "enabled",
                False,
            )
        )

        self._announce_warnings = bool(
            self._settings.get(
                "voice",
                "announce_warnings",
                True,
            )
        )

        self._announce_critical = bool(
            self._settings.get(
                "voice",
                "announce_critical",
                True,
            )
        )

        self._volume = float(
            self._settings.get(
                "voice",
                "volume",
                0.85,
            )
        )

        self._rate = float(
            self._settings.get(
                "voice",
                "rate",
                -0.10,
            )
        )

        self._service.set_volume(self._volume)
        self._service.set_rate(self._rate)

        self._service.stateChanged.connect(
            self.dataChanged.emit
        )

        self._service.errorOccurred.connect(
            self._on_service_error
        )

    @Slot(str, str, str)
    def announce_alert(
        self,
        severity: str,
        title: str,
        message: str,
    ) -> None:
        """
        Annonce une nouvelle alerte selon sa gravité et les réglages.
        """

        if not self._enabled or not self._service.available:
            return

        if (
            severity == "critical"
            and not self._announce_critical
        ):
            return

        if (
            severity == "warning"
            and not self._announce_warnings
        ):
            return

        prefix = (
            "Attention."
            if severity == "critical"
            else "Information."
        )

        self._service.speak(
            f"{prefix} {title}. {message}"
        )

        self.dataChanged.emit()

    @Slot(bool)
    def set_enabled(self, enabled: bool) -> None:
        self._enabled = bool(enabled)

        self._settings.set(
            section="voice",
            key="enabled",
            value=self._enabled,
            save=True,
        )

        if not self._enabled:
            self._service.stop()

        self.dataChanged.emit()

    @Slot(bool)
    def set_announce_warnings(
        self,
        enabled: bool,
    ) -> None:
        self._announce_warnings = bool(enabled)

        self._settings.set(
            section="voice",
            key="announce_warnings",
            value=self._announce_warnings,
            save=True,
        )

        self.dataChanged.emit()

    @Slot(bool)
    def set_announce_critical(
        self,
        enabled: bool,
    ) -> None:
        self._announce_critical = bool(enabled)

        self._settings.set(
            section="voice",
            key="announce_critical",
            value=self._announce_critical,
            save=True,
        )

        self.dataChanged.emit()

    @Slot(float)
    def set_volume(self, volume: float) -> None:
        self._volume = max(
            0.0,
            min(1.0, float(volume)),
        )

        self._service.set_volume(self._volume)

        self._settings.set(
            section="voice",
            key="volume",
            value=self._volume,
            save=True,
        )

        self.dataChanged.emit()

    @Slot(float)
    def set_rate(self, rate: float) -> None:
        self._rate = max(
            -1.0,
            min(1.0, float(rate)),
        )

        self._service.set_rate(self._rate)

        self._settings.set(
            section="voice",
            key="rate",
            value=self._rate,
            save=True,
        )

        self.dataChanged.emit()

    @Slot()
    def test_voice(self) -> None:
        if not self._enabled:
            return

        self._service.speak(
            "Bienvenue à bord. "
            "Le système Omega O S est opérationnel."
        )

        self.dataChanged.emit()

    @Slot()
    def stop_voice(self) -> None:
        self._service.stop()
        self.dataChanged.emit()

    def _on_service_error(
        self,
        _message: str,
    ) -> None:
        self.dataChanged.emit()

    @Property(bool, notify=dataChanged)
    def enabled(self) -> bool:
        return self._enabled

    @Property(bool, notify=dataChanged)
    def available(self) -> bool:
        return self._service.available

    @Property(bool, notify=dataChanged)
    def announce_warnings(self) -> bool:
        return self._announce_warnings

    @Property(bool, notify=dataChanged)
    def announce_critical(self) -> bool:
        return self._announce_critical

    @Property(float, notify=dataChanged)
    def volume(self) -> float:
        return self._volume

    @Property(float, notify=dataChanged)
    def rate(self) -> float:
        return self._rate

    @Property(str, notify=dataChanged)
    def engine_name(self) -> str:
        return self._service.engine_name

    @Property(str, notify=dataChanged)
    def status_message(self) -> str:
        return self._service.status_message
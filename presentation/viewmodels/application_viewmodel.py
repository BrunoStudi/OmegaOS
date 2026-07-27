from __future__ import annotations

from PySide6.QtCore import Property, QObject, Signal

from core.settings import SettingsManager


class ApplicationViewModel(QObject):
    """
    Expose à QML les informations générales d'OmegaOS.

    Ce ViewModel sert de liaison entre le cœur Python
    et l'interface graphique QML.
    """

    applicationNameChanged = Signal()
    applicationVersionChanged = Signal()
    statusMessageChanged = Signal()

    def __init__(
        self,
        settings: SettingsManager,
        parent: QObject | None = None,
    ) -> None:
        super().__init__(parent)

        self._settings = settings

        self._application_name = self._settings.get(
            "application",
            "name",
            "OmegaOS",
        )

        self._application_version = self._settings.get(
            "application",
            "version",
            "0.1.0",
        )

        self._status_message = "Système initialisé"

    @Property(
        str,
        notify=applicationNameChanged,
    )
    def application_name(self) -> str:
        """
        Nom de l'application affiché dans QML.
        """

        return self._application_name

    @Property(
        str,
        notify=applicationVersionChanged,
    )
    def application_version(self) -> str:
        """
        Version actuelle d'OmegaOS.
        """

        return self._application_version

    @Property(
        str,
        notify=statusMessageChanged,
    )
    def status_message(self) -> str:
        """
        Message d'état affiché dans l'interface.
        """

        return self._status_message

    def set_status_message(self, message: str) -> None:
        """
        Met à jour le message d'état.

        Le signal associé prévient automatiquement QML.
        """

        if message == self._status_message:
            return

        self._status_message = message
        self.statusMessageChanged.emit()
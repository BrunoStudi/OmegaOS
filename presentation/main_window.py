from __future__ import annotations

import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QFont, QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from core.logger import setup_logger
from core.settings import SettingsManager
from presentation.viewmodels.application_viewmodel import (
    ApplicationViewModel,
)
from presentation.viewmodels.can_bus_viewmodel import (
    CanBusViewModel,
)
from presentation.viewmodels.system_viewmodel import (
    SystemViewModel,
)


class MainWindow:
    """
    Gère l'application Qt, les ViewModels et le chargement
    de l'interface QML.
    """

    def __init__(self, settings: SettingsManager) -> None:
        self._logger = setup_logger()
        self._settings = settings

        self._app = QGuiApplication(sys.argv)

        # Police disponible nativement sous Windows.
        # Sur Linux et Raspberry Pi, Qt choisira une police de remplacement
        # si Segoe UI n'est pas installée.
        self._app.setFont(
            QFont(
                "Segoe UI",
                10,
            )
        )

        self._engine = QQmlApplicationEngine()

        self._application_viewmodel = ApplicationViewModel(
            self._settings
        )

        self._system_viewmodel = SystemViewModel()
        self._can_bus_viewmodel = CanBusViewModel()

        context = self._engine.rootContext()

        context.setContextProperty(
            "applicationViewModel",
            self._application_viewmodel,
        )

        context.setContextProperty(
            "systemViewModel",
            self._system_viewmodel,
        )

        context.setContextProperty(
            "canBusViewModel",
            self._can_bus_viewmodel,
        )

    def run(self) -> int:
        """
        Charge Main.qml puis démarre la boucle événementielle Qt.
        """

        qml_file = (
            Path(__file__).resolve().parent
            / "qml"
            / "Main.qml"
        )

        self._logger.info(
            "Chargement de l'interface QML : %s",
            qml_file,
        )

        self._engine.load(
            QUrl.fromLocalFile(str(qml_file))
        )

        if not self._engine.rootObjects():
            self._logger.error(
                "Impossible de charger Main.qml"
            )
            return 1

        self._logger.info(
            "Interface graphique chargée"
        )

        return self._app.exec()
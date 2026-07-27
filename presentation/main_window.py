from __future__ import annotations

import sys
from pathlib import Path

from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from core.logger import setup_logger
from core.settings import SettingsManager
from presentation.viewmodels.application_viewmodel import (
    ApplicationViewModel,
)


class MainWindow:
    """
    Gère l'application Qt et le chargement de l'interface QML.
    """

    def __init__(self, settings: SettingsManager) -> None:
        self._logger = setup_logger()
        self._settings = settings

        self._app = QGuiApplication(sys.argv)
        self._engine = QQmlApplicationEngine()

        self._application_viewmodel = ApplicationViewModel(
            self._settings
        )

        self._engine.rootContext().setContextProperty(
            "applicationViewModel",
            self._application_viewmodel,
        )

    def run(self) -> int:
        """
        Charge Main.qml puis démarre Qt.
        """

        qml_file = (
            Path(__file__).parent
            / "qml"
            / "Main.qml"
        )

        self._logger.info("Chargement de %s", qml_file)

        self._engine.load(QUrl.fromLocalFile(str(qml_file.resolve())))

        if not self._engine.rootObjects():
            self._logger.error("Impossible de charger Main.qml")
            return 1

        self._logger.info("Interface chargée")

        return self._app.exec()
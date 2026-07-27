from __future__ import annotations

from core.logger import setup_logger
from core.settings import SettingsManager
from presentation.main_window import MainWindow


class OmegaApplication:
    """
    Point central de l'application OmegaOS.

    Cette classe initialise la configuration, les services
    et l'interface graphique.
    """

    def __init__(self) -> None:
        self._logger = setup_logger()
        self._settings = SettingsManager()

        self._main_window: MainWindow | None = None
        self._is_running = False

    @property
    def application_name(self) -> str:
        """
        Retourne le nom configuré de l'application.
        """

        return self._settings.get(
            "application",
            "name",
            "OmegaOS",
        )

    @property
    def application_version(self) -> str:
        """
        Retourne la version configurée de l'application.
        """

        return self._settings.get(
            "application",
            "version",
            "0.1.0",
        )

    @property
    def is_running(self) -> bool:
        """
        Indique si OmegaOS est actuellement démarré.
        """

        return self._is_running

    def start(self) -> int:
        """
        Démarre les services puis lance l'interface graphique.
        """

        if self._is_running:
            self._logger.warning(
                "%s est déjà démarré",
                self.application_name,
            )
            return 0

        exit_code = 1

        try:
            self._logger.info(
                "Démarrage de %s v%s",
                self.application_name,
                self.application_version,
            )

            self._is_running = True

            self._initialize_services()

            self._main_window = MainWindow(self._settings)

            self._logger.info(
                "%s est initialisé",
                self.application_name,
            )

            exit_code = self._main_window.run()

        except Exception:
            self._logger.exception(
                "Une erreur critique est survenue pendant le démarrage"
            )

        finally:
            self.stop()

        return exit_code

    def stop(self) -> None:
        """
        Arrête proprement OmegaOS et ses services.
        """

        if not self._is_running:
            return

        self._logger.info(
            "Arrêt de %s",
            self.application_name,
        )

        self._shutdown_services()

        self._main_window = None
        self._is_running = False

        self._logger.info(
            "%s est arrêté",
            self.application_name,
        )

    def _initialize_services(self) -> None:
        """
        Initialise les futurs services d'OmegaOS.
        """

        self._logger.info("Initialisation des services")

    def _shutdown_services(self) -> None:
        """
        Arrête les futurs services d'OmegaOS.
        """

        self._logger.info("Arrêt des services")
from __future__ import annotations

from core.logger import setup_logger
from core.settings import SettingsManager


class OmegaApplication:
    """
    Point central d'OmegaOS.

    Cette classe orchestre le démarrage et l'arrêt des différents modules,
    sans contenir directement leur logique métier.
    """

    def __init__(self) -> None:
        self.logger = setup_logger()
        self.settings = SettingsManager()

        self.application_name = self.settings.get(
            "application",
            "name",
            "OmegaOS",
        )
        self.application_version = self.settings.get(
            "application",
            "version",
            "0.1.0",
        )

        self._is_running = False

    @property
    def is_running(self) -> bool:
        """
        Indique si l'application est actuellement démarrée.
        """

        return self._is_running

    def start(self) -> int:
        """
        Démarre OmegaOS.

        Retourne un code de sortie :
        - 0 : arrêt normal
        - autre valeur : erreur
        """

        if self._is_running:
            self.logger.warning(
                "%s est déjà démarré",
                self.application_name,
            )
            return 0

        try:
            self.logger.info(
                "Démarrage de %s v%s",
                self.application_name,
                self.application_version,
            )

            self._is_running = True

            self._initialize_services()

            self.logger.info(
                "%s est initialisé",
                self.application_name,
            )

            return 0

        except Exception:
            self.logger.exception(
                "Une erreur critique est survenue pendant le démarrage"
            )
            return 1

        finally:
            self.stop()

    def stop(self) -> None:
        """
        Arrête proprement OmegaOS.
        """

        if not self._is_running:
            return

        self.logger.info(
            "Arrêt de %s",
            self.application_name,
        )

        self._shutdown_services()

        self._is_running = False

        self.logger.info(
            "%s est arrêté",
            self.application_name,
        )

    def _initialize_services(self) -> None:
        """
        Initialise les différents modules d'OmegaOS.

        Les futurs modules seront ajoutés ici :
        interface, CAN, API, audio, GPS, etc.
        """

        self.logger.info("Initialisation des services")

    def _shutdown_services(self) -> None:
        """
        Arrête les différents modules dans l'ordre inverse
        de leur démarrage.
        """

        self.logger.info("Arrêt des services")
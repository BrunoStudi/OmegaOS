from __future__ import annotations
import json

from copy import deepcopy
from pathlib import Path
from typing import Any
from core.logger import setup_logger


logger = setup_logger()


DEFAULT_SETTINGS: dict[str, Any] = {
    "application": {
        "name": "OmegaOS",
        "version": "0.1.0",
        "language": "fr",
    },
    "display": {
        "fullscreen": False,
        "theme": "dark",
    },
    "vehicle": {
        "name": "Opel Omega B",
        "model": "3.2 V6",
        "year": 2001,
    },
    "can": {
        "interface": "can0",
        "bitrate": 500000,
    },
        "voice": {
        "enabled": False,
        "volume": 0.85,
        "rate": -0.10,
    },
    "logging": {
        "level": "INFO",
    },
}


class SettingsManager:
    """
    Charge, lit, modifie et sauvegarde la configuration d'OmegaOS.
    """

    def __init__(self, settings_path: Path | None = None) -> None:
        project_root = Path(__file__).resolve().parent.parent

        self.settings_path = (
            settings_path
            if settings_path is not None
            else project_root / "config" / "settings.json"
        )

        self._settings: dict[str, Any] = {}
        self.load()

    def load(self) -> None:
        """
        Charge le fichier settings.json.

        Si le fichier n'existe pas ou contient un JSON invalide,
        une configuration par défaut est créée.
        """

        if not self.settings_path.exists():
            logger.warning(
                "Fichier de configuration introuvable : %s",
                self.settings_path,
            )
            self._settings = deepcopy(DEFAULT_SETTINGS)
            self.save()
            return

        try:
            with self.settings_path.open("r", encoding="utf-8") as file:
                loaded_settings = json.load(file)

            if not isinstance(loaded_settings, dict):
                raise ValueError(
                    "La racine du fichier settings.json doit être un objet JSON."
                )

            self._settings = self._merge_settings(
                defaults=DEFAULT_SETTINGS,
                custom=loaded_settings,
            )

            logger.info(
                "Configuration chargée depuis %s",
                self.settings_path,
            )

        except (json.JSONDecodeError, OSError, ValueError) as error:
            logger.error(
                "Impossible de charger la configuration : %s",
                error,
            )
            logger.warning("Chargement de la configuration par défaut")

            self._settings = deepcopy(DEFAULT_SETTINGS)

    def save(self) -> None:
        """
        Sauvegarde la configuration actuelle dans settings.json.
        """

        try:
            self.settings_path.parent.mkdir(
                parents=True,
                exist_ok=True,
            )

            with self.settings_path.open("w", encoding="utf-8") as file:
                json.dump(
                    self._settings,
                    file,
                    indent=4,
                    ensure_ascii=False,
                )

            logger.info(
                "Configuration sauvegardée dans %s",
                self.settings_path,
            )

        except OSError as error:
            logger.error(
                "Impossible de sauvegarder la configuration : %s",
                error,
            )
            raise

    def get(
        self,
        section: str,
        key: str | None = None,
        default: Any = None,
    ) -> Any:
        """
        Retourne une section complète ou une valeur précise.

        Exemples :
            settings.get("display")
            settings.get("display", "theme")
        """

        section_data = self._settings.get(section)

        if key is None:
            return section_data if section_data is not None else default

        if not isinstance(section_data, dict):
            return default

        return section_data.get(key, default)

    def set(
        self,
        section: str,
        key: str,
        value: Any,
        save: bool = False,
    ) -> None:
        """
        Modifie une valeur de configuration.

        Si save=True, le fichier JSON est immédiatement sauvegardé.
        """

        section_data = self._settings.setdefault(section, {})

        if not isinstance(section_data, dict):
            raise TypeError(
                f"La section '{section}' n'est pas un objet de configuration."
            )

        section_data[key] = value

        logger.info(
            "Paramètre modifié : %s.%s = %r",
            section,
            key,
            value,
        )

        if save:
            self.save()

    def reset(self, save: bool = True) -> None:
        """
        Restaure toute la configuration par défaut.
        """

        self._settings = deepcopy(DEFAULT_SETTINGS)

        logger.warning("Configuration réinitialisée")

        if save:
            self.save()

    def as_dict(self) -> dict[str, Any]:
        """
        Retourne une copie complète de la configuration.
        """

        return deepcopy(self._settings)

    @staticmethod
    def _merge_settings(
        defaults: dict[str, Any],
        custom: dict[str, Any],
    ) -> dict[str, Any]:
        """
        Fusionne la configuration utilisateur avec les valeurs par défaut.

        Cela permet d'ajouter plus tard de nouveaux paramètres sans casser
        les anciens fichiers settings.json.
        """

        result = deepcopy(defaults)

        for key, custom_value in custom.items():
            default_value = result.get(key)

            if isinstance(default_value, dict) and isinstance(custom_value, dict):
                result[key] = SettingsManager._merge_settings(
                    default_value,
                    custom_value,
                )
            else:
                result[key] = custom_value

        return result
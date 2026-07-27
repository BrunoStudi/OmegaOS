from core.logger import setup_logger
from core.settings import SettingsManager


def main() -> None:
    logger = setup_logger()
    settings = SettingsManager()

    logger.info("Démarrage d'OmegaOS")

    application_name = settings.get("application", "name")
    version = settings.get("application", "version")
    vehicle = settings.get("vehicle", "name")
    theme = settings.get("display", "theme")

    print(f"Application : {application_name}")
    print(f"Version     : {version}")
    print(f"Véhicule    : {vehicle}")
    print(f"Thème       : {theme}")

    settings.set(
        section="display",
        key="fullscreen",
        value=True,
        save=True,
    )


if __name__ == "__main__":
    main()
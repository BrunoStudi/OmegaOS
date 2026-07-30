from __future__ import annotations
import logging

from logging.handlers import RotatingFileHandler
from pathlib import Path


LOG_FORMAT = "%(asctime)s | %(levelname)-8s | %(name)s | %(message)s"
DATE_FORMAT = "%Y-%m-%d %H:%M:%S"


def setup_logger(
    name: str = "OmegaOS",
    log_level: int = logging.INFO,
) -> logging.Logger:
    """
    Configure et retourne le logger principal d'OmegaOS.

    Les logs sont affichés dans la console et enregistrés dans :
    data/logs/omegaos.log
    """

    logger = logging.getLogger(name)
    logger.setLevel(log_level)
    logger.propagate = False

    # Évite d'ajouter plusieurs fois les mêmes handlers
    if logger.handlers:
        return logger

    formatter = logging.Formatter(
        fmt=LOG_FORMAT,
        datefmt=DATE_FORMAT,
    )

    # Logs dans la console
    console_handler = logging.StreamHandler()
    console_handler.setLevel(log_level)
    console_handler.setFormatter(formatter)

    # Dossier de logs
    project_root = Path(__file__).resolve().parent.parent
    logs_directory = project_root / "data" / "logs"
    logs_directory.mkdir(parents=True, exist_ok=True)

    log_file = logs_directory / "omegaos.log"

    # Fichier limité à 2 Mo, avec 5 sauvegardes
    file_handler = RotatingFileHandler(
        filename=log_file,
        maxBytes=2 * 1024 * 1024,
        backupCount=5,
        encoding="utf-8",
    )
    file_handler.setLevel(log_level)
    file_handler.setFormatter(formatter)

    logger.addHandler(console_handler)
    logger.addHandler(file_handler)

    return logger
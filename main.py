from __future__ import annotations
from core.application import OmegaApplication

import os
import sys


# Le style Windows natif ne permet pas de personnaliser complètement
# certains contrôles QML comme Button.
#
# Basic est entièrement personnalisable et cohérent sur Windows,
# Linux et Raspberry Pi.

os.environ.setdefault(
    "QT_QUICK_CONTROLS_STYLE",
    "Basic",
)


def main() -> int:
    """
    Point d'entrée principal d'OmegaOS.
    """

    application = OmegaApplication()
    return application.start()


if __name__ == "__main__":
    sys.exit(main())
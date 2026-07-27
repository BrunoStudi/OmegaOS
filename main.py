from __future__ import annotations

import sys

from core.application import OmegaApplication


def main() -> int:
    """
    Point d'entrée principal d'OmegaOS.
    """

    application = OmegaApplication()
    return application.start()


if __name__ == "__main__":
    sys.exit(main())
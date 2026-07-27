from __future__ import annotations

import sys

from core.application import OmegaApplication


def main() -> int:
    application = OmegaApplication()
    return application.start()


if __name__ == "__main__":
    sys.exit(main())
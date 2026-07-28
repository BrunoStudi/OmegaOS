from __future__ import annotations

import os
import platform
from pathlib import Path

try:
    import psutil
except ImportError:
    psutil = None


class SystemMonitor:
    """
    Fournit les informations système nécessaires à OmegaOS.

    Cette classe ne dépend ni de Qt ni de l'interface QML.
    """

    def get_python_version(self) -> str:
        return platform.python_version()

    def get_platform(self) -> str:
        return platform.system()

    def get_platform_version(self) -> str:
        return platform.release()

    def get_hostname(self) -> str:
        return platform.node() or "OmegaOS"

    def get_cpu_usage(self) -> float:
        if psutil is None:
            return 0.0

        return float(
            psutil.cpu_percent(interval=None)
        )

    def get_memory_usage(self) -> float:
        if psutil is None:
            return 0.0

        return float(
            psutil.virtual_memory().percent
        )

    def get_cpu_count(self) -> int:
        return os.cpu_count() or 0

    def get_temperature(self) -> float:
        """
        Retourne la température CPU en degrés Celsius.

        Sur Raspberry Pi et certains systèmes Linux, la valeur
        est lue depuis thermal_zone0.

        Sur les systèmes incompatibles, retourne -1.0.
        """

        thermal_file = Path(
            "/sys/class/thermal/thermal_zone0/temp"
        )

        if not thermal_file.exists():
            return -1.0

        try:
            raw_value = thermal_file.read_text(
                encoding="utf-8"
            ).strip()

            return int(raw_value) / 1000.0

        except (
            OSError,
            ValueError,
        ):
            return -1.0
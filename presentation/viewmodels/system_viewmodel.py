from __future__ import annotations

from PySide6.QtCore import (
    QObject,
    Property,
    QTimer,
    Signal,
)

from services.system_monitor import SystemMonitor


class SystemViewModel(QObject):
    """
    Expose les informations système à l'interface QML.
    """

    dataChanged = Signal()

    def __init__(self) -> None:
        super().__init__()

        self._monitor = SystemMonitor()

        self._cpu_usage = 0.0
        self._memory_usage = 0.0
        self._temperature = -1.0

        self._python_version = (
            self._monitor.get_python_version()
        )

        self._operating_system = (
            f"{self._monitor.get_platform()} "
            f"{self._monitor.get_platform_version()}"
        )

        self._hostname = self._monitor.get_hostname()
        self._cpu_count = self._monitor.get_cpu_count()

        self._timer = QTimer(self)
        self._timer.timeout.connect(
            self.update_system_information
        )
        self._timer.start(1000)

        self.update_system_information()

    def update_system_information(self) -> None:
        """
        Actualise les informations système dynamiques.
        """

        cpu_usage = self._monitor.get_cpu_usage()
        memory_usage = self._monitor.get_memory_usage()
        temperature = self._monitor.get_temperature()

        data_has_changed = (
            cpu_usage != self._cpu_usage
            or memory_usage != self._memory_usage
            or temperature != self._temperature
        )

        self._cpu_usage = cpu_usage
        self._memory_usage = memory_usage
        self._temperature = temperature

        if data_has_changed:
            self.dataChanged.emit()

    @Property(str, constant=True)
    def python_version(self) -> str:
        return self._python_version

    @Property(str, constant=True)
    def operating_system(self) -> str:
        return self._operating_system

    @Property(str, constant=True)
    def hostname(self) -> str:
        return self._hostname

    @Property(int, constant=True)
    def cpu_count(self) -> int:
        return self._cpu_count

    @Property(float, notify=dataChanged)
    def cpu_usage(self) -> float:
        return self._cpu_usage

    @Property(float, notify=dataChanged)
    def memory_usage(self) -> float:
        return self._memory_usage

    @Property(float, notify=dataChanged)
    def temperature(self) -> float:
        return self._temperature
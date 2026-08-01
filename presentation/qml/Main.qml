import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../pages"
import "../theme"

ApplicationWindow {
    id: root

    width: 1280
    height: 800

    minimumWidth: 1024
    minimumHeight: 600

    visible: true

    title: applicationViewModel.application_name
    color: Theme.background

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TopBar {
            Layout.fillWidth: true

            Layout.preferredHeight:
                Theme.topBarHeight

            applicationName:
                applicationViewModel.application_name

            applicationVersion:
                applicationViewModel.application_version

            canConnected:
                canBusViewModel.connected

            canMode:
                canBusViewModel.display_mode

            cpuUsage:
                systemViewModel.cpu_usage

            memoryUsage:
                systemViewModel.memory_usage

            raspberryTemperature:
                systemViewModel.temperature
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 0

            NavigationMenu {
                id: navigationMenu

                Layout.fillHeight: true

                Layout.preferredWidth:
                    Theme.navigationWidth

                onPageSelected:
                    function(pageIndex, pageName) {
                        console.log(
                            "Navigation vers :",
                            pageName,
                            "(" + pageIndex + ")"
                        )
                    }
            }

            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true

                currentIndex:
                    navigationMenu.currentIndex

                DashboardPage {
                    statusMessage:
                        applicationViewModel.status_message

                    onPageRequested:
                        function(pageIndex) {
                            navigationMenu.currentIndex =
                                pageIndex
                        }
                }

                VehiclePage {
                }

                CanBusPage {
                }

                ModulePlaceholder {
                    title: "Diagnostics"

                    description:
                        "Lecture des défauts "
                        + "et analyse du véhicule"
                }

                HistoryPage {
                }

                SettingsPage {
                }
            }
        }

        StatusBar {
            Layout.fillWidth: true

            Layout.preferredHeight:
                Theme.statusBarHeight

            statusMessage:
                canBusViewModel.status_message

            hardwareName:
                systemViewModel.hostname

            operatingSystem:
                systemViewModel.operating_system

            pythonVersion:
                systemViewModel.python_version

            qtVersion:
                "Qt / PySide6"

            canConnected:
                canBusViewModel.connected
        }
    }
}
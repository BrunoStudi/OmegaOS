import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../pages"
import "../theme"

ApplicationWindow {
    id: root

    width: 1280
    height: 720

    minimumWidth: 1024
    minimumHeight: 600

    visible: true

    title: applicationViewModel.application_name

    color: Theme.background

    property bool canConnected: false

    ColumnLayout {
        anchors.fill: parent

        spacing: 0

        TopBar {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.topBarHeight

            applicationName: applicationViewModel.application_name
            applicationVersion: applicationViewModel.application_version

            canConnected: root.canConnected

            cpuUsage: "--"
            raspberryTemperature: "--"
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: 0

            NavigationMenu {
                id: navigationMenu

                Layout.fillHeight: true
                Layout.preferredWidth: Theme.navigationWidth

                onPageSelected: function(pageIndex, pageName) {
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

                currentIndex: navigationMenu.currentIndex

                DashboardPage {
                    statusMessage: applicationViewModel.status_message
                }

                ModulePlaceholder {
                    title: "Véhicule"
                    description: "Informations générales et état du véhicule"
                }

                ModulePlaceholder {
                    title: "CAN Bus"
                    description: "Connexion, trames et décodage CAN"
                }

                ModulePlaceholder {
                    title: "Diagnostics"
                    description: "Lecture des défauts et analyse du véhicule"
                }

                ModulePlaceholder {
                    title: "Historique"
                    description: "Trajets, événements et statistiques"
                }

                ModulePlaceholder {
                    title: "Paramètres"
                    description: "Configuration générale d’OmegaOS"
                }
            }
        }

        StatusBar {
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.statusBarHeight

            statusMessage: applicationViewModel.status_message
            hardwareName: "Raspberry Pi 3B+"
            pythonVersion: "Python"
            qtVersion: "Qt / PySide6"

            canConnected: root.canConnected
        }
    }
}
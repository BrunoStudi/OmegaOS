import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../pages"

ApplicationWindow {
    id: root

    width: 1280
    height: 720
    visible: true

    title: applicationViewModel.application_name
    color: "#05070b"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TopBar {
            Layout.fillWidth: true

            applicationName: applicationViewModel.application_name
            applicationVersion: applicationViewModel.application_version
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            NavigationMenu {
                id: navigationMenu

                Layout.fillHeight: true
                Layout.preferredWidth: 230
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
    }
}
import QtQuick
import QtQuick.Layouts

import "../components"
import "../theme"

Rectangle {
    id: root

    property string statusMessage: "Système initialisé"

    signal pageRequested(int pageIndex)

    color: Theme.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.pageMargin

        spacing: Theme.spacingLarge

        RowLayout {
            Layout.fillWidth: true

            spacing: Theme.spacingMedium

            ColumnLayout {
                spacing: Theme.spacingTiny

                Text {
                    text: "Tableau de bord"

                    color: Theme.textPrimary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontTitle
                    font.bold: true
                }

                Text {
                    text: "Vue générale du système"

                    color: Theme.textSecondary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontMedium
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                implicitWidth: statusContent.implicitWidth + 28
                implicitHeight: 38

                radius: 19

                color: Theme.successBackground

                border.width: Theme.borderWidth
                border.color: Theme.successBorder

                RowLayout {
                    id: statusContent

                    anchors.centerIn: parent
                    spacing: Theme.spacingSmall

                    Rectangle {
                        implicitWidth: 10
                        implicitHeight: 10

                        radius: 5
                        color: Theme.success
                    }

                    Text {
                        text: root.statusMessage

                        color: Theme.success

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontNormal
                        font.bold: true
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true

            columns: 3

            columnSpacing: Theme.spacingMedium
            rowSpacing: Theme.spacingMedium

            InfoCard {
                Layout.fillWidth: true

                title: "Connexion CAN"
                value: canBusViewModel.connection_status

                subtitle: canBusViewModel.connected
                          ? canBusViewModel.formatted_bitrate
                            + " — "
                            + canBusViewModel.frames_per_second
                            + " trames/s"
                          : "Interface non initialisée"

                accentColor: canBusViewModel.connected
                             ? Theme.success
                             : Theme.disconnected

                valueColor: canBusViewModel.connected
                            ? Theme.success
                            : Theme.textSecondary

                interactive: true

                onClicked: {
                    root.pageRequested(2)
                }
            }

            InfoCard {
                Layout.fillWidth: true

                title: "Véhicule"
                value: "Opel Omega B"
                subtitle: "3.2 V6 — Y32SE"

                accentColor: Theme.accent

                interactive: true

                onClicked: {
                    root.pageRequested(1)
                }
            }

            InfoCard {
                Layout.fillWidth: true

                title: "Diagnostics"
                value: "Aucun défaut"
                subtitle: "Analyse non démarrée"

                accentColor: Theme.success

                interactive: true

                onClicked: {
                    root.pageRequested(3)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: Theme.radiusMedium
            color: Theme.surface

            border.width: Theme.borderWidth
            border.color: Theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22

                spacing: Theme.spacingNormal

                Text {
                    text: "Activité récente"

                    color: Theme.textPrimary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontLarge
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1

                    color: Theme.border
                }

                Item {
                    Layout.fillHeight: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    text: canBusViewModel.connected
                          ? canBusViewModel.last_frame
                          : "Aucune donnée enregistrée"

                    color: canBusViewModel.connected
                           ? Theme.accent
                           : Theme.textSecondary

                    font.family: canBusViewModel.connected
                                 ? "Consolas"
                                 : "Segoe UI"

                    font.pixelSize: Theme.fontMedium
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    text: canBusViewModel.connected
                          ? canBusViewModel.frames_received
                            + " trames reçues depuis la connexion"
                          : "Les événements CAN et les diagnostics apparaîtront ici."

                    color: Theme.textMuted

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontNormal
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
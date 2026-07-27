import QtQuick
import QtQuick.Layouts

import "../components"
import "../theme"

Rectangle {
    id: root

    property string statusMessage: "Système initialisé"

    color: Theme.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.pageMargin

        spacing: Theme.spacingLarge

        RowLayout {
            Layout.fillWidth: true

            spacing: Theme.spacingMedium

            ColumnLayout {
                spacing: 4

                Text {
                    text: "Tableau de bord"

                    color: Theme.textPrimary

                    font.pixelSize: Theme.fontTitle
                    font.bold: true
                }

                Text {
                    text: "Vue générale du système"

                    color: Theme.textSecondary

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

                        font.pixelSize: Theme.fontNormal
                        font.bold: true
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true

            columns: 3

            columnSpacing: 18
            rowSpacing: 18

            InfoCard {
                Layout.fillWidth: true

                title: "Connexion CAN"
                value: "Déconnecté"
                subtitle: "Interface non initialisée"

                accentColor: Theme.disconnected
                valueColor: Theme.textSecondary

                interactive: true

                onClicked: {
                    console.log("Carte CAN sélectionnée")
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
                    console.log("Carte véhicule sélectionnée")
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
                    console.log("Carte diagnostics sélectionnée")
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

                    text: "Aucune donnée enregistrée"

                    color: Theme.textSecondary

                    font.pixelSize: Theme.fontMedium
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    text: "Les événements CAN et les diagnostics apparaîtront ici."

                    color: Theme.textMuted

                    font.pixelSize: Theme.fontNormal
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
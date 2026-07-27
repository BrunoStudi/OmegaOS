import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string statusMessage: "Système initialisé"

    color: "#05070b"

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 28
        spacing: 22

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ColumnLayout {
                spacing: 4

                Text {
                    text: "Tableau de bord"
                    color: "#f0f3f7"

                    font.pixelSize: 32
                    font.bold: true
                }

                Text {
                    text: "Vue générale du système"
                    color: "#7f8a99"

                    font.pixelSize: 15
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                implicitWidth: statusRow.implicitWidth + 28
                implicitHeight: 38

                radius: 19
                color: "#10271d"

                border.width: 1
                border.color: "#245e3d"

                RowLayout {
                    id: statusRow

                    anchors.centerIn: parent
                    spacing: 9

                    Rectangle {
                        implicitWidth: 10
                        implicitHeight: 10

                        radius: 5
                        color: "#49d17d"
                    }

                    Text {
                        text: root.statusMessage
                        color: "#7ce7a4"

                        font.pixelSize: 14
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

            Repeater {
                model: [
                    {
                        "title": "Connexion CAN",
                        "value": "Déconnecté",
                        "detail": "Interface non initialisée"
                    },
                    {
                        "title": "Véhicule",
                        "value": "Opel Omega B",
                        "detail": "3.2 V6 — Y32SE"
                    },
                    {
                        "title": "Diagnostics",
                        "value": "Aucun défaut",
                        "detail": "Analyse non démarrée"
                    }
                ]

                delegate: Rectangle {
                    required property var modelData

                    Layout.fillWidth: true
                    Layout.preferredHeight: 155

                    radius: 12
                    color: "#0b1018"

                    border.width: 1
                    border.color: "#182332"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 20
                        spacing: 8

                        Text {
                            text: modelData.title
                            color: "#7f8a99"

                            font.pixelSize: 13
                            font.bold: true
                        }

                        Text {
                            text: modelData.value
                            color: "#f0f3f7"

                            font.pixelSize: 24
                            font.bold: true
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                        Text {
                            text: modelData.detail
                            color: "#697586"

                            font.pixelSize: 12
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: 12
            color: "#0b1018"

            border.width: 1
            border.color: "#182332"

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 14

                Text {
                    text: "Activité récente"
                    color: "#f0f3f7"

                    font.pixelSize: 20
                    font.bold: true
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1

                    color: "#182332"
                }

                Item {
                    Layout.fillHeight: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    text: "Aucune donnée enregistrée"
                    color: "#647081"

                    font.pixelSize: 16
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    text: "Les événements CAN et les diagnostics apparaîtront ici."
                    color: "#4f5968"

                    font.pixelSize: 13
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
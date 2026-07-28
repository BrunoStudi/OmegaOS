import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Rectangle {
    id: root

    color: Theme.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.pageMargin

        spacing: Theme.spacingLarge

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: Theme.spacingTiny

                Text {
                    text: "CAN Bus"

                    color: Theme.textPrimary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontTitle
                    font.bold: true
                }

                Text {
                    text: "Communication et surveillance du réseau véhicule"

                    color: Theme.textSecondary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontMedium
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                id: connectionButton

                text: canBusViewModel.connected
                      ? "Déconnecter"
                      : "Connecter"

                implicitWidth: 150
                implicitHeight: 42

                onClicked: {
                    canBusViewModel.toggle_connection()
                }

                contentItem: Text {
                    text: connectionButton.text

                    color: Theme.textPrimary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontNormal
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: Theme.radiusSmall

                    color: canBusViewModel.connected
                           ? Theme.dangerBackground
                           : Theme.accentSoft

                    border.width: Theme.borderWidth

                    border.color: canBusViewModel.connected
                                  ? Theme.dangerBorder
                                  : Theme.borderSelected
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true

            columns: 4

            columnSpacing: Theme.spacingMedium
            rowSpacing: Theme.spacingMedium

            InfoCard {
                Layout.fillWidth: true

                title: "État"
                value: canBusViewModel.connection_status
                subtitle: canBusViewModel.mode

                accentColor: canBusViewModel.connected
                             ? Theme.success
                             : Theme.disconnected

                valueColor: canBusViewModel.connected
                            ? Theme.success
                            : Theme.textSecondary
            }

            InfoCard {
                Layout.fillWidth: true

                title: "Interface"
                value: canBusViewModel.interface_name
                subtitle: canBusViewModel.formatted_bitrate

                accentColor: Theme.accent
            }

            InfoCard {
                Layout.fillWidth: true

                title: "Trames reçues"
                value: canBusViewModel.frames_received.toString()

                subtitle: canBusViewModel.frames_per_second
                          + " trames/s"

                accentColor: Theme.warning
            }

            InfoCard {
                Layout.fillWidth: true

                title: "Dernière mise à jour"
                value: canBusViewModel.last_update
                subtitle: "Actualisation automatique"

                accentColor: Theme.success
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
                anchors.margins: Theme.spacingLarge

                spacing: Theme.spacingNormal

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Dernière trame CAN"

                        color: Theme.textPrimary

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontLarge
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        implicitWidth: modeText.implicitWidth + 22
                        implicitHeight: 28

                        radius: 14

                        color: Theme.warningBackground

                        border.width: Theme.borderWidth
                        border.color: Theme.warningBorder

                        Text {
                            id: modeText

                            anchors.centerIn: parent

                            text: "MODE "
                                  + canBusViewModel.mode.toUpperCase()

                            color: Theme.warning

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontTiny
                            font.bold: true
                        }
                    }
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

                    text: canBusViewModel.last_frame

                    color: canBusViewModel.connected
                           ? Theme.accent
                           : Theme.textMuted

                    font.family: "Consolas"
                    font.pixelSize: Theme.fontLarge
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    text: canBusViewModel.connected
                          ? "Réception simulée active"
                          : "Connecte le bus CAN pour commencer la réception"

                    color: Theme.textSecondary

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
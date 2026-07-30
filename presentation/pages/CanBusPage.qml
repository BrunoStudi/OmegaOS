import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Rectangle {
    id: root

    color: Theme.background

    readonly property bool configurationLocked:
        canBusViewModel.connected

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

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 160

            radius: Theme.radiusMedium
            color: Theme.surface

            border.width: Theme.borderWidth
            border.color: Theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingLarge

                spacing: Theme.spacingMedium

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Connexion CAN"

                        color: Theme.textPrimary

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontLarge
                        font.bold: true
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        implicitWidth: connectionStatusRow.implicitWidth + 24
                        implicitHeight: 30

                        radius: 15

                        color: canBusViewModel.connected
                               ? Theme.successBackground
                               : Theme.surfaceAlternative

                        border.width: Theme.borderWidth

                        border.color: canBusViewModel.connected
                                      ? Theme.successBorder
                                      : Theme.border

                        RowLayout {
                            id: connectionStatusRow

                            anchors.centerIn: parent
                            spacing: Theme.spacingSmall

                            Rectangle {
                                implicitWidth: 8
                                implicitHeight: 8
                                radius: 4

                                color: canBusViewModel.connected
                                       ? Theme.success
                                       : Theme.disconnected
                            }

                            Text {
                                text: canBusViewModel.connection_status

                                color: canBusViewModel.connected
                                       ? Theme.success
                                       : Theme.textSecondary

                                font.family: "Segoe UI"
                                font.pixelSize: Theme.fontSmall
                                font.bold: true
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingLarge

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingTiny

                        Text {
                            text: "MODE CAN"
                            color: Theme.textMuted

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontTiny
                            font.bold: true
                        }

                        ComboBox {
                            id: modeComboBox

                            Layout.fillWidth: true
                            implicitHeight: 40

                            enabled: !root.configurationLocked

                            model: [
                                "Simulation",
                                "SocketCAN"
                            ]

                            currentIndex:
                                canBusViewModel.mode === "socketcan"
                                ? 1
                                : 0

                            onActivated: function(index) {
                                canBusViewModel.set_mode(
                                    index === 1
                                    ? "socketcan"
                                    : "simulation"
                                )
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingTiny

                        Text {
                            text: "INTERFACE"
                            color: Theme.textMuted

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontTiny
                            font.bold: true
                        }

                        ComboBox {
                            id: interfaceComboBox

                            Layout.fillWidth: true
                            implicitHeight: 40

                            enabled: !root.configurationLocked
                                     && canBusViewModel.mode
                                        === "socketcan"

                            model: [
                                "can0",
                                "can1"
                            ]

                            currentIndex:
                                canBusViewModel.interface_name
                                === "can1"
                                ? 1
                                : 0

                            onActivated: function(index) {
                                canBusViewModel.set_interface_name(
                                    model[index]
                                )
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: Theme.spacingTiny

                        Text {
                            text: "DÉBIT"
                            color: Theme.textMuted

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontTiny
                            font.bold: true
                        }

                        ComboBox {
                            id: bitrateComboBox

                            Layout.fillWidth: true
                            implicitHeight: 40

                            enabled: !root.configurationLocked

                            model: [
                                "125 kbit/s",
                                "250 kbit/s",
                                "500 kbit/s",
                                "1 Mbit/s"
                            ]

                            currentIndex: {
                                switch (canBusViewModel.bitrate) {
                                case 125000:
                                    return 0
                                case 250000:
                                    return 1
                                case 1000000:
                                    return 3
                                default:
                                    return 2
                                }
                            }

                            onActivated: function(index) {
                                const bitrates = [
                                    125000,
                                    250000,
                                    500000,
                                    1000000
                                ]

                                canBusViewModel.set_bitrate(
                                    bitrates[index]
                                )
                            }
                        }
                    }

                    ColumnLayout {
                        Layout.preferredWidth: 160
                        spacing: Theme.spacingTiny

                        Text {
                            text: "CONNEXION AUTO."
                            color: Theme.textMuted

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontTiny
                            font.bold: true
                        }

                        CheckBox {
                            id: autoConnectCheckBox

                            text: "Activer au démarrage"
                            checked: canBusViewModel.auto_connect

                            onToggled: {
                                canBusViewModel.set_auto_connect(
                                    checked
                                )
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            visible: canBusViewModel.error_message !== ""

            Layout.fillWidth: true
            Layout.preferredHeight: visible ? 48 : 0

            radius: Theme.radiusSmall
            color: Theme.dangerBackground

            border.width: Theme.borderWidth
            border.color: Theme.dangerBorder

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingMedium
                anchors.rightMargin: Theme.spacingMedium

                spacing: Theme.spacingSmall

                Text {
                    text: "!"

                    color: Theme.danger

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontLarge
                    font.bold: true
                }

                Text {
                    Layout.fillWidth: true

                    text: canBusViewModel.error_message
                    color: Theme.danger

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontNormal

                    wrapMode: Text.WordWrap
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
                subtitle: canBusViewModel.display_mode

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
                value: canBusViewModel.mode === "simulation"
                       ? "Simulateur"
                       : canBusViewModel.interface_name

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
                subtitle: canBusViewModel.status_message

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
                                  + canBusViewModel.display_mode
                                    .toUpperCase()

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

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Theme.spacingLarge

                    Text {
                        text: "ID : "
                              + canBusViewModel.last_frame_id

                        color: Theme.textSecondary

                        font.family: "Consolas"
                        font.pixelSize: Theme.fontSmall
                    }

                    Text {
                        text: "DLC : "
                              + canBusViewModel.last_frame_dlc

                        color: Theme.textSecondary

                        font.family: "Consolas"
                        font.pixelSize: Theme.fontSmall
                    }

                    Text {
                        text: "Heure : "
                              + canBusViewModel.last_frame_time

                        color: Theme.textSecondary

                        font.family: "Consolas"
                        font.pixelSize: Theme.fontSmall
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    text: canBusViewModel.connected
                          ? canBusViewModel.status_message
                          : "Configure puis connecte le bus CAN."

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
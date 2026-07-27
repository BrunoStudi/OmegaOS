import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string applicationName: "OmegaOS"
    property string applicationVersion: "0.1.0"

    property bool canConnected: false
    property string cpuUsage: "--"
    property string raspberryTemperature: "--"

    property string currentTime: Qt.formatTime(
        new Date(),
        "HH:mm:ss"
    )

    implicitHeight: Theme.topBarHeight

    color: Theme.surface

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        height: Theme.borderWidth

        color: Theme.border
    }

    RowLayout {
        anchors.fill: parent

        anchors.leftMargin: Theme.spacingLarge
        anchors.rightMargin: Theme.spacingLarge

        spacing: Theme.spacingLarge

        RowLayout {
            spacing: Theme.spacingNormal

            Rectangle {
                implicitWidth: 42
                implicitHeight: 42

                radius: 21

                color: Theme.accentSoft

                border.width: Theme.borderWidth
                border.color: Theme.borderSelected

                Text {
                    anchors.centerIn: parent

                    text: "Ω"

                    color: Theme.accent

                    font.pixelSize: 25
                    font.bold: true
                }
            }

            ColumnLayout {
                spacing: 1

                Text {
                    text: root.applicationName

                    color: Theme.textPrimary

                    font.pixelSize: Theme.fontLarge
                    font.bold: true
                }

                Text {
                    text: "Version " + root.applicationVersion

                    color: Theme.textMuted

                    font.pixelSize: Theme.fontTiny
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: Theme.spacingLarge

            RowLayout {
                spacing: Theme.spacingSmall

                Rectangle {
                    implicitWidth: 9
                    implicitHeight: 9

                    radius: 5

                    color: root.canConnected
                           ? Theme.success
                           : Theme.disconnected

                    SequentialAnimation on opacity {
                        running: root.canConnected
                        loops: Animation.Infinite

                        NumberAnimation {
                            from: 1.0
                            to: 0.45
                            duration: 800
                        }

                        NumberAnimation {
                            from: 0.45
                            to: 1.0
                            duration: 800
                        }
                    }
                }

                ColumnLayout {
                    spacing: 0

                    Text {
                        text: "CAN"

                        color: Theme.textMuted

                        font.pixelSize: Theme.fontTiny
                        font.bold: true
                    }

                    Text {
                        text: root.canConnected
                              ? "Connecté"
                              : "Déconnecté"

                        color: root.canConnected
                               ? Theme.success
                               : Theme.textSecondary

                        font.pixelSize: Theme.fontSmall
                    }
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 30

                color: Theme.border
            }

            ColumnLayout {
                spacing: 0

                Text {
                    text: "CPU"

                    color: Theme.textMuted

                    font.pixelSize: Theme.fontTiny
                    font.bold: true
                }

                Text {
                    text: root.cpuUsage + " %"

                    color: Theme.textSecondary

                    font.pixelSize: Theme.fontSmall
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 30

                color: Theme.border
            }

            ColumnLayout {
                spacing: 0

                Text {
                    text: "RASPBERRY"

                    color: Theme.textMuted

                    font.pixelSize: Theme.fontTiny
                    font.bold: true
                }

                Text {
                    text: root.raspberryTemperature + " °C"

                    color: Theme.textSecondary

                    font.pixelSize: Theme.fontSmall
                }
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 30

                color: Theme.border
            }

            Text {
                text: root.currentTime

                color: Theme.textPrimary

                font.pixelSize: Theme.fontLarge
                font.bold: true
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            root.currentTime = Qt.formatTime(
                new Date(),
                "HH:mm:ss"
            )
        }
    }
}
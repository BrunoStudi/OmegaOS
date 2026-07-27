import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string statusMessage: "Prêt"
    property string hardwareName: "Raspberry Pi 3B+"
    property string pythonVersion: "Python"
    property string qtVersion: "Qt"
    property bool canConnected: false

    implicitHeight: Theme.statusBarHeight

    color: Theme.surfaceAlternative

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        height: Theme.borderWidth

        color: Theme.border
    }

    RowLayout {
        anchors.fill: parent

        anchors.leftMargin: Theme.spacingMedium
        anchors.rightMargin: Theme.spacingMedium

        spacing: Theme.spacingNormal

        RowLayout {
            spacing: Theme.spacingSmall

            Rectangle {
                implicitWidth: 7
                implicitHeight: 7

                radius: 4

                color: Theme.success
            }

            Text {
                text: root.statusMessage

                color: Theme.textSecondary

                font.pixelSize: Theme.fontSmall
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: root.hardwareName

            color: Theme.textMuted

            font.pixelSize: Theme.fontTiny
        }

        Text {
            text: "•"

            color: Theme.borderHover

            font.pixelSize: Theme.fontTiny
        }

        Text {
            text: root.pythonVersion

            color: Theme.textMuted

            font.pixelSize: Theme.fontTiny
        }

        Text {
            text: "•"

            color: Theme.borderHover

            font.pixelSize: Theme.fontTiny
        }

        Text {
            text: root.qtVersion

            color: Theme.textMuted

            font.pixelSize: Theme.fontTiny
        }

        Text {
            text: "•"

            color: Theme.borderHover

            font.pixelSize: Theme.fontTiny
        }

        RowLayout {
            spacing: Theme.spacingTiny

            Text {
                text: "CAN :"

                color: Theme.textMuted

                font.pixelSize: Theme.fontTiny
            }

            Text {
                text: root.canConnected
                      ? "Connecté"
                      : "Déconnecté"

                color: root.canConnected
                       ? Theme.success
                       : Theme.textSecondary

                font.pixelSize: Theme.fontTiny
                font.bold: true
            }
        }
    }
}
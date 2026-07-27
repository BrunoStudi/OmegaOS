import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property string applicationName: "OmegaOS"
    property string applicationVersion: "0.1.0"

    implicitHeight: 72
    color: "#0b1018"

    border.width: 1
    border.color: "#182332"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 24
        anchors.rightMargin: 24

        spacing: 14

        Text {
            text: "Ω"
            color: "#2aa7ff"

            font.pixelSize: 40
            font.bold: true

            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            spacing: 0

            Layout.alignment: Qt.AlignVCenter

            Text {
                text: root.applicationName.toUpperCase()
                color: "#f0f3f7"

                font.pixelSize: 22
                font.bold: true
                font.letterSpacing: 2
            }

            Text {
                text: "Version " + root.applicationVersion
                color: "#7f8a99"

                font.pixelSize: 12
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            id: clockText

            color: "#d8dee8"
            font.pixelSize: 24
            font.bold: true

            Layout.alignment: Qt.AlignVCenter

            function updateClock() {
                clockText.text = Qt.formatDateTime(
                    new Date(),
                    "HH:mm"
                )
            }

            Component.onCompleted: updateClock()

            Timer {
                interval: 1000
                running: true
                repeat: true

                onTriggered: clockText.updateClock()
            }
        }
    }
}
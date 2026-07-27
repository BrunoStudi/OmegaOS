import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string title: ""
    property string description: ""

    color: "#05070b"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 12

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: root.title
            color: "#f0f3f7"

            font.pixelSize: 34
            font.bold: true
        }

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: root.description
            color: "#7f8a99"

            font.pixelSize: 16
        }

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: "Module en développement"
            color: "#2aa7ff"

            font.pixelSize: 14
            font.bold: true
        }
    }
}
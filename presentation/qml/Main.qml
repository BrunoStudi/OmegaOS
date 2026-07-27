import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ApplicationWindow {
    id: root

    width: 1280
    height: 720
    visible: true

    title: applicationViewModel.application_name

    color: "#05070b"

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 18

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: "Ω"
            color: "#2aa7ff"

            font.pixelSize: 130
            font.bold: true
        }

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: applicationViewModel.application_name.toUpperCase()
            color: "#f0f3f7"

            font.pixelSize: 44
            font.bold: true
            font.letterSpacing: 4
        }

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: "Version " + applicationViewModel.application_version
            color: "#8b95a5"

            font.pixelSize: 18
        }

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: applicationViewModel.status_message
            color: "#49d17d"

            font.pixelSize: 16
        }
    }
}
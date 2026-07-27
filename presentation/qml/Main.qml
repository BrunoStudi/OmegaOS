import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"

ApplicationWindow {
    id: root

    width: 1280
    height: 720
    visible: true

    title: applicationViewModel.application_name
    color: "#05070b"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TopBar {
            Layout.fillWidth: true

            applicationName: applicationViewModel.application_name
            applicationVersion: applicationViewModel.application_version
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            color: "#05070b"

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 16

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    text: "Ω"
                    color: "#2aa7ff"

                    font.pixelSize: 100
                    font.bold: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter

                    text: applicationViewModel.status_message
                    color: "#49d17d"

                    font.pixelSize: 18
                }
            }
        }
    }
}
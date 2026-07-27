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

    property string currentPageName: "Tableau de bord"

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        TopBar {
            Layout.fillWidth: true

            applicationName: applicationViewModel.application_name
            applicationVersion: applicationViewModel.application_version
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            NavigationMenu {
                Layout.fillHeight: true
                Layout.preferredWidth: 230

                onPageSelected: function(index, pageName) {
                    root.currentPageName = pageName
                }
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

                        text: root.currentPageName
                        color: "#f0f3f7"

                        font.pixelSize: 34
                        font.bold: true
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter

                        text: root.currentPageName === "Tableau de bord"
                            ? applicationViewModel.status_message
                            : "Module en développement"

                        color: root.currentPageName === "Tableau de bord"
                            ? "#49d17d"
                            : "#8b95a5"

                        font.pixelSize: 18
                    }
                }
            }
        }
    }
}
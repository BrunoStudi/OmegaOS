import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root

    property int currentIndex: 0

    signal pageSelected(int index, string pageName)

    implicitWidth: 230
    color: "#0b1018"

    border.width: 1
    border.color: "#182332"

    ListModel {
        id: navigationModel

        ListElement {
            title: "Tableau de bord"
            iconText: "⌂"
        }

        ListElement {
            title: "Véhicule"
            iconText: "V"
        }

        ListElement {
            title: "CAN Bus"
            iconText: "C"
        }

        ListElement {
            title: "Diagnostics"
            iconText: "D"
        }

        ListElement {
            title: "Historique"
            iconText: "H"
        }

        ListElement {
            title: "Paramètres"
            iconText: "⚙"
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 20
        anchors.bottomMargin: 20

        spacing: 8

        Text {
            text: "NAVIGATION"
            color: "#687487"

            font.pixelSize: 11
            font.bold: true
            font.letterSpacing: 2

            Layout.leftMargin: 22
            Layout.bottomMargin: 8
        }

        Repeater {
            model: navigationModel

            delegate: Rectangle {
                required property int index
                required property string title
                required property string iconText

                Layout.fillWidth: true
                Layout.preferredHeight: 54
                Layout.leftMargin: 10
                Layout.rightMargin: 10

                radius: 8

                color: root.currentIndex === index
                    ? "#14283b"
                    : mouseArea.containsMouse
                        ? "#111a26"
                        : "transparent"

                border.width: root.currentIndex === index ? 1 : 0
                border.color: "#235b83"

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14

                    spacing: 14

                    Text {
                        text: iconText
                        color: root.currentIndex === index
                            ? "#2aa7ff"
                            : "#8793a5"

                        font.pixelSize: 20
                        font.bold: true

                        Layout.preferredWidth: 28
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Text {
                        text: title
                        color: root.currentIndex === index
                            ? "#f0f3f7"
                            : "#a5afbd"

                        font.pixelSize: 15
                        font.bold: root.currentIndex === index

                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.currentIndex = index
                        root.pageSelected(index, title)
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Text {
            text: "OmegaOS v0.1.0"
            color: "#566171"
            font.pixelSize: 11

            Layout.alignment: Qt.AlignHCenter
        }
    }
}
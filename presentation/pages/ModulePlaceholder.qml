import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string title: ""
    property string description: ""

    color: Theme.background

    ColumnLayout {
        anchors.centerIn: parent

        spacing: Theme.spacingNormal

        Rectangle {
            Layout.alignment: Qt.AlignHCenter

            implicitWidth: 72
            implicitHeight: 72

            radius: 36

            color: Theme.accentSoft

            border.width: Theme.borderWidth
            border.color: Theme.borderSelected

            Text {
                anchors.centerIn: parent

                text: "Ω"

                color: Theme.accent

                font.pixelSize: 34
                font.bold: true
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: root.title

            color: Theme.textPrimary

            font.pixelSize: 34
            font.bold: true
        }

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: root.description

            color: Theme.textSecondary

            font.pixelSize: Theme.fontMedium
        }

        Text {
            Layout.alignment: Qt.AlignHCenter

            text: "Module en développement"

            color: Theme.accent

            font.pixelSize: Theme.fontNormal
            font.bold: true
        }
    }
}
import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property string title: ""
    property string value: ""
    property string subtitle: ""

    property color accentColor: Theme.accent
    property color valueColor: Theme.textPrimary

    property bool interactive: false

    signal clicked()

    implicitHeight: 155

    radius: Theme.radiusMedium

    color: hoverHandler.hovered && root.interactive
           ? Theme.surfaceHover
           : Theme.surface

    border.width: Theme.borderWidth

    border.color: hoverHandler.hovered && root.interactive
                  ? Theme.borderHover
                  : Theme.border

    Behavior on color {
        ColorAnimation {
            duration: 140
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 140
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        width: 4

        color: root.accentColor

        radius: 2
    }

    ColumnLayout {
        anchors.fill: parent

        anchors.leftMargin: 22
        anchors.rightMargin: 20
        anchors.topMargin: 18
        anchors.bottomMargin: 18

        spacing: Theme.spacingSmall

        Text {
            Layout.fillWidth: true

            text: root.title

            color: Theme.textSecondary

            font.pixelSize: Theme.fontNormal
            font.bold: true

            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true

            text: root.value

            color: root.valueColor

            font.pixelSize: 24
            font.bold: true

            elide: Text.ElideRight
        }

        Item {
            Layout.fillHeight: true
        }

        Text {
            Layout.fillWidth: true

            text: root.subtitle

            color: Theme.textMuted

            font.pixelSize: Theme.fontSmall

            elide: Text.ElideRight
        }
    }

    HoverHandler {
        id: hoverHandler

        enabled: root.interactive
    }

    TapHandler {
        enabled: root.interactive

        onTapped: root.clicked()
    }
}
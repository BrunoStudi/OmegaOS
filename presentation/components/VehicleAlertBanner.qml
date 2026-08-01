import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property bool active: false
    property string severity: "info"
    property string title: "Aucune alerte"
    property string message: "Tous les systèmes fonctionnent normalement."
    property string iconText: "✓"

    signal acknowledged()

    readonly property color alertColor: {
        if (root.severity === "critical") {
            return Theme.danger
        }

        if (root.severity === "warning") {
            return Theme.warning
        }

        return Theme.success
    }

    readonly property color alertBackground: {
        if (root.severity === "critical") {
            return Theme.dangerBackground
        }

        if (root.severity === "warning") {
            return Theme.warningBackground
        }

        return Theme.successBackground
    }

    readonly property color alertBorder: {
        if (root.severity === "critical") {
            return Theme.dangerBorder
        }

        if (root.severity === "warning") {
            return Theme.warningBorder
        }

        return Theme.successBorder
    }

    implicitHeight: root.active ? 92 : 68

    radius: Theme.radiusMedium
    color: root.alertBackground

    border.width: Theme.borderWidth
    border.color: root.alertBorder

    Behavior on implicitHeight {
        NumberAnimation {
            duration: Theme.animationNormal
            easing.type: Easing.OutCubic
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.animationNormal
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Theme.animationNormal
        }
    }

    RowLayout {
        anchors.fill: parent

        anchors.leftMargin: Theme.spacingLarge
        anchors.rightMargin: Theme.spacingLarge
        anchors.topMargin: Theme.spacingNormal
        anchors.bottomMargin: Theme.spacingNormal

        spacing: Theme.spacingMedium

        Rectangle {
            implicitWidth: 46
            implicitHeight: 46

            radius: 23

            color: Qt.rgba(
                root.alertColor.r,
                root.alertColor.g,
                root.alertColor.b,
                0.18
            )

            border.width: Theme.borderWidth
            border.color: root.alertColor

            Text {
                anchors.centerIn: parent

                text: root.iconText
                color: root.alertColor

                font.family: "Segoe UI"
                font.pixelSize: 24
                font.bold: true
            }

            SequentialAnimation on opacity {
                running: root.active
                         && root.severity === "critical"

                loops: Animation.Infinite

                NumberAnimation {
                    from: 1.0
                    to: 0.45
                    duration: 500
                }

                NumberAnimation {
                    from: 0.45
                    to: 1.0
                    duration: 500
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            spacing: Theme.spacingTiny

            Text {
                Layout.fillWidth: true

                text: root.title.toUpperCase()
                color: root.alertColor

                font.family: "Segoe UI"
                font.pixelSize: Theme.fontNormal
                font.bold: true
                font.letterSpacing: 0.8
            }

            Text {
                Layout.fillWidth: true

                text: root.message
                color: Theme.textPrimary

                font.family: "Segoe UI"
                font.pixelSize: Theme.fontMedium

                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }
        }

        Rectangle {
            visible: root.active

            implicitWidth: severityText.implicitWidth + 22
            implicitHeight: 28

            radius: 14

            color: Qt.rgba(
                root.alertColor.r,
                root.alertColor.g,
                root.alertColor.b,
                0.12
            )

            border.width: Theme.borderWidth
            border.color: root.alertColor

            Text {
                id: severityText

                anchors.centerIn: parent

                text: root.severity === "critical"
                      ? "CRITIQUE"
                      : "AVERTISSEMENT"

                color: root.alertColor

                font.family: "Segoe UI"
                font.pixelSize: Theme.fontTiny
                font.bold: true
            }
        }

        Button {
            id: acknowledgeButton

            visible: root.active

            text: "Acquitter"

            implicitWidth: 105
            implicitHeight: 34

            onClicked: {
                root.acknowledged()
            }

            contentItem: Text {
                text: acknowledgeButton.text
                color: Theme.textPrimary

                font.family: "Segoe UI"
                font.pixelSize: Theme.fontSmall
                font.bold: true

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                radius: Theme.radiusSmall

                color: acknowledgeButton.down
                       ? Theme.surfaceSelected
                       : Theme.surfaceAlternative

                border.width: Theme.borderWidth
                border.color: root.alertColor
            }
        }
    }
}
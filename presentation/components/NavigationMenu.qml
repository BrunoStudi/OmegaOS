import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
    id: root

    property int currentIndex: 0

    signal pageSelected(
        int pageIndex,
        string pageName
    )

    implicitWidth: Theme.navigationWidth

    color: Theme.surface

    border.width: 0

    property var menuItems: [
        {
            "title": "Tableau de bord",
            "icon": "⌂"
        },
        {
            "title": "Véhicule",
            "icon": "◆"
        },
        {
            "title": "CAN Bus",
            "icon": "↔"
        },
        {
            "title": "Diagnostics",
            "icon": "!"
        },
        {
            "title": "Historique",
            "icon": "◷"
        },
        {
            "title": "Paramètres",
            "icon": "⚙"
        }
    ]

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        width: Theme.borderWidth

        color: Theme.border
    }

    ColumnLayout {
        anchors.fill: parent

        anchors.topMargin: Theme.spacingMedium
        anchors.bottomMargin: Theme.spacingMedium

        spacing: Theme.spacingTiny

        Text {
            Layout.leftMargin: Theme.spacingLarge
            Layout.bottomMargin: Theme.spacingSmall

            text: "NAVIGATION"

            color: Theme.textMuted

            font.pixelSize: Theme.fontTiny
            font.bold: true
            font.letterSpacing: 1.4
        }

        Repeater {
            model: root.menuItems

            delegate: Item {
                id: menuItem

                required property int index
                required property var modelData

                Layout.fillWidth: true
                Layout.preferredHeight: Theme.navigationItemHeight

                property bool selected: root.currentIndex === index

                Rectangle {
                    id: itemBackground

                    anchors.fill: parent

                    anchors.leftMargin: Theme.spacingSmall
                    anchors.rightMargin: Theme.spacingSmall

                    radius: Theme.radiusSmall

                    color: menuItem.selected
                           ? Theme.surfaceSelected
                           : mouseArea.containsMouse
                             ? Theme.surfaceHover
                             : "transparent"

                    border.width: menuItem.selected
                                  ? Theme.borderWidth
                                  : 0

                    border.color: menuItem.selected
                                  ? Theme.borderSelected
                                  : "transparent"

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
                }

                Rectangle {
                    anchors.left: itemBackground.left
                    anchors.verticalCenter: itemBackground.verticalCenter

                    width: menuItem.selected ? 4 : 0
                    height: menuItem.selected ? 30 : 0

                    radius: 2

                    color: Theme.accent

                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.animationFast
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on height {
                        NumberAnimation {
                            duration: Theme.animationNormal
                            easing.type: Easing.OutCubic
                        }
                    }
                }

                RowLayout {
                    anchors.fill: itemBackground

                    anchors.leftMargin: Theme.spacingMedium
                    anchors.rightMargin: Theme.spacingMedium

                    spacing: Theme.spacingNormal

                    Text {
                        text: menuItem.modelData.icon

                        color: menuItem.selected
                               ? Theme.accent
                               : Theme.textSecondary

                        font.pixelSize: 19
                        font.bold: true

                        Layout.preferredWidth: 24
                        Layout.alignment: Qt.AlignVCenter

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animationFast
                            }
                        }
                    }

                    Text {
                        Layout.fillWidth: true

                        text: menuItem.modelData.title

                        color: menuItem.selected
                               ? Theme.textPrimary
                               : Theme.textSecondary

                        font.pixelSize: Theme.fontNormal
                        font.bold: menuItem.selected

                        verticalAlignment: Text.AlignVCenter

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animationFast
                            }
                        }
                    }
                }

                MouseArea {
                    id: mouseArea

                    anchors.fill: parent

                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        root.currentIndex = menuItem.index

                        root.pageSelected(
                            menuItem.index,
                            menuItem.modelData.title
                        )
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            Layout.leftMargin: Theme.spacingMedium
            Layout.rightMargin: Theme.spacingMedium
            Layout.bottomMargin: Theme.spacingNormal

            color: Theme.border
        }

        RowLayout {
            Layout.fillWidth: true

            Layout.leftMargin: Theme.spacingLarge
            Layout.rightMargin: Theme.spacingLarge

            spacing: Theme.spacingSmall

            Rectangle {
                implicitWidth: 8
                implicitHeight: 8

                radius: 4

                color: Theme.success
            }

            ColumnLayout {
                Layout.fillWidth: true

                spacing: 0

                Text {
                    text: "OmegaOS"

                    color: Theme.textSecondary

                    font.pixelSize: Theme.fontSmall
                    font.bold: true
                }

                Text {
                    text: "Système opérationnel"

                    color: Theme.textMuted

                    font.pixelSize: Theme.fontTiny
                }
            }
        }
    }
}
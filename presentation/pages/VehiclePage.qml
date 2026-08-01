import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components/vehicle"
import "../theme"

Rectangle {
    id: root

    color: Theme.background

    property bool frontLeftDoorOpen: false
    property bool frontRightDoorOpen: false
    property bool rearLeftDoorOpen: false
    property bool rearRightDoorOpen: false

    property bool hoodOpen: false
    property bool trunkOpen: false

    property bool headlightsOn: false
    property bool highBeamsOn: false
    property bool brakeLightsOn: false
    property bool reverseLightsOn: false

    property bool leftIndicatorOn: false
    property bool rightIndicatorOn: false

    readonly property bool anyOpeningOpen:
        frontLeftDoorOpen
        || frontRightDoorOpen
        || rearLeftDoorOpen
        || rearRightDoorOpen
        || hoodOpen
        || trunkOpen

    function closeEverything() {
        frontLeftDoorOpen = false
        frontRightDoorOpen = false
        rearLeftDoorOpen = false
        rearRightDoorOpen = false

        hoodOpen = false
        trunkOpen = false

        headlightsOn = false
        highBeamsOn = false
        brakeLightsOn = false
        reverseLightsOn = false

        leftIndicatorOn = false
        rightIndicatorOn = false
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.pageMargin

        spacing: Theme.spacingMedium

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: Theme.spacingTiny

                Text {
                    text: "Véhicule"

                    color: Theme.textPrimary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontTitle
                    font.bold: true
                }

                Text {
                    text: "Vue générale de l’Opel Omega B"

                    color: Theme.textSecondary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontMedium
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                implicitWidth: vehicleStatusRow.implicitWidth + 28
                implicitHeight: 38

                radius: 19

                color: root.anyOpeningOpen
                       ? Theme.warningBackground
                       : Theme.successBackground

                border.width: Theme.borderWidth

                border.color: root.anyOpeningOpen
                              ? Theme.warningBorder
                              : Theme.successBorder

                RowLayout {
                    id: vehicleStatusRow

                    anchors.centerIn: parent
                    spacing: Theme.spacingSmall

                    Rectangle {
                        implicitWidth: 9
                        implicitHeight: 9

                        radius: 5

                        color: root.anyOpeningOpen
                               ? Theme.warning
                               : Theme.success
                    }

                    Text {
                        text: root.anyOpeningOpen
                              ? "OUVRANT DÉTECTÉ"
                              : "VÉHICULE SÉCURISÉ"

                        color: root.anyOpeningOpen
                               ? Theme.warning
                               : Theme.success

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontSmall
                        font.bold: true
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            spacing: Theme.spacingMedium

            /*
             * Vue du véhicule
             */
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                Layout.minimumWidth: 500

                radius: Theme.radiusMedium

                color: Theme.surface

                border.width: Theme.borderWidth
                border.color: Theme.border

                VehicleView {
                    anchors.centerIn: parent

                    width: Math.min(
                        parent.width - 30,
                        470
                    )

                    height: Math.min(
                        parent.height - 24,
                        590
                    )

                    frontLeftDoorOpen:
                        root.frontLeftDoorOpen

                    frontRightDoorOpen:
                        root.frontRightDoorOpen

                    rearLeftDoorOpen:
                        root.rearLeftDoorOpen

                    rearRightDoorOpen:
                        root.rearRightDoorOpen

                    hoodOpen:
                        root.hoodOpen

                    trunkOpen:
                        root.trunkOpen

                    headlightsOn:
                        root.headlightsOn

                    highBeamsOn:
                        root.highBeamsOn

                    brakeLightsOn:
                        root.brakeLightsOn

                    reverseLightsOn:
                        root.reverseLightsOn

                    leftIndicatorOn:
                        root.leftIndicatorOn

                    rightIndicatorOn:
                        root.rightIndicatorOn
                }
            }

            /*
             * Commandes de démonstration
             */
            Rectangle {
                Layout.preferredWidth: 360
                Layout.fillHeight: true

                radius: Theme.radiusMedium

                color: Theme.surface

                border.width: Theme.borderWidth
                border.color: Theme.border

                ScrollView {
                    anchors.fill: parent

                    anchors.leftMargin: Theme.spacingLarge
                    anchors.rightMargin: Theme.spacingLarge
                    anchors.topMargin: Theme.spacingLarge
                    anchors.bottomMargin: Theme.spacingLarge

                    clip: true

                    ColumnLayout {
                        width: 310

                        spacing: Theme.spacingMedium

                        Text {
                            text: "Simulation des états"

                            color: Theme.textPrimary

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontLarge
                            font.bold: true
                        }

                        Text {
                            Layout.fillWidth: true

                            text:
                                "Ces commandes sont temporaires. "
                                + "Elles seront ensuite pilotées "
                                + "par les trames CAN."

                            color: Theme.textMuted

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontSmall

                            wrapMode: Text.WordWrap
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1

                            color: Theme.border
                        }

                        Text {
                            text: "OUVRANTS"

                            color: Theme.textMuted

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontTiny
                            font.bold: true
                            font.letterSpacing: 1.2
                        }

                        CheckBox {
                            text: "Porte avant gauche"

                            checked:
                                root.frontLeftDoorOpen

                            onToggled: {
                                root.frontLeftDoorOpen =
                                    checked
                            }
                        }

                        CheckBox {
                            text: "Porte avant droite"

                            checked:
                                root.frontRightDoorOpen

                            onToggled: {
                                root.frontRightDoorOpen =
                                    checked
                            }
                        }

                        CheckBox {
                            text: "Porte arrière gauche"

                            checked:
                                root.rearLeftDoorOpen

                            onToggled: {
                                root.rearLeftDoorOpen =
                                    checked
                            }
                        }

                        CheckBox {
                            text: "Porte arrière droite"

                            checked:
                                root.rearRightDoorOpen

                            onToggled: {
                                root.rearRightDoorOpen =
                                    checked
                            }
                        }

                        CheckBox {
                            text: "Capot"

                            checked:
                                root.hoodOpen

                            onToggled: {
                                root.hoodOpen = checked
                            }
                        }

                        CheckBox {
                            text: "Coffre"

                            checked:
                                root.trunkOpen

                            onToggled: {
                                root.trunkOpen = checked
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 1

                            color: Theme.border
                        }

                        Text {
                            text: "ÉCLAIRAGE"

                            color: Theme.textMuted

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontTiny
                            font.bold: true
                            font.letterSpacing: 1.2
                        }

                        CheckBox {
                            text: "Feux de croisement"

                            checked:
                                root.headlightsOn

                            onToggled: {
                                root.headlightsOn = checked

                                if (!checked) {
                                    root.highBeamsOn = false
                                }
                            }
                        }

                        CheckBox {
                            text: "Pleins phares"

                            checked:
                                root.highBeamsOn

                            onToggled: {
                                root.highBeamsOn = checked

                                if (checked) {
                                    root.headlightsOn = true
                                }
                            }
                        }

                        CheckBox {
                            text: "Feux stop"

                            checked:
                                root.brakeLightsOn

                            onToggled: {
                                root.brakeLightsOn =
                                    checked
                            }
                        }

                        CheckBox {
                            text: "Feux de recul"

                            checked:
                                root.reverseLightsOn

                            onToggled: {
                                root.reverseLightsOn =
                                    checked
                            }
                        }

                        CheckBox {
                            text: "Clignotant gauche"

                            checked:
                                root.leftIndicatorOn

                            onToggled: {
                                root.leftIndicatorOn =
                                    checked
                            }
                        }

                        CheckBox {
                            text: "Clignotant droit"

                            checked:
                                root.rightIndicatorOn

                            onToggled: {
                                root.rightIndicatorOn =
                                    checked
                            }
                        }

                        Button {
                            id: resetButton

                            Layout.fillWidth: true
                            Layout.preferredHeight: 40

                            text: "Réinitialiser les états"

                            onClicked: {
                                root.closeEverything()
                            }

                            contentItem: Text {
                                text: resetButton.text

                                color: Theme.textPrimary

                                font.family: "Segoe UI"
                                font.pixelSize: Theme.fontSmall
                                font.bold: true

                                horizontalAlignment:
                                    Text.AlignHCenter

                                verticalAlignment:
                                    Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: Theme.radiusSmall

                                color: Theme.dangerBackground

                                border.width:
                                    Theme.borderWidth

                                border.color:
                                    Theme.dangerBorder
                            }
                        }
                    }
                }
            }
        }
    }
}
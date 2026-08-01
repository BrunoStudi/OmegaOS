import QtQuick
import QtQuick.Layouts

import "../../theme"

Item {
    id: root

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

    property color bodyColor: "#89929F"
    property color bodyHighlight: "#B8C0CB"
    property color glassColor: "#172533"

    property bool indicatorVisible: true

    implicitWidth: 470
    implicitHeight: 590

    Timer {
        interval: 500
        running:
            root.leftIndicatorOn
            || root.rightIndicatorOn

        repeat: true

        onTriggered: {
            root.indicatorVisible =
                !root.indicatorVisible
        }
    }

    onLeftIndicatorOnChanged: {
        if (!leftIndicatorOn && !rightIndicatorOn) {
            indicatorVisible = true
        }
    }

    onRightIndicatorOnChanged: {
        if (!leftIndicatorOn && !rightIndicatorOn) {
            indicatorVisible = true
        }
    }

    Rectangle {
        anchors.centerIn: parent

        width: 390
        height: 550

        radius: 145

        color: "#07101A"

        border.width: 1
        border.color: Theme.border
    }

    /*
     * Ombre de la voiture
     */
    Rectangle {
        anchors.horizontalCenter: carBody.horizontalCenter
        anchors.verticalCenter: carBody.verticalCenter

        anchors.verticalCenterOffset: 10

        width: carBody.width + 24
        height: carBody.height + 26

        radius: carBody.radius + 8

        color: "#77000000"
    }

    /*
     * Carrosserie principale
     */
    Rectangle {
        id: carBody

        anchors.centerIn: parent

        width: 250
        height: 500

        radius: 92

        color: root.bodyColor

        border.width: 2
        border.color: root.bodyHighlight

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#B7BEC8"
            }

            GradientStop {
                position: 0.48
                color: root.bodyColor
            }

            GradientStop {
                position: 1.0
                color: "#626C79"
            }
        }
    }

    /*
     * Capot
     */
    Rectangle {
        id: hood

        anchors.horizontalCenter: carBody.horizontalCenter
        anchors.top: carBody.top
        anchors.topMargin: 22

        width: 184
        height: 112

        radius: 45

        color: root.hoodOpen
               ? Theme.warningBackground
               : "#929BA7"

        border.width: root.hoodOpen ? 3 : 1

        border.color: root.hoodOpen
                      ? Theme.warning
                      : "#C1C8D0"

        transformOrigin: Item.Bottom

        rotation: root.hoodOpen ? -8 : 0

        Behavior on rotation {
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

        Text {
            anchors.centerIn: parent

            visible: root.hoodOpen

            text: "CAPOT OUVERT"

            color: Theme.warning

            font.family: "Segoe UI"
            font.pixelSize: Theme.fontTiny
            font.bold: true
        }
    }

    /*
     * Pare-brise
     */
    Rectangle {
        anchors.horizontalCenter: carBody.horizontalCenter
        anchors.top: carBody.top
        anchors.topMargin: 128

        width: 178
        height: 76

        radius: 28

        color: root.glassColor

        border.width: 2
        border.color: "#45647D"

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#28475D"
            }

            GradientStop {
                position: 1.0
                color: "#101D27"
            }
        }
    }

    /*
     * Pavillon
     */
    Rectangle {
        anchors.horizontalCenter: carBody.horizontalCenter
        anchors.top: carBody.top
        anchors.topMargin: 196

        width: 170
        height: 160

        radius: 35

        color: "#747E8A"

        border.width: 1
        border.color: "#B0B8C2"
    }

    /*
     * Lunette arrière
     */
    Rectangle {
        anchors.horizontalCenter: carBody.horizontalCenter
        anchors.top: carBody.top
        anchors.topMargin: 342

        width: 176
        height: 68

        radius: 27

        color: root.glassColor

        border.width: 2
        border.color: "#45647D"

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: "#101D27"
            }

            GradientStop {
                position: 1.0
                color: "#28475D"
            }
        }
    }

    /*
     * Coffre
     */
    Rectangle {
        id: trunk

        anchors.horizontalCenter: carBody.horizontalCenter
        anchors.bottom: carBody.bottom
        anchors.bottomMargin: 22

        width: 188
        height: 94

        radius: 38

        color: root.trunkOpen
               ? Theme.warningBackground
               : "#78828E"

        border.width: root.trunkOpen ? 3 : 1

        border.color: root.trunkOpen
                      ? Theme.warning
                      : "#B5BDC7"

        transformOrigin: Item.Top

        rotation: root.trunkOpen ? 8 : 0

        Behavior on rotation {
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

        Text {
            anchors.centerIn: parent

            visible: root.trunkOpen

            text: "COFFRE OUVERT"

            color: Theme.warning

            font.family: "Segoe UI"
            font.pixelSize: Theme.fontTiny
            font.bold: true
        }
    }

    /*
     * Porte avant gauche
     */
    Rectangle {
        id: frontLeftDoor

        anchors.right: carBody.left
        anchors.rightMargin: -24

        anchors.top: carBody.top
        anchors.topMargin: 178

        width: 36
        height: 118

        radius: 18

        color: root.frontLeftDoorOpen
            ? Theme.warningBackground
            : "#7E8895"

        border.width: root.frontLeftDoorOpen ? 3 : 1

        border.color: root.frontLeftDoorOpen
                    ? Theme.warning
                    : "#B4BCC6"

        // Charnière placée à l’avant et contre la carrosserie.
        transformOrigin: Item.TopRight

        // Côté gauche : ouverture vers l’extérieur.
        rotation: root.frontLeftDoorOpen ? 30 : 0

        Behavior on rotation {
            NumberAnimation {
                duration: Theme.animationNormal
                easing.type: Easing.OutBack
            }
        }
    }

    /*
     * Porte avant droite
     */
    Rectangle {
        id: frontRightDoor

        anchors.left: carBody.right
        anchors.leftMargin: -24

        anchors.top: carBody.top
        anchors.topMargin: 178

        width: 36
        height: 118

        radius: 18

        color: root.frontRightDoorOpen
            ? Theme.warningBackground
            : "#7E8895"

        border.width: root.frontRightDoorOpen ? 3 : 1

        border.color: root.frontRightDoorOpen
                    ? Theme.warning
                    : "#B4BCC6"

        transformOrigin: Item.TopLeft

        // Côté droit : rotation opposée.
        rotation: root.frontRightDoorOpen ? -30 : 0

        Behavior on rotation {
            NumberAnimation {
                duration: Theme.animationNormal
                easing.type: Easing.OutBack
            }
        }
    }

    /*
     * Porte arrière gauche
     */
    Rectangle {
        id: rearLeftDoor

        anchors.right: carBody.left
        anchors.rightMargin: -24

        anchors.top: carBody.top
        anchors.topMargin: 300

        width: 36
        height: 108

        radius: 18

        color: root.rearLeftDoorOpen
            ? Theme.warningBackground
            : "#727C88"

        border.width: root.rearLeftDoorOpen ? 3 : 1

        border.color: root.rearLeftDoorOpen
                    ? Theme.warning
                    : "#ADB5BF"

        // La porte arrière est elle aussi articulée par son bord avant.
        transformOrigin: Item.TopRight

        rotation: root.rearLeftDoorOpen ? 30 : 0

        Behavior on rotation {
            NumberAnimation {
                duration: Theme.animationNormal
                easing.type: Easing.OutBack
            }
        }
    }

    /*
     * Porte arrière droite
     */
    Rectangle {
        id: rearRightDoor

        anchors.left: carBody.right
        anchors.leftMargin: -24

        anchors.top: carBody.top
        anchors.topMargin: 300

        width: 36
        height: 108

        radius: 18

        color: root.rearRightDoorOpen
            ? Theme.warningBackground
            : "#727C88"

        border.width: root.rearRightDoorOpen ? 3 : 1

        border.color: root.rearRightDoorOpen
                    ? Theme.warning
                    : "#ADB5BF"

        transformOrigin: Item.TopLeft

        rotation: root.rearRightDoorOpen ? -30 : 0

        Behavior on rotation {
            NumberAnimation {
                duration: Theme.animationNormal
                easing.type: Easing.OutBack
            }
        }
    }

    /*
     * Roues gauches
     */
    Rectangle {
        anchors.right: carBody.left
        anchors.rightMargin: -15
        anchors.top: carBody.top
        anchors.topMargin: 112

        width: 28
        height: 82

        radius: 10

        color: "#11151A"

        border.width: 2
        border.color: "#353B42"
    }

    Rectangle {
        anchors.right: carBody.left
        anchors.rightMargin: -15
        anchors.bottom: carBody.bottom
        anchors.bottomMargin: 105

        width: 28
        height: 82

        radius: 10

        color: "#11151A"

        border.width: 2
        border.color: "#353B42"
    }

    /*
     * Roues droites
     */
    Rectangle {
        anchors.left: carBody.right
        anchors.leftMargin: -15
        anchors.top: carBody.top
        anchors.topMargin: 112

        width: 28
        height: 82

        radius: 10

        color: "#11151A"

        border.width: 2
        border.color: "#353B42"
    }

    Rectangle {
        anchors.left: carBody.right
        anchors.leftMargin: -15
        anchors.bottom: carBody.bottom
        anchors.bottomMargin: 105

        width: 28
        height: 82

        radius: 10

        color: "#11151A"

        border.width: 2
        border.color: "#353B42"
    }

    /*
     * Phares avant
     */
    Rectangle {
        anchors.left: carBody.left
        anchors.leftMargin: 30
        anchors.top: carBody.top
        anchors.topMargin: 22

        width: 62
        height: 20

        radius: 9

        color: root.highBeamsOn
               ? "#FFFFFF"
               : root.headlightsOn
                 ? "#D9F1FF"
                 : "#46515C"

        border.width: 1
        border.color: root.headlightsOn
                      || root.highBeamsOn
                      ? "#FFFFFF"
                      : "#6C7782"

        opacity: root.headlightsOn
                 || root.highBeamsOn
                 ? 1.0
                 : 0.75
    }

    Rectangle {
        anchors.right: carBody.right
        anchors.rightMargin: 30
        anchors.top: carBody.top
        anchors.topMargin: 22

        width: 62
        height: 20

        radius: 9

        color: root.highBeamsOn
               ? "#FFFFFF"
               : root.headlightsOn
                 ? "#D9F1FF"
                 : "#46515C"

        border.width: 1
        border.color: root.headlightsOn
                      || root.highBeamsOn
                      ? "#FFFFFF"
                      : "#6C7782"

        opacity: root.headlightsOn
                 || root.highBeamsOn
                 ? 1.0
                 : 0.75
    }

    /*
     * Halos des phares
     */
    Rectangle {
        visible: root.headlightsOn || root.highBeamsOn

        anchors.horizontalCenter: carBody.horizontalCenter
        anchors.bottom: carBody.top
        anchors.bottomMargin: -4

        width: 210
        height: root.highBeamsOn ? 100 : 60

        radius: width / 2

        color: root.highBeamsOn
               ? "#22FFFFFF"
               : "#16CFEFFF"
    }

    /*
     * Feux arrière
     */
    Rectangle {
        anchors.left: carBody.left
        anchors.leftMargin: 34
        anchors.bottom: carBody.bottom
        anchors.bottomMargin: 20

        width: 52
        height: 19

        radius: 8

        color: root.brakeLightsOn
               ? "#FF2F3A"
               : "#701C25"

        border.width: 1
        border.color: root.brakeLightsOn
                      ? "#FF7A82"
                      : "#A8434B"
    }

    Rectangle {
        anchors.right: carBody.right
        anchors.rightMargin: 34
        anchors.bottom: carBody.bottom
        anchors.bottomMargin: 20

        width: 52
        height: 19

        radius: 8

        color: root.brakeLightsOn
               ? "#FF2F3A"
               : "#701C25"

        border.width: 1
        border.color: root.brakeLightsOn
                      ? "#FF7A82"
                      : "#A8434B"
    }

    /*
     * Feux de recul
     */
    Rectangle {
        visible: root.reverseLightsOn

        anchors.horizontalCenter: carBody.horizontalCenter
        anchors.bottom: carBody.bottom
        anchors.bottomMargin: 20

        width: 46
        height: 15

        radius: 7

        color: "#F4F8FF"

        border.width: 1
        border.color: "#FFFFFF"
    }

    /*
     * Clignotant avant gauche
     */
    Rectangle {
        visible:
            root.leftIndicatorOn
            && root.indicatorVisible

        anchors.left: carBody.left
        anchors.leftMargin: 18
        anchors.top: carBody.top
        anchors.topMargin: 42

        width: 26
        height: 14

        radius: 7

        color: Theme.warning
    }

    /*
     * Clignotant avant droit
     */
    Rectangle {
        visible:
            root.rightIndicatorOn
            && root.indicatorVisible

        anchors.right: carBody.right
        anchors.rightMargin: 18
        anchors.top: carBody.top
        anchors.topMargin: 42

        width: 26
        height: 14

        radius: 7

        color: Theme.warning
    }

    /*
     * Clignotant arrière gauche
     */
    Rectangle {
        visible:
            root.leftIndicatorOn
            && root.indicatorVisible

        anchors.left: carBody.left
        anchors.leftMargin: 18
        anchors.bottom: carBody.bottom
        anchors.bottomMargin: 42

        width: 26
        height: 14

        radius: 7

        color: Theme.warning
    }

    /*
     * Clignotant arrière droit
     */
    Rectangle {
        visible:
            root.rightIndicatorOn
            && root.indicatorVisible

        anchors.right: carBody.right
        anchors.rightMargin: 18
        anchors.bottom: carBody.bottom
        anchors.bottomMargin: 42

        width: 26
        height: 14

        radius: 7

        color: Theme.warning
    }

    /*
     * Logo simplifié
     */
    Rectangle {
        anchors.horizontalCenter: carBody.horizontalCenter
        anchors.top: carBody.top
        anchors.topMargin: 68

        width: 28
        height: 28

        radius: 14

        color: "transparent"

        border.width: 2
        border.color: "#DCE2E8"

        Text {
            anchors.centerIn: parent

            text: "⚡"

            color: "#DCE2E8"

            font.family: "Segoe UI Symbol"
            font.pixelSize: 14
            font.bold: true
        }
    }
}
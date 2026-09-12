import QtQuick
import QtQuick.Layouts

import "../../theme"

Item {
    id: root

    /*
     * Interface publique conservée afin que VehiclePage.qml
     * continue de fonctionner sans modification.
     */
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

    // Conservées pour compatibilité avec l'ancienne vue.
    property color bodyColor: "#89929F"
    property color bodyHighlight: "#B8C0CB"
    property color glassColor: "#172533"

    property bool indicatorVisible: true

    implicitWidth: 470
    implicitHeight: 590

    /*
     * Le SVG utilise le viewBox :
     *     0 255 570 315
     *
     * Les quatre portes utilisent le même canvas complet.
     * Les calques sont pré-rendus en PNG transparent afin d'éviter
     * les limitations de QtSvg sur clipPath/use. Les pivots restent
     * exprimés dans les coordonnées du SVG d'origine.
     */
    readonly property real svgViewBoxX: 0.0
    readonly property real svgViewBoxY: 255.0
    readonly property real svgViewBoxWidth: 570.0
    readonly property real svgViewBoxHeight: 315.0

    function svgX(value) {
        return ((value - svgViewBoxX) / svgViewBoxWidth) * vehicleSvg.width
    }

    function svgY(value) {
        return ((value - svgViewBoxY) / svgViewBoxHeight) * vehicleSvg.height
    }

    Timer {
        interval: 500
        running: root.leftIndicatorOn || root.rightIndicatorOn
        repeat: true

        onTriggered: {
            root.indicatorVisible = !root.indicatorVisible
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

    /*
     * Fond de la zone véhicule.
     */
    Rectangle {
        id: backgroundPanel

        anchors.centerIn: parent

        width: Math.min(parent.width - 28, 410)
        height: Math.min(parent.height - 28, 560)

        radius: 42

        color: "#07101A"

        border.width: 1
        border.color: Theme.border
    }

    /*
     * Ombre générale.
     *
     * Le dessin source est horizontal (avant vers la gauche).
     * vehicleSvg est ensuite tourné de +90° pour afficher
     * l'avant du véhicule vers le haut de l'écran.
     */
    Rectangle {
        anchors.centerIn: vehicleSvg

        width: vehicleSvg.height * 0.93
        height: vehicleSvg.width * 0.93

        radius: width / 2

        color: "#42000000"

        rotation: 90

        z: 0
    }

    Item {
        id: vehicleSvg

        anchors.centerIn: parent

        // Après rotation de 90°, la longueur occupe environ 90 % de la hauteur.
        width: Math.min(root.height * 0.90, root.width * 1.65)
        height: width * root.svgViewBoxHeight / root.svgViewBoxWidth

        rotation: 90

        z: 1

        /*
         * Carrosserie sans les quatre portes.
         */
        Image {
            id: bodyImage

            anchors.fill: parent

            source: "assets/omega_b2_body.png"

            fillMode: Image.Stretch
            smooth: true
            mipmap: true
        }

        /*
         * Porte avant droite
         *
         * Pivot issu du SVG validé :
         * 177.17318 ; 310.64028
         */
        Image {
            id: frontRightDoor

            anchors.fill: parent

            source: "assets/porte_av_droite.png"

            fillMode: Image.Stretch
            smooth: true
            mipmap: true

            transform: Rotation {
                id: frontRightDoorRotation

                origin.x: root.svgX(177.17318)
                origin.y: root.svgY(310.64028)

                angle: root.frontRightDoorOpen ? -32 : 0

                Behavior on angle {
                    NumberAnimation {
                        duration: Theme.animationNormal
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        /*
         * Porte arrière droite
         *
         * Pivot issu du SVG validé :
         * 301.74806 ; 309.80139
         */
        Image {
            id: rearRightDoor

            anchors.fill: parent

            source: "assets/porte_ar_droite.png"

            fillMode: Image.Stretch
            smooth: true
            mipmap: true

            transform: Rotation {
                id: rearRightDoorRotation

                origin.x: root.svgX(301.74806)
                origin.y: root.svgY(309.80139)

                angle: root.rearRightDoorOpen ? -32 : 0

                Behavior on angle {
                    NumberAnimation {
                        duration: Theme.animationNormal
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        /*
         * Porte avant gauche
         *
         * Pivot issu du SVG validé :
         * 175.83095 ; 515.24510
         */
        Image {
            id: frontLeftDoor

            anchors.fill: parent

            source: "assets/porte_av_gauche.png"

            fillMode: Image.Stretch
            smooth: true
            mipmap: true

            transform: Rotation {
                id: frontLeftDoorRotation

                origin.x: root.svgX(175.83095)
                origin.y: root.svgY(515.24510)

                angle: root.frontLeftDoorOpen ? 32 : 0

                Behavior on angle {
                    NumberAnimation {
                        duration: Theme.animationNormal
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        /*
         * Porte arrière gauche
         *
         * Pivot issu du SVG validé :
         * 301.04062 ; 516.54419
         */
        Image {
            id: rearLeftDoor

            anchors.fill: parent

            source: "assets/porte_ar_gauche.png"

            fillMode: Image.Stretch
            smooth: true
            mipmap: true

            transform: Rotation {
                id: rearLeftDoorRotation

                origin.x: root.svgX(301.04062)
                origin.y: root.svgY(516.54419)

                angle: root.rearLeftDoorOpen ? 32 : 0

                Behavior on angle {
                    NumberAnimation {
                        duration: Theme.animationNormal
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        /*
         * Feux de croisement.
         */
        Image {
            anchors.fill: parent

            source: "assets/lights_front_low.png"

            fillMode: Image.Stretch
            smooth: true
            mipmap: true

            visible: root.headlightsOn && !root.highBeamsOn

            opacity: visible ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }
        }

        /*
         * Pleins phares.
         */
        Image {
            anchors.fill: parent

            source: "assets/lights_front_high.png"

            fillMode: Image.Stretch
            smooth: true
            mipmap: true

            visible: root.highBeamsOn

            opacity: visible ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation {
                    duration: 120
                }
            }
        }

        /*
         * Feux stop.
         */
        Image {
            anchors.fill: parent

            source: "assets/lights_rear_brake.png"

            fillMode: Image.Stretch
            smooth: true
            mipmap: true

            visible: root.brakeLightsOn
        }

        /*
         * Feux de recul.
         *
         * Pour l'instant le masque couvre le bloc optique arrière complet,
         * puisque le SVG utilisateur ne sépare pas encore la zone blanche
         * du feu de recul.
         */
        Image {
            anchors.fill: parent

            source: "assets/lights_rear_reverse.png"

            fillMode: Image.Stretch
            smooth: true
            mipmap: true

            visible: root.reverseLightsOn
        }

        /*
         * Clignotant gauche.
         *
         * Le masque utilisateur actuel correspond au bloc optique complet.
         * La couleur ambre permet déjà de conserver le comportement
         * fonctionnel en attendant un éventuel masque dédié.
         */
        Image {
            anchors.fill: parent

            source: "assets/indicator_left.png"

            fillMode: Image.Stretch
            smooth: true
            mipmap: true

            visible:
                root.leftIndicatorOn
                && root.indicatorVisible
        }

        /*
         * Clignotant droit.
         */
        Image {
            anchors.fill: parent

            source: "assets/indicator_right.png"

            fillMode: Image.Stretch
            smooth: true
            mipmap: true

            visible:
                root.rightIndicatorOn
                && root.indicatorVisible
        }
    }

    /*
     * Le SVG actuel possède des masques précis pour les portes et les feux,
     * mais pas encore pour le capot et le coffre.
     *
     * On conserve néanmoins leur état visuel pour ne casser aucune commande
     * existante de VehiclePage.qml.
     */
    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: backgroundPanel.top
        anchors.topMargin: 14

        visible: root.hoodOpen

        height: 28
        width: hoodText.width + 24

        radius: height / 2

        color: Theme.warningBackground

        border.width: 1
        border.color: Theme.warning

        z: 10

        Text {
            id: hoodText

            anchors.centerIn: parent

            text: "CAPOT OUVERT"

            color: Theme.warning

            font.family: "Segoe UI"
            font.pixelSize: Theme.fontTiny
            font.bold: true
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: backgroundPanel.bottom
        anchors.bottomMargin: 14

        visible: root.trunkOpen

        height: 28
        width: trunkText.width + 24

        radius: height / 2

        color: Theme.warningBackground

        border.width: 1
        border.color: Theme.warning

        z: 10

        Text {
            id: trunkText

            anchors.centerIn: parent

            text: "COFFRE OUVERT"

            color: Theme.warning

            font.family: "Segoe UI"
            font.pixelSize: Theme.fontTiny
            font.bold: true
        }
    }
}

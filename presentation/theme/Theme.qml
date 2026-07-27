pragma Singleton

import QtQuick

QtObject {
    // Couleurs générales
    readonly property color background: "#05070B"
    readonly property color surface: "#0B1018"
    readonly property color surfaceHover: "#101824"
    readonly property color surfaceSelected: "#12253A"

    // Bordures
    readonly property color border: "#182332"
    readonly property color borderHover: "#29415C"
    readonly property color borderSelected: "#2AA7FF"

    // Couleurs de texte
    readonly property color textPrimary: "#F0F3F7"
    readonly property color textSecondary: "#7F8A99"
    readonly property color textMuted: "#4F5968"

    // Couleur principale OmegaOS
    readonly property color accent: "#2AA7FF"
    readonly property color accentSoft: "#12324D"

    // États
    readonly property color success: "#49D17D"
    readonly property color successBackground: "#10271D"
    readonly property color successBorder: "#245E3D"

    readonly property color warning: "#F2B84B"
    readonly property color warningBackground: "#30240E"

    readonly property color danger: "#FF5B64"
    readonly property color dangerBackground: "#321316"

    readonly property color disconnected: "#7F8A99"

    // Dimensions
    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 12
    readonly property int radiusLarge: 18

    readonly property int borderWidth: 1

    // Espacements
    readonly property int spacingSmall: 8
    readonly property int spacingNormal: 12
    readonly property int spacingMedium: 16
    readonly property int spacingLarge: 24
    readonly property int pageMargin: 28

    // Typographie
    readonly property int fontSmall: 12
    readonly property int fontNormal: 14
    readonly property int fontMedium: 16
    readonly property int fontLarge: 20
    readonly property int fontTitle: 32
}
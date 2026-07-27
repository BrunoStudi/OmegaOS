pragma Singleton

import QtQuick

QtObject {
    // Arrière-plans
    readonly property color background: "#05070B"
    readonly property color surface: "#0B1018"
    readonly property color surfaceAlternative: "#0D141E"
    readonly property color surfaceHover: "#101824"
    readonly property color surfaceSelected: "#12253A"

    // Bordures
    readonly property color border: "#182332"
    readonly property color borderHover: "#29415C"
    readonly property color borderSelected: "#2AA7FF"

    // Textes
    readonly property color textPrimary: "#F0F3F7"
    readonly property color textSecondary: "#7F8A99"
    readonly property color textMuted: "#4F5968"
    readonly property color textDisabled: "#343C48"

    // Couleur principale OmegaOS
    readonly property color accent: "#2AA7FF"
    readonly property color accentHover: "#59BAFF"
    readonly property color accentSoft: "#12324D"

    // États
    readonly property color success: "#49D17D"
    readonly property color successBackground: "#10271D"
    readonly property color successBorder: "#245E3D"

    readonly property color warning: "#F2B84B"
    readonly property color warningBackground: "#30240E"
    readonly property color warningBorder: "#6A4C17"

    readonly property color danger: "#FF5B64"
    readonly property color dangerBackground: "#321316"
    readonly property color dangerBorder: "#6A272C"

    readonly property color disconnected: "#7F8A99"

    // Rayons
    readonly property int radiusSmall: 8
    readonly property int radiusMedium: 12
    readonly property int radiusLarge: 18
    readonly property int radiusRound: 999

    // Bordures
    readonly property int borderWidth: 1

    // Espacements
    readonly property int spacingTiny: 4
    readonly property int spacingSmall: 8
    readonly property int spacingNormal: 12
    readonly property int spacingMedium: 16
    readonly property int spacingLarge: 24
    readonly property int spacingExtraLarge: 32

    readonly property int pageMargin: 28

    // Typographie
    readonly property int fontTiny: 11
    readonly property int fontSmall: 12
    readonly property int fontNormal: 14
    readonly property int fontMedium: 16
    readonly property int fontLarge: 20
    readonly property int fontSubtitle: 24
    readonly property int fontTitle: 32

    // Dimensions principales
    readonly property int topBarHeight: 68
    readonly property int navigationWidth: 230
    readonly property int statusBarHeight: 34
    readonly property int navigationItemHeight: 54

    // Animations
    readonly property int animationFast: 120
    readonly property int animationNormal: 180
    readonly property int animationSlow: 280
}
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Rectangle {
    id: root

    property string statusMessage: "Système initialisé"

    /*
     * 0 : aucune alerte forcée
     * 1 : carburant faible
     * 2 : batterie faible
     * 3 : température élevée
     */
    property int demoAlertIndex: 0

    /*
     * Permet d'acquitter visuellement une alerte.
     * Une nouvelle variation de l'état véhicule la réactivera plus tard
     * lorsque nous connecterons un véritable gestionnaire d'alertes.
     */
    property bool alertAcknowledged: false

    signal pageRequested(int pageIndex)

    color: Theme.background

    readonly property bool realTemperatureAlert:
        canBusViewModel.connected
        && canBusViewModel.coolant_temperature >= 95

    readonly property bool realBatteryAlert:
        canBusViewModel.connected
        && canBusViewModel.battery_voltage < 12.3

    readonly property bool realFuelAlert:
        canBusViewModel.connected
        && canBusViewModel.fuel_level <= 20

    readonly property bool hasRealAlert:
        realTemperatureAlert
        || realBatteryAlert
        || realFuelAlert

    readonly property bool hasDemoAlert:
        demoAlertIndex > 0

    readonly property bool alertActive:
        !alertAcknowledged
        && (hasRealAlert || hasDemoAlert)

    readonly property string alertSeverity: {
        if (demoAlertIndex === 3) {
            return "critical"
        }

        if (demoAlertIndex === 2) {
            return "critical"
        }

        if (demoAlertIndex === 1) {
            return "warning"
        }

        if (realTemperatureAlert
                && canBusViewModel.coolant_temperature >= 105) {
            return "critical"
        }

        if (realBatteryAlert
                && canBusViewModel.battery_voltage < 11.8) {
            return "critical"
        }

        return alertActive ? "warning" : "info"
    }

    readonly property string alertTitle: {
        if (demoAlertIndex === 3) {
            return "Température moteur élevée"
        }

        if (demoAlertIndex === 2) {
            return "Tension batterie critique"
        }

        if (demoAlertIndex === 1) {
            return "Niveau de carburant faible"
        }

        if (realTemperatureAlert) {
            return "Température moteur élevée"
        }

        if (realBatteryAlert) {
            return "Tension batterie faible"
        }

        if (realFuelAlert) {
            return "Niveau de carburant faible"
        }

        return "Système opérationnel"
    }

    readonly property string alertMessage: {
        if (demoAlertIndex === 3) {
            return "La température moteur a dépassé 105 °C. "
                   + "Arrêtez le véhicule dès que possible."
        }

        if (demoAlertIndex === 2) {
            return "La tension est inférieure à 11,8 V. "
                   + "Vérifiez la batterie et le circuit de charge."
        }

        if (demoAlertIndex === 1) {
            return "Le niveau de carburant est inférieur à 10 %. "
                   + "Un ravitaillement est conseillé."
        }

        if (realTemperatureAlert) {
            return "Température mesurée : "
                   + canBusViewModel.coolant_temperature.toFixed(1)
                   + " °C."
        }

        if (realBatteryAlert) {
            return "Tension mesurée : "
                   + canBusViewModel.battery_voltage.toFixed(2)
                   + " V."
        }

        if (realFuelAlert) {
            return "Carburant restant : "
                   + canBusViewModel.fuel_level.toFixed(1)
                   + " %."
        }

        return "Aucune alerte active. Tous les systèmes "
               + "fonctionnent normalement."
    }

    readonly property string alertIcon: {
        if (!alertActive) {
            return "✓"
        }

        if (demoAlertIndex === 1 || realFuelAlert) {
            return "⛽"
        }

        if (demoAlertIndex === 2 || realBatteryAlert) {
            return "⚡"
        }

        return "!"
    }

    function selectNextDemoAlert() {
        demoAlertIndex = (demoAlertIndex + 1) % 4
        alertAcknowledged = false
    }

    /*
     * Une modification des valeurs réelles autorise une future
     * réapparition des alertes après acquittement.
     */
    Connections {
        target: canBusViewModel

        function onDataChanged() {
            if (!root.hasRealAlert && root.demoAlertIndex === 0) {
                root.alertAcknowledged = false
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.pageMargin

        spacing: Theme.spacingMedium

        /*
         * En-tête
         */
        RowLayout {
            Layout.fillWidth: true

            spacing: Theme.spacingMedium

            ColumnLayout {
                spacing: Theme.spacingTiny

                Text {
                    text: "Tableau de bord"
                    color: Theme.textPrimary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontTitle
                    font.bold: true
                }

                Text {
                    text: "Données générales du véhicule et du système"
                    color: Theme.textSecondary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontMedium
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                id: testAlertButton

                text: root.demoAlertIndex === 0
                      ? "Tester une alerte"
                      : root.demoAlertIndex === 1
                        ? "Tester batterie"
                        : root.demoAlertIndex === 2
                          ? "Tester température"
                          : "Terminer le test"

                implicitWidth: 170
                implicitHeight: 38

                onClicked: {
                    root.selectNextDemoAlert()
                }

                contentItem: Text {
                    text: testAlertButton.text
                    color: Theme.textPrimary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontSmall
                    font.bold: true

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    radius: Theme.radiusSmall
                    color: Theme.surfaceAlternative

                    border.width: Theme.borderWidth
                    border.color: root.demoAlertIndex > 0
                                  ? Theme.warningBorder
                                  : Theme.borderHover
                }
            }

            Rectangle {
                implicitWidth: engineStatusRow.implicitWidth + 28
                implicitHeight: 38

                radius: 19

                color: canBusViewModel.engine_running
                       ? Theme.successBackground
                       : Theme.surfaceAlternative

                border.width: Theme.borderWidth

                border.color: canBusViewModel.engine_running
                              ? Theme.successBorder
                              : Theme.border

                RowLayout {
                    id: engineStatusRow

                    anchors.centerIn: parent
                    spacing: Theme.spacingSmall

                    Rectangle {
                        implicitWidth: 10
                        implicitHeight: 10

                        radius: 5

                        color: canBusViewModel.engine_running
                               ? Theme.success
                               : Theme.disconnected

                        SequentialAnimation on opacity {
                            running: canBusViewModel.engine_running
                            loops: Animation.Infinite

                            NumberAnimation {
                                from: 1.0
                                to: 0.4
                                duration: 900
                            }

                            NumberAnimation {
                                from: 0.4
                                to: 1.0
                                duration: 900
                            }
                        }
                    }

                    Text {
                        text: canBusViewModel.engine_running
                              ? "MOTEUR EN MARCHE"
                              : "MOTEUR ARRÊTÉ"

                        color: canBusViewModel.engine_running
                               ? Theme.success
                               : Theme.textSecondary

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontNormal
                        font.bold: true
                    }
                }
            }

            Rectangle {
                implicitWidth: canStatusRow.implicitWidth + 28
                implicitHeight: 38

                radius: 19

                color: canBusViewModel.connected
                       ? Theme.accentSoft
                       : Theme.surfaceAlternative

                border.width: Theme.borderWidth

                border.color: canBusViewModel.connected
                              ? Theme.borderSelected
                              : Theme.border

                RowLayout {
                    id: canStatusRow

                    anchors.centerIn: parent
                    spacing: Theme.spacingSmall

                    Rectangle {
                        implicitWidth: 10
                        implicitHeight: 10

                        radius: 5

                        color: canBusViewModel.connected
                               ? Theme.accent
                               : Theme.disconnected
                    }

                    Text {
                        text: canBusViewModel.connected
                              ? "CAN "
                                + canBusViewModel.display_mode
                                    .toUpperCase()
                              : "CAN DÉCONNECTÉ"

                        color: canBusViewModel.connected
                               ? Theme.accent
                               : Theme.textSecondary

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontNormal
                        font.bold: true
                    }
                }
            }
        }

        /*
         * Bandeau d'alerte prioritaire
         */
        VehicleAlertBanner {
            Layout.fillWidth: true

            active: root.alertActive
            severity: root.alertSeverity
            title: root.alertTitle
            message: root.alertMessage
            iconText: root.alertIcon

            onAcknowledged: {
                root.alertAcknowledged = true
            }
        }

        /*
         * Mesures principales
         */
        GridLayout {
            Layout.fillWidth: true

            columns: 3

            columnSpacing: Theme.spacingMedium
            rowSpacing: Theme.spacingMedium

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 128

                title: "VITESSE"

                value: canBusViewModel.connected
                       ? canBusViewModel.vehicle_speed
                            .toFixed(0) + " km/h"
                       : "-- km/h"

                subtitle: canBusViewModel.connected
                          ? "Donnée véhicule en temps réel"
                          : "Bus CAN déconnecté"

                accentColor: Theme.accent

                valueColor: canBusViewModel.connected
                            ? Theme.textPrimary
                            : Theme.textSecondary
            }

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 128

                title: "RÉGIME MOTEUR"

                value: canBusViewModel.connected
                       ? canBusViewModel.engine_rpm
                            .toString() + " tr/min"
                       : "-- tr/min"

                subtitle: canBusViewModel.engine_running
                          ? "Moteur en fonctionnement"
                          : "Moteur arrêté"

                accentColor: canBusViewModel.engine_rpm >= 5000
                             ? Theme.danger
                             : canBusViewModel.engine_rpm >= 3500
                               ? Theme.warning
                               : Theme.accent

                valueColor: canBusViewModel.engine_rpm >= 5000
                            ? Theme.danger
                            : Theme.textPrimary
            }

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 128

                title: "TEMPÉRATURE MOTEUR"

                value: canBusViewModel.connected
                       ? canBusViewModel.coolant_temperature
                            .toFixed(1) + " °C"
                       : "-- °C"

                subtitle: {
                    if (!canBusViewModel.connected) {
                        return "Bus CAN déconnecté"
                    }

                    if (canBusViewModel.coolant_temperature >= 105) {
                        return "Température critique"
                    }

                    if (canBusViewModel.coolant_temperature >= 95) {
                        return "Température élevée"
                    }

                    if (canBusViewModel.coolant_temperature < 70) {
                        return "Moteur en chauffe"
                    }

                    return "Température normale"
                }

                accentColor:
                    canBusViewModel.coolant_temperature >= 105
                    ? Theme.danger
                    : canBusViewModel.coolant_temperature >= 95
                      ? Theme.warning
                      : Theme.success

                valueColor:
                    canBusViewModel.coolant_temperature >= 105
                    ? Theme.danger
                    : canBusViewModel.coolant_temperature >= 95
                      ? Theme.warning
                      : Theme.textPrimary
            }
        }

        GridLayout {
            Layout.fillWidth: true

            columns: 3

            columnSpacing: Theme.spacingMedium
            rowSpacing: Theme.spacingMedium

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 116

                title: "TENSION BATTERIE"

                value: canBusViewModel.connected
                       ? canBusViewModel.battery_voltage
                            .toFixed(2) + " V"
                       : "-- V"

                subtitle: {
                    if (!canBusViewModel.connected) {
                        return "Bus CAN déconnecté"
                    }

                    if (canBusViewModel.battery_voltage < 11.8) {
                        return "Tension batterie critique"
                    }

                    if (canBusViewModel.battery_voltage < 12.3) {
                        return "Batterie faible"
                    }

                    return canBusViewModel.engine_running
                           ? "Alternateur en fonctionnement"
                           : "Tension au repos"
                }

                accentColor:
                    canBusViewModel.battery_voltage < 11.8
                    ? Theme.danger
                    : canBusViewModel.battery_voltage < 12.3
                      ? Theme.warning
                      : Theme.success
            }

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 116

                title: "CARBURANT"

                value: canBusViewModel.connected
                       ? canBusViewModel.fuel_level
                            .toFixed(1) + " %"
                       : "-- %"

                subtitle: {
                    if (!canBusViewModel.connected) {
                        return "Bus CAN déconnecté"
                    }

                    if (canBusViewModel.fuel_level <= 10) {
                        return "Réserve de carburant"
                    }

                    if (canBusViewModel.fuel_level <= 20) {
                        return "Niveau faible"
                    }

                    return "Niveau suffisant"
                }

                accentColor:
                    canBusViewModel.fuel_level <= 10
                    ? Theme.danger
                    : canBusViewModel.fuel_level <= 20
                      ? Theme.warning
                      : Theme.accent
            }

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 116

                title: "RÉSEAU CAN"
                value: canBusViewModel.connection_status

                subtitle: canBusViewModel.connected
                          ? canBusViewModel.frames_per_second
                            + " trames/s · "
                            + canBusViewModel.formatted_bitrate
                          : canBusViewModel.display_mode

                accentColor: canBusViewModel.connected
                             ? Theme.success
                             : Theme.disconnected

                valueColor: canBusViewModel.connected
                            ? Theme.success
                            : Theme.textSecondary

                interactive: true

                onClicked: {
                    root.pageRequested(2)
                }
            }
        }

        /*
         * Activité CAN récente
         */
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: Theme.radiusMedium
            color: Theme.surface

            border.width: Theme.borderWidth
            border.color: Theme.border

            RowLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingLarge

                spacing: Theme.spacingMedium

                ColumnLayout {
                    Layout.fillWidth: true

                    spacing: Theme.spacingTiny

                    Text {
                        text: "Activité récente"
                        color: Theme.textPrimary

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontLarge
                        font.bold: true
                    }

                    Text {
                        text: canBusViewModel.connected
                              ? canBusViewModel.last_frame
                              : "Connecte le bus CAN pour recevoir les données."

                        color: canBusViewModel.connected
                               ? Theme.accent
                               : Theme.textSecondary

                        font.family: canBusViewModel.connected
                                     ? "Consolas"
                                     : "Segoe UI"

                        font.pixelSize: Theme.fontMedium
                        font.bold: canBusViewModel.connected
                    }

                    Text {
                        text: canBusViewModel.connected
                              ? canBusViewModel.frames_received
                                + " trames reçues depuis la connexion"
                              : "Le simulateur reproduira un trajet complet."

                        color: Theme.textMuted

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontSmall
                    }
                }

                Rectangle {
                    implicitWidth: activityModeText.implicitWidth + 22
                    implicitHeight: 28

                    radius: 14

                    color: canBusViewModel.connected
                           ? Theme.successBackground
                           : Theme.surfaceAlternative

                    border.width: Theme.borderWidth

                    border.color: canBusViewModel.connected
                                  ? Theme.successBorder
                                  : Theme.border

                    Text {
                        id: activityModeText

                        anchors.centerIn: parent

                        text: canBusViewModel.connected
                              ? "TEMPS RÉEL"
                              : "INACTIF"

                        color: canBusViewModel.connected
                               ? Theme.success
                               : Theme.textMuted

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontTiny
                        font.bold: true
                    }
                }
            }
        }
    }
}
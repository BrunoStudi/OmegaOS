import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Rectangle {
    id: root

    property string statusMessage: "Système initialisé"

    signal pageRequested(int pageIndex)

    color: Theme.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.pageMargin

        spacing: Theme.spacingMedium

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

                text: {
                    switch (canBusViewModel.demo_alert_index) {
                    case 0:
                        return "Tester une alerte"
                    case 1:
                        return "Tester batterie"
                    case 2:
                        return "Tester température"
                    default:
                        return "Terminer le test"
                    }
                }

                implicitWidth: 170
                implicitHeight: 38

                onClicked: {
                    canBusViewModel.next_demo_alert()
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

                    border.color:
                        canBusViewModel.demo_alert_index > 0
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

        VehicleAlertBanner {
            Layout.fillWidth: true

            active: canBusViewModel.alert_active
            severity: canBusViewModel.alert_severity
            title: canBusViewModel.alert_title
            message: canBusViewModel.alert_message
            iconText: canBusViewModel.alert_icon

            onAcknowledged: {
                canBusViewModel.acknowledge_current_alert()
            }
        }

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

                accentColor:
                    canBusViewModel.engine_rpm >= 5000
                    ? Theme.danger
                    : canBusViewModel.engine_rpm >= 3500
                      ? Theme.warning
                      : Theme.accent
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

                subtitle: canBusViewModel.engine_running
                          ? "Alternateur en fonctionnement"
                          : "Tension au repos"

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

                subtitle: canBusViewModel.fuel_level <= 10
                          ? "Réserve de carburant"
                          : canBusViewModel.fuel_level <= 20
                            ? "Niveau faible"
                            : "Niveau suffisant"

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
                    implicitWidth: alertCounterText.implicitWidth + 22
                    implicitHeight: 28

                    radius: 14

                    color:
                        canBusViewModel.unacknowledged_alert_count > 0
                        ? Theme.warningBackground
                        : Theme.successBackground

                    border.width: Theme.borderWidth

                    border.color:
                        canBusViewModel.unacknowledged_alert_count > 0
                        ? Theme.warningBorder
                        : Theme.successBorder

                    Text {
                        id: alertCounterText

                        anchors.centerIn: parent

                        text:
                            canBusViewModel.unacknowledged_alert_count
                            + " ALERTE(S) NON ACQUITTÉE(S)"

                        color:
                            canBusViewModel.unacknowledged_alert_count > 0
                            ? Theme.warning
                            : Theme.success

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontTiny
                        font.bold: true
                    }
                }
            }
        }
    }
}
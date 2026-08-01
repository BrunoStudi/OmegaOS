import QtQuick
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

        /*
         * En-tête du tableau de bord
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

            /*
             * État du moteur
             */
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

            /*
             * État du CAN
             */
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
         * Première rangée :
         * vitesse, régime et température moteur
         */
        GridLayout {
            Layout.fillWidth: true

            columns: 3

            columnSpacing: Theme.spacingMedium
            rowSpacing: Theme.spacingMedium

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 135

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
                Layout.preferredHeight: 135

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
                Layout.preferredHeight: 135

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

        /*
         * Deuxième rangée :
         * batterie, carburant et état du réseau CAN
         */
        GridLayout {
            Layout.fillWidth: true

            columns: 3

            columnSpacing: Theme.spacingMedium
            rowSpacing: Theme.spacingMedium

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 122

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

                    if (canBusViewModel.engine_running) {
                        return "Alternateur en fonctionnement"
                    }

                    return "Tension au repos"
                }

                accentColor:
                    canBusViewModel.battery_voltage < 11.8
                    ? Theme.danger
                    : canBusViewModel.battery_voltage < 12.3
                      ? Theme.warning
                      : Theme.success

                valueColor:
                    canBusViewModel.battery_voltage < 11.8
                    ? Theme.danger
                    : Theme.textPrimary
            }

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 122

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

                valueColor:
                    canBusViewModel.fuel_level <= 10
                    ? Theme.danger
                    : Theme.textPrimary
            }

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 122

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
         * Zone d'activité récente
         */
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true

            radius: Theme.radiusMedium
            color: Theme.surface

            border.width: Theme.borderWidth
            border.color: Theme.border

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingLarge

                spacing: Theme.spacingNormal

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
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
                                  ? canBusViewModel.frames_received
                                    + " trames reçues depuis la connexion"
                                  : "Aucune activité CAN"

                            color: Theme.textMuted

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontSmall
                        }
                    }

                    Item {
                        Layout.fillWidth: true
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

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1

                    color: Theme.border
                }

                Item {
                    Layout.fillHeight: true
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter

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
                    Layout.alignment: Qt.AlignHCenter

                    text: canBusViewModel.connected
                          ? "Dernière trame reçue à "
                            + canBusViewModel.last_frame_time
                          : "Le simulateur reproduira un trajet complet."

                    color: Theme.textMuted

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontNormal
                }

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }
}
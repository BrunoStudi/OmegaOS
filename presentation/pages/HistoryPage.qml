import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../components"
import "../theme"

Rectangle {
    id: root

    color: Theme.background

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Theme.pageMargin

        spacing: Theme.spacingMedium

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: Theme.spacingTiny

                Text {
                    text: "Historique"
                    color: Theme.textPrimary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontTitle
                    font.bold: true
                }

                Text {
                    text: "Événements et données enregistrés par OmegaOS"
                    color: Theme.textSecondary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontMedium
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Rectangle {
                implicitWidth: historyStatusRow.implicitWidth + 26
                implicitHeight: 36

                radius: 18

                color: canBusViewModel.connected
                       ? Theme.successBackground
                       : Theme.surfaceAlternative

                border.width: Theme.borderWidth

                border.color: canBusViewModel.connected
                              ? Theme.successBorder
                              : Theme.border

                RowLayout {
                    id: historyStatusRow

                    anchors.centerIn: parent
                    spacing: Theme.spacingSmall

                    Rectangle {
                        implicitWidth: 9
                        implicitHeight: 9
                        radius: 5

                        color: canBusViewModel.connected
                               ? Theme.success
                               : Theme.disconnected
                    }

                    Text {
                        text: canBusViewModel.connected
                              ? "ENREGISTREMENT ACTIF"
                              : "CAN DÉCONNECTÉ"

                        color: canBusViewModel.connected
                               ? Theme.success
                               : Theme.textSecondary

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontSmall
                        font.bold: true
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true

            columns: 4
            columnSpacing: Theme.spacingMedium
            rowSpacing: Theme.spacingMedium

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 112

                title: "TRAMES REÇUES"
                value: canBusViewModel.frames_received.toString()

                subtitle: canBusViewModel.connected
                          ? canBusViewModel.frames_per_second
                            + " trames/s actuellement"
                          : "Réception interrompue"

                accentColor: Theme.accent
            }

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 112

                title: "MODE D’ACQUISITION"
                value: canBusViewModel.display_mode

                subtitle: canBusViewModel.mode === "simulation"
                          ? "Simulateur de véhicule"
                          : canBusViewModel.interface_name
                            + " · "
                            + canBusViewModel.formatted_bitrate

                accentColor: Theme.warning
            }

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 112

                title: "ALERTES ENREGISTRÉES"
                value: canBusViewModel.alert_count.toString()

                subtitle: "Journal véhicule"

                accentColor: Theme.warning
            }

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 112

                title: "NON ACQUITTÉES"

                value:
                    canBusViewModel.unacknowledged_alert_count
                        .toString()

                subtitle:
                    canBusViewModel.unacknowledged_alert_count > 0
                    ? "Vérification nécessaire"
                    : "Aucune action requise"

                accentColor:
                    canBusViewModel.unacknowledged_alert_count > 0
                    ? Theme.danger
                    : Theme.success
            }
        }

        TabBar {
            id: historyTabs

            Layout.fillWidth: true
            Layout.preferredHeight: 42

            TabButton {
                text: "Trames CAN"
            }

            TabButton {
                text: "Alertes véhicule"
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: historyTabs.currentIndex

            Rectangle {
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

                        Text {
                            text: "Historique des trames CAN"
                            color: Theme.textPrimary

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontLarge
                            font.bold: true
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            text: canBusViewModel.display_paused
                                  ? "Reprendre"
                                  : "Pause"

                            enabled: canBusViewModel.connected

                            onClicked: {
                                canBusViewModel.toggle_display_pause()
                            }
                        }

                        Button {
                            text: "Vider"

                            enabled:
                                canBusViewModel.frames_received > 0

                            onClicked: {
                                canBusViewModel.clear_history()
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        radius: Theme.radiusSmall
                        color: "#030508"

                        border.width: Theme.borderWidth
                        border.color: Theme.border

                        ScrollView {
                            anchors.fill: parent
                            clip: true

                            TextArea {
                                text: canBusViewModel.history_text

                                readOnly: true
                                selectByMouse: true
                                wrapMode: TextEdit.NoWrap

                                color: Theme.textSecondary

                                font.family: "Consolas"
                                font.pixelSize: Theme.fontSmall

                                padding: Theme.spacingNormal

                                background: Rectangle {
                                    color: "transparent"
                                }
                            }
                        }
                    }
                }
            }

            Rectangle {
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
                                text: "Historique des alertes véhicule"
                                color: Theme.textPrimary

                                font.family: "Segoe UI"
                                font.pixelSize: Theme.fontLarge
                                font.bold: true
                            }

                            Text {
                                text:
                                    canBusViewModel.alert_count
                                    + " événement(s) enregistré(s)"

                                color: Theme.textMuted

                                font.family: "Segoe UI"
                                font.pixelSize: Theme.fontSmall
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            id: clearAlertsButton

                            text: "Vider les alertes"

                            enabled:
                                canBusViewModel.alert_count > 0

                            implicitWidth: 140
                            implicitHeight: 34

                            onClicked: {
                                canBusViewModel.clear_alert_history()
                            }

                            contentItem: Text {
                                text: clearAlertsButton.text

                                color: clearAlertsButton.enabled
                                       ? Theme.textPrimary
                                       : Theme.textDisabled

                                font.family: "Segoe UI"
                                font.pixelSize: Theme.fontSmall
                                font.bold: true

                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            background: Rectangle {
                                radius: Theme.radiusSmall

                                color: clearAlertsButton.enabled
                                       ? Theme.dangerBackground
                                       : Theme.surfaceAlternative

                                border.width: Theme.borderWidth

                                border.color: clearAlertsButton.enabled
                                              ? Theme.dangerBorder
                                              : Theme.border
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1

                        color: Theme.border
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        radius: Theme.radiusSmall
                        color: "#030508"

                        border.width: Theme.borderWidth
                        border.color: Theme.border

                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 2

                            clip: true

                            TextArea {
                                text:
                                    canBusViewModel.alert_history_text

                                readOnly: true
                                selectByMouse: true
                                wrapMode: TextEdit.NoWrap

                                color: Theme.textSecondary

                                selectionColor: Theme.accentSoft
                                selectedTextColor: Theme.textPrimary

                                font.family: "Consolas"
                                font.pixelSize: Theme.fontSmall

                                leftPadding: Theme.spacingNormal
                                rightPadding: Theme.spacingNormal
                                topPadding: Theme.spacingNormal
                                bottomPadding: Theme.spacingNormal

                                background: Rectangle {
                                    color: "transparent"
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text:
                                canBusViewModel.unacknowledged_alert_count
                                + " alerte(s) non acquittée(s)"

                            color:
                                canBusViewModel
                                    .unacknowledged_alert_count > 0
                                ? Theme.warning
                                : Theme.success

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontSmall
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text:
                                "Limite actuelle : 200 événements"

                            color: Theme.textMuted

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontSmall
                        }
                    }
                }
            }
        }
    }
}
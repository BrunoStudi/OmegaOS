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

        /*
         * En-tête
         */
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

        /*
         * Résumé
         */
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

                title: "DERNIÈRE TRAME"

                value: canBusViewModel.last_frame_id

                subtitle: canBusViewModel.last_frame_time

                accentColor: Theme.success
            }

            InfoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 112

                title: "ALERTES VÉHICULE"

                value: "0"

                subtitle: "Journal des alertes à venir"

                accentColor: Theme.disconnected
            }
        }

        /*
         * Sélection de la catégorie d’historique
         */
        TabBar {
            id: historyTabs

            Layout.fillWidth: true
            Layout.preferredHeight: 42

            background: Rectangle {
                color: Theme.surface

                radius: Theme.radiusSmall

                border.width: Theme.borderWidth
                border.color: Theme.border
            }

            TabButton {
                id: canHistoryTab

                text: "Trames CAN"

                contentItem: Text {
                    text: canHistoryTab.text

                    color: historyTabs.currentIndex === 0
                           ? Theme.accent
                           : Theme.textSecondary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontNormal
                    font.bold: historyTabs.currentIndex === 0

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: historyTabs.currentIndex === 0
                           ? Theme.accentSoft
                           : "transparent"

                    radius: Theme.radiusSmall

                    border.width: historyTabs.currentIndex === 0
                                  ? Theme.borderWidth
                                  : 0

                    border.color: Theme.borderSelected
                }
            }

            TabButton {
                id: alertHistoryTab

                text: "Alertes véhicule"

                contentItem: Text {
                    text: alertHistoryTab.text

                    color: historyTabs.currentIndex === 1
                           ? Theme.accent
                           : Theme.textSecondary

                    font.family: "Segoe UI"
                    font.pixelSize: Theme.fontNormal
                    font.bold: historyTabs.currentIndex === 1

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                background: Rectangle {
                    color: historyTabs.currentIndex === 1
                           ? Theme.accentSoft
                           : "transparent"

                    radius: Theme.radiusSmall

                    border.width: historyTabs.currentIndex === 1
                                  ? Theme.borderWidth
                                  : 0

                    border.color: Theme.borderSelected
                }
            }
        }

        /*
         * Contenu des onglets
         */
        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: historyTabs.currentIndex

            /*
             * Historique CAN
             */
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
                                text: "Historique des trames CAN"

                                color: Theme.textPrimary

                                font.family: "Segoe UI"
                                font.pixelSize: Theme.fontLarge
                                font.bold: true
                            }

                            Text {
                                text: canBusViewModel.display_paused
                                      ? "Affichage actuellement figé"
                                      : "Les 200 dernières trames reçues"

                                color: canBusViewModel.display_paused
                                       ? Theme.warning
                                       : Theme.textMuted

                                font.family: "Segoe UI"
                                font.pixelSize: Theme.fontSmall
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Button {
                            id: pauseHistoryButton

                            text: canBusViewModel.display_paused
                                  ? "Reprendre"
                                  : "Pause"

                            implicitWidth: 105
                            implicitHeight: 34

                            enabled: canBusViewModel.connected

                            onClicked: {
                                canBusViewModel.toggle_display_pause()
                            }

                            contentItem: Text {
                                text: pauseHistoryButton.text

                                color: pauseHistoryButton.enabled
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

                                color: canBusViewModel.display_paused
                                       ? Theme.warningBackground
                                       : Theme.accentSoft

                                border.width: Theme.borderWidth

                                border.color: canBusViewModel.display_paused
                                              ? Theme.warningBorder
                                              : Theme.borderSelected
                            }
                        }

                        Button {
                            id: clearHistoryButton

                            text: "Vider"

                            implicitWidth: 90
                            implicitHeight: 34

                            enabled: canBusViewModel.frames_received > 0

                            onClicked: {
                                canBusViewModel.clear_history()
                            }

                            contentItem: Text {
                                text: clearHistoryButton.text

                                color: clearHistoryButton.enabled
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

                                color: clearHistoryButton.enabled
                                       ? Theme.dangerBackground
                                       : Theme.surfaceAlternative

                                border.width: Theme.borderWidth

                                border.color: clearHistoryButton.enabled
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

                        border.color: canBusViewModel.display_paused
                                      ? Theme.warningBorder
                                      : Theme.border

                        Behavior on border.color {
                            ColorAnimation {
                                duration: Theme.animationNormal
                            }
                        }

                        ScrollView {
                            anchors.fill: parent
                            anchors.margins: 2

                            clip: true

                            TextArea {
                                text: canBusViewModel.history_text

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
                            text: canBusViewModel.display_paused
                                  ? "La réception continue en arrière-plan."
                                  : canBusViewModel.status_message

                            color: canBusViewModel.display_paused
                                   ? Theme.warning
                                   : Theme.textSecondary

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontSmall
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: canBusViewModel.frames_received
                                  + " trames reçues"

                            color: Theme.textMuted

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontSmall
                        }
                    }
                }
            }

            /*
             * Futur historique des alertes
             */
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
                                text: "Alertes, avertissements et événements importants"

                                color: Theme.textMuted

                                font.family: "Segoe UI"
                                font.pixelSize: Theme.fontSmall
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            implicitWidth: comingSoonText.implicitWidth + 22
                            implicitHeight: 28

                            radius: 14

                            color: Theme.accentSoft

                            border.width: Theme.borderWidth
                            border.color: Theme.borderSelected

                            Text {
                                id: comingSoonText

                                anchors.centerIn: parent

                                text: "PRÊT À ÊTRE CONNECTÉ"

                                color: Theme.accent

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

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter

                        implicitWidth: 72
                        implicitHeight: 72

                        radius: 36

                        color: Theme.accentSoft

                        border.width: Theme.borderWidth
                        border.color: Theme.borderSelected

                        Text {
                            anchors.centerIn: parent

                            text: "!"

                            color: Theme.accent

                            font.family: "Segoe UI"
                            font.pixelSize: 34
                            font.bold: true
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter

                        text: "Aucune alerte enregistrée"

                        color: Theme.textPrimary

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontLarge
                        font.bold: true
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter

                        text: "Les alertes simulées et réelles seront conservées ici."

                        color: Theme.textSecondary

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontNormal
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter

                        text: "La prochaine étape reliera le bandeau d’alerte "
                              + "du tableau de bord à ce journal."

                        color: Theme.textMuted

                        font.family: "Segoe UI"
                        font.pixelSize: Theme.fontSmall
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
}
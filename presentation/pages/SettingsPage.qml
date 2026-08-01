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

        spacing: Theme.spacingLarge

        ColumnLayout {
            spacing: Theme.spacingTiny

            Text {
                text: "Paramètres"

                color: Theme.textPrimary

                font.family: "Segoe UI"
                font.pixelSize: Theme.fontTitle
                font.bold: true
            }

            Text {
                text: "Configuration générale d’OmegaOS"

                color: Theme.textSecondary

                font.family: "Segoe UI"
                font.pixelSize: Theme.fontMedium
            }
        }

        Rectangle {
            Layout.fillWidth: true

            radius: Theme.radiusMedium
            color: Theme.surface

            border.width: Theme.borderWidth
            border.color: Theme.border

            implicitHeight: 390

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.spacingLarge

                spacing: Theme.spacingLarge

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        spacing: Theme.spacingTiny

                        Text {
                            text: "Synthèse vocale"

                            color: Theme.textPrimary

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontLarge
                            font.bold: true
                        }

                        Text {
                            text: "Annonces locales pour les alertes véhicule"

                            color: Theme.textMuted

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontSmall
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        implicitWidth: voiceStatusText.implicitWidth + 24
                        implicitHeight: 30

                        radius: 15

                        color: voiceViewModel.available
                               ? Theme.successBackground
                               : Theme.dangerBackground

                        border.width: Theme.borderWidth

                        border.color: voiceViewModel.available
                                      ? Theme.successBorder
                                      : Theme.dangerBorder

                        Text {
                            id: voiceStatusText

                            anchors.centerIn: parent

                            text: voiceViewModel.available
                                  ? "MOTEUR DISPONIBLE"
                                  : "INDISPONIBLE"

                            color: voiceViewModel.available
                                   ? Theme.success
                                   : Theme.danger

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

                RowLayout {
                    Layout.fillWidth: true

                    ColumnLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Activer les annonces"

                            color: Theme.textPrimary

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontNormal
                            font.bold: true
                        }

                        Text {
                            text: "OmegaOS annoncera uniquement "
                                  + "les nouvelles alertes importantes."

                            color: Theme.textMuted

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontSmall
                        }
                    }

                    Switch {
                        checked: voiceViewModel.enabled

                        enabled: voiceViewModel.available

                        onToggled: {
                            voiceViewModel.set_enabled(
                                checked
                            )
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSmall

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Volume"

                            color: Theme.textPrimary

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontNormal
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: Math.round(
                                voiceVolumeSlider.value * 100
                            ) + " %"

                            color: Theme.accent

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontNormal
                            font.bold: true
                        }
                    }

                    Slider {
                        id: voiceVolumeSlider

                        Layout.fillWidth: true

                        from: 0.0
                        to: 1.0
                        stepSize: 0.05

                        value: voiceViewModel.volume

                        enabled: voiceViewModel.available

                        onMoved: {
                            voiceViewModel.set_volume(
                                value
                            )
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingSmall

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "Vitesse de la voix"

                            color: Theme.textPrimary

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontNormal
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            text: voiceRateSlider.value
                                .toFixed(2)

                            color: Theme.accent

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontNormal
                            font.bold: true
                        }
                    }

                    Slider {
                        id: voiceRateSlider

                        Layout.fillWidth: true

                        from: -1.0
                        to: 1.0
                        stepSize: 0.05

                        value: voiceViewModel.rate

                        enabled: voiceViewModel.available

                        onMoved: {
                            voiceViewModel.set_rate(
                                value
                            )
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    spacing: Theme.spacingMedium

                    Button {
                        text: "Tester la voix"

                        enabled:
                            voiceViewModel.available
                            && voiceViewModel.enabled

                        onClicked: {
                            voiceViewModel.test_voice()
                        }
                    }

                    Button {
                        text: "Arrêter"

                        enabled:
                            voiceViewModel.available

                        onClicked: {
                            voiceViewModel.stop_voice()
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    ColumnLayout {
                        spacing: Theme.spacingTiny

                        Text {
                            text: voiceViewModel.engine_name

                            color: Theme.textSecondary

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontSmall

                            horizontalAlignment: Text.AlignRight
                        }

                        Text {
                            text: voiceViewModel.status_message

                            color: voiceViewModel.available
                                   ? Theme.success
                                   : Theme.danger

                            font.family: "Segoe UI"
                            font.pixelSize: Theme.fontSmall

                            horizontalAlignment: Text.AlignRight
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
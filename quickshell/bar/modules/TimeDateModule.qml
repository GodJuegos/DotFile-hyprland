// ~/.config/quickshell/bar/modules/TimeDateModule.qml
// Propósito: Isla central Liquid Glass que muestra la hora (con segundos) y la fecha.
// Se adapta automáticamente si la barra está en horizontal (Top/Bottom) o vertical (Left/Right).

import QtQuick
import "../../components"
import "../../services"

LiquidCapsule {
    id: root
    property bool isVertical: false
    accentGlowColor: ThemeService.accentCyan

    Loader {
        sourceComponent: root.isVertical ? verticalClock : horizontalClock
    }

    Component {
        id: horizontalClock
        Row {
            spacing: 10

            Row {
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4

                Text {
                    text: "󰥔"
                    font.family: ThemeService.iconFont
                    font.pixelSize: 15
                    color: ThemeService.accentCyan
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: DateTimeService.timeString
                    font.family: ThemeService.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Black
                    color: ThemeService.textPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: ":" + DateTimeService.seconds
                    font.family: ThemeService.monoFont
                    font.pixelSize: 11
                    font.bold: true
                    color: ThemeService.accentCyan
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                width: 1
                height: 14
                color: "#40ffffff"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: DateTimeService.dateString
                font.family: ThemeService.fontFamily
                font.pixelSize: 12
                font.bold: true
                color: ThemeService.textSecondary
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Component {
        id: verticalClock
        Column {
            spacing: 2

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: DateTimeService.hours
                font.family: ThemeService.fontFamily
                font.pixelSize: 13
                font.weight: Font.Black
                color: ThemeService.textPrimary
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: DateTimeService.minutes
                font.family: ThemeService.fontFamily
                font.pixelSize: 13
                font.weight: Font.Black
                color: ThemeService.accentCyan
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 14
                height: 1
                color: "#40ffffff"
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: DateTimeService.dayNumber
                font.family: ThemeService.fontFamily
                font.pixelSize: 11
                font.bold: true
                color: ThemeService.textSecondary
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: DateTimeService.monthShort
                font.family: ThemeService.fontFamily
                font.pixelSize: 9
                font.bold: true
                color: ThemeService.textMuted
            }
        }
    }
}

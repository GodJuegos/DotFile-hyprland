// ~/.config/quickshell/bar/modules/NetworkModule.qml
// Propósito: Isla flotante Liquid Glass para Internet (Cable Ethernet + Wi-Fi).
// - Al hacer clic sobre el icono/cápsula de Internet, abre la Cápsula Orbital de
//   Configuración de Red (NetworkPopup.qml), igual que en Serpantinum.
// - Muestra en la barra el icono, estado de red, tráfico en vivo (↓/↑) y acceso rápido a Test.

import QtQuick
import "../../components"
import "../../services"

LiquidCapsule {
    id: root
    property bool isVertical: false
    accentGlowColor: ThemeService.accentGreen
    activeHighlight: NetService.popupOpen

    // Al hacer clic en la cápsula de Internet, abre/cierra la Cápsula de Configuración Orbital
    onClicked: NetService.togglePopup()

    Loader {
        sourceComponent: root.isVertical ? verticalNet : horizontalNet
    }

    Component {
        id: horizontalNet
        Row {
            spacing: 10

            // Icono + Tipo de red (Cable / Wi-Fi)
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: NetService.netIcon
                    font.family: ThemeService.iconFont
                    font.pixelSize: 16
                    color: NetService.isConnected ? ThemeService.accentGreen : ThemeService.accentRed
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: NetService.connectionName
                    font.family: ThemeService.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    color: ThemeService.textPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Velocidad en tiempo real (↓ Descarga / ↑ Subida)
            Row {
                spacing: 6
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: "↓ " + NetService.downSpeedText
                    font.family: ThemeService.monoFont
                    font.pixelSize: 11
                    font.bold: true
                    color: ThemeService.accentCyan
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "↑ " + NetService.upSpeedText
                    font.family: ThemeService.monoFont
                    font.pixelSize: 11
                    color: ThemeService.textSecondary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Botón rápido de Speedtest o indicador de resultado
            Rectangle {
                id: testBtn
                height: 24
                width: testRow.implicitWidth + 14
                radius: 12
                anchors.verticalCenter: parent.verticalCenter
                color: NetService.testRunning
                    ? "#44ffd60a"
                    : (testMouse.containsMouse ? "#455ac8fa" : "#26ffffff")
                border.width: 1
                border.color: NetService.testRunning ? ThemeService.accentAmber : "#55ffffff"

                Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 150 } }

                Row {
                    id: testRow
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: NetService.testRunning ? "󱍸" : "󰓅"
                        font.family: ThemeService.iconFont
                        font.pixelSize: 13
                        color: NetService.testRunning ? ThemeService.accentAmber : ThemeService.accentCyan
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: NetService.lastTestMbps !== "" && !NetService.testRunning
                            ? NetService.lastTestMbps
                            : (NetService.testRunning ? "Midiendo..." : "Test")
                        font.family: ThemeService.fontFamily
                        font.pixelSize: 11
                        font.bold: true
                        color: ThemeService.textPrimary
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                MouseArea {
                    id: testMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NetService.runSpeedTest()
                }
            }
        }
    }

    Component {
        id: verticalNet
        Column {
            spacing: 4

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: NetService.netIcon
                font.family: ThemeService.iconFont
                font.pixelSize: 16
                color: NetService.isConnected ? ThemeService.accentGreen : ThemeService.accentRed
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "↓"
                font.family: ThemeService.monoFont
                font.pixelSize: 9
                font.bold: true
                color: ThemeService.accentCyan
            }
        }
    }
}

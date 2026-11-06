// ~/.config/quickshell/bar/modules/AudioModule.qml
// Propósito: Isla flotante Liquid Glass de Volumen y Salida de Audio.
// - Rueda del mouse: sube/baja el volumen de 5% en 5%
// - Clic derecho: silenciar / activar sonido (Mute)
// - Botón de ruta (o clic izquierdo en la píldora de salida): alterna entre
//   "Altavoz + Audíf." (Dual), "Altavoces", "Audífonos" y "HDMI TV", evitando
//   que PipeWire priorice solo los audífonos.

import QtQuick
import "../../components"
import "../../services"

LiquidCapsule {
    id: root
    property bool isVertical: false
    accentGlowColor: ThemeService.accentPurple

    onRightClicked: AudioService.toggleMute()
    onMiddleClicked: AudioService.cycleRoute()
    onWheelScrolled: wheel => {
        if (wheel.angleDelta.y > 0) AudioService.changeVolume(5);
        else if (wheel.angleDelta.y < 0) AudioService.changeVolume(-5);
    }

    Loader {
        sourceComponent: root.isVertical ? verticalAudio : horizontalAudio
    }

    Component {
        id: horizontalAudio
        Row {
            spacing: 8

            // Icono de volumen + porcentaje
            Row {
                spacing: 5
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    text: AudioService.routeIcon
                    font.family: ThemeService.iconFont
                    font.pixelSize: 16
                    color: AudioService.isMuted ? ThemeService.accentRed : ThemeService.accentPurple
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: AudioService.isMuted ? "Mute" : (AudioService.volumePercent + "%")
                    font.family: ThemeService.monoFont
                    font.pixelSize: 12
                    font.bold: true
                    color: AudioService.isMuted ? ThemeService.textMuted : ThemeService.textPrimary
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Selector rápido de salida (Altavoz + Audíf. / Altavoces / Audífonos / HDMI)
            Rectangle {
                height: 24
                width: routeText.implicitWidth + 14
                radius: 12
                anchors.verticalCenter: parent.verticalCenter
                color: routeMouse.containsMouse ? "#45bf5af2" : "#26ffffff"
                border.width: 1
                border.color: "#55ffffff"

                Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    id: routeText
                    anchors.centerIn: parent
                    text: AudioService.routeLabel
                    font.family: ThemeService.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    color: ThemeService.textPrimary
                }

                MouseArea {
                    id: routeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: AudioService.cycleRoute()
                }
            }
        }
    }

    Component {
        id: verticalAudio
        Column {
            spacing: 3

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: AudioService.routeIcon
                font.family: ThemeService.iconFont
                font.pixelSize: 16
                color: AudioService.isMuted ? ThemeService.accentRed : ThemeService.accentPurple
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: AudioService.volumePercent + "%"
                font.family: ThemeService.monoFont
                font.pixelSize: 10
                font.bold: true
                color: ThemeService.textPrimary
            }
        }
    }

    onClicked: {
        if (root.isVertical) AudioService.cycleRoute();
    }
}

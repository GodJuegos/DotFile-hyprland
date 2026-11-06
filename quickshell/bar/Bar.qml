// ~/.config/quickshell/bar/Bar.qml
// Propósito: Ventana principal de la barra modular de islas flotantes Liquid Glass
// y su Cápsula Orbital de Configuración de Red (NetworkPopup).
// Soporta las 4 posiciones de pantalla ("top", "bottom", "left", "right")
// y expone comandos IPC (`qs ipc call bar ...`) para controlarla desde teclado o terminal.

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "../services"
import "modules"
import "popups"

Scope {
    id: barScope

    IpcHandler {
        target: "bar"

        function setPosition(pos: string): void {
            ConfigService.setBarPosition(pos);
        }

        function cyclePosition(): void {
            ConfigService.cycleBarPosition();
        }

        function cycleAudio(): void {
            AudioService.cycleRoute();
        }

        function toggleNetwork(): void {
            NetService.togglePopup();
        }

        function speedtest(): void {
            NetService.runSpeedTest();
        }
    }

    // Ventana flotante de Configuración de Internet (Orbital Liquid Glass)
    NetworkPopup {}

    Variants {
        model: Quickshell.screens

        delegate: PanelWindow {
            id: barWindow
            required property var modelData
            screen: modelData

            readonly property string pos: ConfigService.barPosition
            readonly property bool isVertical: pos === "left" || pos === "right"
            readonly property int barThickness: ConfigService.barThickness
            readonly property int barMargin: ConfigService.barMargin
            readonly property int itemSpacing: ConfigService.barSpacing

            color: "transparent"
            WlrLayershell.namespace: "qs-liquid-bar"
            WlrLayershell.layer: WlrLayer.Top
            exclusiveZone: barThickness + barMargin

            anchors {
                top: pos === "top" || isVertical
                bottom: pos === "bottom" || isVertical
                left: pos === "left" || !isVertical
                right: pos === "right" || !isVertical
            }

            margins {
                top: pos === "top" ? barMargin : (isVertical ? barMargin : 0)
                bottom: pos === "bottom" ? barMargin : (isVertical ? barMargin : 0)
                left: pos === "left" ? barMargin : (!isVertical ? barMargin : 0)
                right: pos === "right" ? barMargin : (!isVertical ? barMargin : 0)
            }

            implicitHeight: isVertical ? 0 : barThickness
            implicitWidth: isVertical ? barThickness : 0

            // Contenedor Horizontal (cuando pos es "top" o "bottom")
            Item {
                id: horizontalContainer
                anchors.fill: parent
                visible: !barWindow.isVertical

                // Islas de la Izquierda: Workspaces + Ventana Activa
                Row {
                    id: leftGroup
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: barWindow.itemSpacing

                    WorkspacesModule {
                        visible: ConfigService.showWorkspaces
                        isVertical: false
                    }

                    FocusModule {
                        visible: ConfigService.showFocus
                        isVertical: false
                    }
                }

                // Isla Central: Hora y Fecha
                Row {
                    id: centerGroup
                    anchors.centerIn: parent
                    spacing: barWindow.itemSpacing

                    TimeDateModule {
                        visible: ConfigService.showTimeDate
                        isVertical: false
                    }
                }

                // Islas de la Derecha: Bandeja + Internet (clic abre cápsula orbital) + Volumen/Salidas + Batería opcional
                Row {
                    id: rightGroup
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: barWindow.itemSpacing

                    TrayModule {
                        isVertical: false
                    }

                    NetworkModule {
                        visible: ConfigService.showNetwork
                        isVertical: false
                    }

                    AudioModule {
                        visible: ConfigService.showAudio
                        isVertical: false
                    }

                    BatteryModule {
                        isVertical: false
                    }
                }
            }

            // Contenedor Vertical (cuando pos es "left" o "right")
            Item {
                id: verticalContainer
                anchors.fill: parent
                visible: barWindow.isVertical

                // Islas Superiores: Workspaces
                Column {
                    anchors.top: parent.top
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: barWindow.itemSpacing

                    WorkspacesModule {
                        visible: ConfigService.showWorkspaces
                        isVertical: true
                    }
                }

                // Isla Central: Hora y Fecha apilada
                Column {
                    anchors.centerIn: parent
                    spacing: barWindow.itemSpacing

                    TimeDateModule {
                        visible: ConfigService.showTimeDate
                        isVertical: true
                    }
                }

                // Islas Inferiores: Bandeja + Red + Audio + Batería opcional
                Column {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: barWindow.itemSpacing

                    TrayModule {
                        isVertical: true
                    }

                    NetworkModule {
                        visible: ConfigService.showNetwork
                        isVertical: true
                    }

                    AudioModule {
                        visible: ConfigService.showAudio
                        isVertical: true
                    }

                    BatteryModule {
                        isVertical: true
                    }
                }
            }
        }
    }
}

// ~/.config/quickshell/bar/modules/FocusModule.qml
// Propósito: Isla flotante Liquid Glass que muestra el título o aplicación
// de la ventana enfocada actualmente en Hyprland.

import QtQuick
import Quickshell.Wayland
import "../../components"
import "../../services"

LiquidCapsule {
    id: root
    property bool isVertical: false
    interactive: false
    accentGlowColor: ThemeService.accentBlue

    readonly property var activeWindow: ToplevelManager.activeToplevel
    readonly property string winTitle: (activeWindow && activeWindow.title) ? activeWindow.title : "Escritorio"
    readonly property string appId: (activeWindow && activeWindow.appId) ? activeWindow.appId : "Hyprland"

    visible: !isVertical && ConfigService.showFocus

    Row {
        spacing: 8

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: "󰣆"
            font.family: ThemeService.iconFont
            font.pixelSize: 15
            color: ThemeService.accentBlue
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.winTitle.length > 34 ? (root.winTitle.substring(0, 33) + "…") : root.winTitle
            font.family: ThemeService.fontFamily
            font.pixelSize: 12
            font.bold: true
            color: ThemeService.textPrimary
        }
    }
}

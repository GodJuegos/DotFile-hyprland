// ~/.config/quickshell/bar/modules/WorkspacesModule.qml
// Propósito: Isla flotante Liquid Glass con los espacios de trabajo de Hyprland.
// Clic izquierdo: cambia al workspace | Rueda del mouse: recorre workspaces
// Clic derecho: rota la posición de la barra (Top -> Right -> Bottom -> Left) para probar las 4 posiciones.

import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../../components"
import "../../services"

LiquidCapsule {
    id: root
    property bool isVertical: false
    accentGlowColor: ThemeService.accentPurple

    readonly property int focusedWsId: (Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id) ? Hyprland.focusedWorkspace.id : 1
    readonly property int totalWorkspaces: Math.max(5, focusedWsId)

    function hasWindowsInWorkspace(wsId) {
        if (!Hyprland.workspaces || !Hyprland.workspaces.values) return false;
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++) {
            if (list[i] && list[i].id === wsId) return true;
        }
        return false;
    }

    onRightClicked: ConfigService.cycleBarPosition()

    onWheelScrolled: wheel => {
        if (wheel.angleDelta.y > 0) {
            let prev = Math.max(1, focusedWsId - 1);
            Hyprland.dispatch("workspace " + prev);
        } else if (wheel.angleDelta.y < 0) {
            let next = Math.min(10, focusedWsId + 1);
            Hyprland.dispatch("workspace " + next);
        }
    }

    Grid {
        id: wsFlow
        columns: root.isVertical ? 1 : root.totalWorkspaces
        spacing: 6

        Repeater {
            model: root.totalWorkspaces

            delegate: Rectangle {
                required property int index
                readonly property int wsId: index + 1
                readonly property bool isActive: wsId === root.focusedWsId
                readonly property bool isOccupied: root.hasWindowsInWorkspace(wsId)

                width: root.isVertical ? 16 : (isActive ? 32 : 16)
                height: root.isVertical ? (isActive ? 32 : 16) : 16
                radius: 8

                color: isActive
                    ? ThemeService.accentCyan
                    : (isOccupied ? "#55ffffff" : "#22ffffff")

                border.width: isActive ? 1 : 0
                border.color: "#ccffffff"

                Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutQuint } }
                Behavior on height { NumberAnimation { duration: 260; easing.type: Easing.OutQuint } }
                Behavior on color { ColorAnimation { duration: 180 } }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + wsId)
                }
            }
        }
    }
}

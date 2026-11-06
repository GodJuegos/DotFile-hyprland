// ~/.config/quickshell/bar/modules/TrayModule.qml
// Propósito: Isla flotante Liquid Glass para los iconos de bandeja del sistema (SystemTray).
// Se oculta sola si no hay aplicaciones en segundo plano en la bandeja.

import QtQuick
import Quickshell.Services.SystemTray
import "../../components"
import "../../services"

LiquidCapsule {
    id: root
    property bool isVertical: false
    interactive: false

    readonly property var trayItems: SystemTray.items ? SystemTray.items.values : []
    visible: ConfigService.showTray && trayItems && trayItems.length > 0

    Grid {
        columns: root.isVertical ? 1 : Math.max(1, root.trayItems.length)
        spacing: 8

        Repeater {
            model: SystemTray.items

            delegate: Item {
                required property SystemTrayItem modelData
                width: 20
                height: 20

                Image {
                    anchors.centerIn: parent
                    width: 16
                    height: 16
                    source: modelData.icon || ""
                    smooth: true
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mouse => {
                        if (mouse.button === Qt.LeftButton) modelData.activate();
                        else if (mouse.button === Qt.RightButton) modelData.secondaryActivate();
                    }
                }
            }
        }
    }
}

// ~/.config/quickshell/bar/modules/BatteryModule.qml
// Propósito: Isla flotante Liquid Glass de Batería.
// Está desactivada por defecto en PC ("showBattery": false en settings.json)
// y se puede activar opcionalmente si usas la configuración en una laptop.

import QtQuick
import Quickshell.Services.UPower
import "../../components"
import "../../services"

LiquidCapsule {
    id: root
    property bool isVertical: false
    accentGlowColor: ThemeService.accentGreen

    visible: ConfigService.showBattery

    readonly property int pct: UPower.displayDevice.ready ? Math.round(UPower.displayDevice.percentage * 100) : 100
    readonly property bool charging: UPower.displayDevice.ready && UPower.displayDevice.state === UPowerDeviceState.Charging

    Row {
        spacing: 5

        Text {
            text: root.charging ? "󰂄" : (root.pct <= 20 ? "󰂃" : "󰁹")
            font.family: ThemeService.iconFont
            font.pixelSize: 15
            color: root.charging ? ThemeService.accentGreen : (root.pct <= 20 ? ThemeService.accentRed : ThemeService.textPrimary)
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            visible: !root.isVertical
            text: root.pct + "%"
            font.family: ThemeService.monoFont
            font.pixelSize: 12
            font.bold: true
            color: ThemeService.textPrimary
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

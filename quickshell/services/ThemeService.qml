// ~/.config/quickshell/services/ThemeService.qml
// Propósito: Centraliza la paleta de colores, fuentes e iluminaciones para el
// estilo "iOS Liquid Glass" (cristal líquido con reflejo especular y bordes biselados).

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    // Fuentes principales (usando Iosevka Nerd Font instalada en tu sistema)
    readonly property string fontFamily: "Iosevka Nerd Font Propo"
    readonly property string monoFont: "Iosevka Nerd Font"
    readonly property string iconFont: "Iosevka Nerd Font Propo"

    // Colores base para Liquid Glass oscuro/translúcido
    readonly property color glassTint: "#121624"
    readonly property color glassSurface: "#1e2438"
    readonly property color glassRimLight: "#ffffff"
    readonly property color glassRimSubtle: "#8ab4f8"

    // Texto
    readonly property color textPrimary: "#f4f7ff"
    readonly property color textSecondary: "#b8c4e0"
    readonly property color textMuted: "#7d8bad"

    // Acentos luminosos estilo iOS / Material
    readonly property color accentBlue: "#5ac8fa"
    readonly property color accentCyan: "#64d2ff"
    readonly property color accentPurple: "#bf5af2"
    readonly property color accentGreen: "#30d158"
    readonly property color accentAmber: "#ffd60a"
    readonly property color accentRed: "#ff453a"
}

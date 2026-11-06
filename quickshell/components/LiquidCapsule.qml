// ~/.config/quickshell/components/LiquidCapsule.qml
// Propósito: Componente de isla flotante con efecto "Liquid Glass" de iOS.
// Crea una cápsula de cristal translúcido con bisel luminoso direccional,
// refracción especular interactiva que sigue al cursor y animación elástica.

import QtQuick
import "../services"

Item {
    id: root

    property bool isVertical: false
    property int paddingH: isVertical ? 6 : 14
    property int paddingV: isVertical ? 12 : 6
    property real customRadius: ConfigService.glassCornerRadius
    property color tintColor: ThemeService.glassTint
    property color accentGlowColor: ThemeService.accentCyan
    property bool interactive: true
    property bool activeHighlight: false

    default property alias content: contentContainer.data

    signal clicked(var mouse)
    signal rightClicked(var mouse)
    signal middleClicked(var mouse)
    signal wheelScrolled(var wheel)

    implicitWidth: isVertical
        ? ConfigService.barThickness
        : Math.max(ConfigService.barThickness, contentContainer.childrenRect.width + paddingH * 2)

    implicitHeight: isVertical
        ? Math.max(ConfigService.barThickness, contentContainer.childrenRect.height + paddingV * 2)
        : ConfigService.barThickness

    width: implicitWidth
    height: implicitHeight

    Behavior on width {
        NumberAnimation { duration: 280; easing.type: Easing.OutQuint }
    }
    Behavior on height {
        NumberAnimation { duration: 280; easing.type: Easing.OutQuint }
    }

    property bool hovered: hoverHandler.hovered
    property point cursorPos: hoverHandler.point.position
    property real hoverProgress: hovered ? 1.0 : 0.0
    Behavior on hoverProgress {
        NumberAnimation { duration: 220; easing.type: Easing.OutCubic }
    }

    scale: mouseArea.pressed ? 0.96 : (hovered && interactive ? 1.025 : 1.0)
    Behavior on scale {
        NumberAnimation { duration: 200; easing.type: Easing.OutBack }
    }

    // 1. Sombra exterior suave de flotación
    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 2
        anchors.bottomMargin: -2
        radius: root.customRadius
        color: "#45000000"
        z: -2
    }

    // 2. Cuerpo principal del cristal (Liquid Glass)
    Rectangle {
        id: glassBody
        anchors.fill: parent
        radius: root.customRadius
        clip: true

        // Gradiente diagonal translúcido estilo cristal esmerilado iOS
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop {
                position: 0.0
                color: Qt.rgba(
                    0.18 + 0.06 * root.hoverProgress,
                    0.22 + 0.08 * root.hoverProgress,
                    0.34 + 0.10 * root.hoverProgress,
                    ConfigService.glassOpacity + 0.14 + (root.activeHighlight ? 0.12 : 0.0)
                )
            }
            GradientStop {
                position: 0.5
                color: Qt.rgba(
                    0.09,
                    0.12,
                    0.20,
                    ConfigService.glassOpacity + 0.08
                )
            }
            GradientStop {
                position: 1.0
                color: Qt.rgba(
                    0.13 + 0.04 * root.hoverProgress,
                    0.17 + 0.05 * root.hoverProgress,
                    0.28 + 0.08 * root.hoverProgress,
                    ConfigService.glassOpacity + 0.16
                )
            }
        }

        // 3. Reflejo especular dinámico que sigue al cursor (Efecto lente Liquid Glass)
        Rectangle {
            id: cursorLensGlow
            width: Math.max(parent.width, parent.height) * 1.3
            height: width
            radius: width / 2
            x: root.cursorPos.x - width / 2
            y: root.cursorPos.y - height / 2
            visible: root.hoverProgress > 0.01
            opacity: root.hoverProgress * 0.28

            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(root.accentGlowColor.r, root.accentGlowColor.g, root.accentGlowColor.b, 0.55) }
                GradientStop { position: 0.45; color: Qt.rgba(1.0, 1.0, 1.0, 0.15) }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // 4. Brillo superior de refracción (Menisco de cristal superior)
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: root.customRadius * 0.45
            anchors.rightMargin: root.customRadius * 0.45
            height: 1.5
            radius: 1
            opacity: ConfigService.glassHighlightOpacity + 0.2 * root.hoverProgress
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.25; color: "#d0ffffff" }
                GradientStop { position: 0.5; color: "#ffffffff" }
                GradientStop { position: 0.75; color: "#b0a8d8ff" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        // 5. Bisel perimetral de cristal (Rim Light)
        border.width: 1.2
        border.color: Qt.rgba(
            1.0,
            1.0,
            1.0,
            ConfigService.glassBorderOpacity * (0.65 + 0.35 * root.hoverProgress)
        )
    }

    // 6. Contenedor centrado de los elementos del módulo
    Item {
        id: contentContainer
        anchors.centerIn: parent
        width: childrenRect.width
        height: childrenRect.height
    }

    HoverHandler {
        id: hoverHandler
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        cursorShape: root.interactive ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton) root.clicked(mouse);
            else if (mouse.button === Qt.RightButton) root.rightClicked(mouse);
            else if (mouse.button === Qt.MiddleButton) root.middleClicked(mouse);
        }
        onWheel: wheel => root.wheelScrolled(wheel)
    }
}

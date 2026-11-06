// ~/.config/quickshell/bar/popups/NetworkPopup.qml
// Propósito: Cápsula/Ventana flotante de Configuración de Internet (inspirada en NetworkPopup de Serpantinum)
// con estética iOS Liquid Glass. Se abre al hacer clic en el icono de Internet de la barra.
// Incluye:
// - Núcleo central orbital con anillos de radar y rayos shader (node_beams_clipped.frag.qsb)
// - Cápsulas orbitales flotantes: IP Local (clic para copiar), Velocidad de enlace (1000 Mbps),
//   Dirección MAC, Tráfico en vivo (↓/↑) y Botón de Test de Velocidad (Speedtest Cloudflare + Ping)
// - Selector inferior para cambiar entre Ethernet (Cable), Wi-Fi y Bluetooth + Botón Power.

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Bluetooth
import "../../components"
import "../../services"

PanelWindow {
    id: popupWin

    readonly property string barPos: ConfigService.barPosition
    readonly property int barThick: ConfigService.barThickness
    readonly property int barMarg: ConfigService.barMargin

    visible: NetService.popupOpen
    color: "transparent"

    WlrLayershell.namespace: "qs-network-popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: NetService.popupOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    implicitWidth: 640
    implicitHeight: 450

    anchors {
        top: barPos === "top" || barPos === "left" || barPos === "right"
        bottom: barPos === "bottom"
        right: barPos === "top" || barPos === "bottom" || barPos === "right"
        left: barPos === "left"
    }

    margins {
        top: barPos === "top" ? (barThick + barMarg * 2 + 4) : 40
        bottom: barPos === "bottom" ? (barThick + barMarg * 2 + 4) : 0
        right: barPos === "right" ? (barThick + barMarg * 2 + 4) : 16
        left: barPos === "left" ? (barThick + barMarg * 2 + 4) : 0
    }

    // Animación orbital continua suave para las tarjetas alrededor del núcleo
    property real orbitAngle: 0.0
    NumberAnimation on orbitAngle {
        from: 0
        to: Math.PI * 2
        duration: 180000
        loops: Animation.Infinite
        running: popupWin.visible
    }

    // Animación de entrada al abrir la cápsula
    property real openProgress: NetService.popupOpen ? 1.0 : 0.0
    Behavior on openProgress {
        NumberAnimation { duration: 320; easing.type: Easing.OutBack }
    }

    readonly property color modeAccent: {
        if (NetService.activeTab === "bt") return ThemeService.accentPurple;
        if (NetService.activeTab === "wifi") return ThemeService.accentCyan;
        return ThemeService.accentGreen;
    }

    // Datos de las 6 tarjetas orbitales alrededor del núcleo central
    readonly property var orbitCards: [
        {
            icon: "󰩟",
            title: NetService.ipCopiedFeedback ? "¡IP Copiada!" : NetService.localIp,
            subtitle: "IP Local (Clic copiar)",
            action: "copy_ip",
            highlight: NetService.ipCopiedFeedback
        },
        {
            icon: "󰓅",
            title: NetService.testRunning ? "Midiendo..." : (NetService.lastTestMbps !== "" ? NetService.testStatusText : "Iniciar Speedtest"),
            subtitle: "Test de Velocidad",
            action: "speedtest",
            highlight: true
        },
        {
            icon: "󰇚",
            title: "↓ " + NetService.downSpeedText,
            subtitle: "Descarga en vivo",
            action: "none",
            highlight: false
        },
        {
            icon: "󰕒",
            title: "↑ " + NetService.upSpeedText,
            subtitle: "Subida en vivo",
            action: "none",
            highlight: false
        },
        {
            icon: "󰈀",
            title: NetService.linkSpeed,
            subtitle: "Enlace (" + NetService.interfaceName + ")",
            action: "none",
            highlight: false
        },
        {
            icon: "󰒋",
            title: NetService.macAddress,
            subtitle: "Dirección MAC",
            action: "refresh",
            highlight: false
        }
    ]

    Item {
        id: mainStage
        anchors.fill: parent
        scale: 0.92 + 0.08 * popupWin.openProgress
        opacity: Math.min(1.0, popupWin.openProgress * 1.2)

        // Fondo Principal Liquid Glass de la Cápsula de Configuración
        Rectangle {
            id: glassCardBg
            anchors.fill: parent
            anchors.margins: 6
            radius: 28
            clip: true

            gradient: Gradient {
                orientation: Gradient.Vertical
                GradientStop { position: 0.0; color: Qt.rgba(0.14, 0.18, 0.28, 0.88) }
                GradientStop { position: 0.5; color: Qt.rgba(0.08, 0.11, 0.18, 0.92) }
                GradientStop { position: 1.0; color: Qt.rgba(0.11, 0.15, 0.24, 0.90) }
            }

            border.width: 1.4
            border.color: "#55ffffff"

            // Brillo especular superior estilo iOS Liquid Glass
            Rectangle {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 36
                anchors.rightMargin: 36
                height: 2
                radius: 1
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 0.3; color: "#ccffffff" }
                    GradientStop { position: 0.5; color: "#ffffffff" }
                    GradientStop { position: 0.7; color: "#aa88ddff" }
                    GradientStop { position: 1.0; color: "transparent" }
                }
            }

            // Resplandor ambiental detrás del núcleo central
            Rectangle {
                width: 300
                height: 300
                radius: 150
                anchors.centerIn: orbitArea
                color: popupWin.modeAccent
                opacity: NetService.isConnected ? 0.10 : 0.03
                Behavior on color { ColorAnimation { duration: 250 } }
            }

            // Botón superior derecho para cerrar la cápsula (✕)
            Rectangle {
                width: 32
                height: 32
                radius: 16
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.margins: 16
                z: 50
                color: closeMa.containsMouse ? "#44ff453a" : "#22ffffff"
                border.width: 1
                border.color: "#44ffffff"

                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    font.family: ThemeService.iconFont
                    font.pixelSize: 15
                    color: ThemeService.textPrimary
                }

                MouseArea {
                    id: closeMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: NetService.popupOpen = false
                }
            }

            // Área Orbital (Núcleo Central + Rayos + Tarjetas Flotantes)
            Item {
                id: orbitArea
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: bottomControls.top
                anchors.bottomMargin: 6

                readonly property real centerX: width / 2
                readonly property real centerY: height / 2

                // 3 Anillos concéntricos de radar estilo Serpantinum
                Repeater {
                    model: 3
                    Rectangle {
                        required property int index
                        anchors.centerIn: parent
                        width: 170 + index * 95
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.width: 1
                        border.color: Qt.rgba(popupWin.modeAccent.r, popupWin.modeAccent.g, popupWin.modeAccent.b, 0.16 - index * 0.04)
                    }
                }

                // Shader de Rayos de Energía conectando el Núcleo con las 6 Cápsulas Orbitales
                ShaderEffect {
                    id: beamsShader
                    anchors.fill: parent
                    z: 1
                    visible: NetService.isConnected

                    property real animTime: 0.0
                    NumberAnimation on animTime {
                        running: popupWin.visible && NetService.isConnected
                        loops: Animation.Infinite
                        from: 0; to: 1000
                        duration: 1000000
                    }

                    property vector2d itemSize: Qt.vector2d(width, height)
                    property real time: animTime
                    property real strikeProg: popupWin.openProgress
                    property real scale: 1.0
                    property color activeColor: popupWin.modeAccent
                    property real beamCount: 6.0
                    property real coreRadius: 68.0

                    function cardCenter(idx) {
                        let angle = popupWin.orbitAngle + (idx / 6.0) * Math.PI * 2;
                        let rx = 215;
                        let ry = 118;
                        return Qt.vector4d(
                            orbitArea.centerX,
                            orbitArea.centerY,
                            orbitArea.centerX + Math.cos(angle) * rx,
                            orbitArea.centerY + Math.sin(angle) * ry
                        );
                    }

                    property vector4d beam0: cardCenter(0)
                    property vector4d beam1: cardCenter(1)
                    property vector4d beam2: cardCenter(2)
                    property vector4d beam3: cardCenter(3)
                    property vector4d beam4: cardCenter(4)
                    property vector4d beam5: cardCenter(5)
                    property vector4d beam6: Qt.vector4d(-1, -1, -1, -1)
                    property vector4d beam7: Qt.vector4d(-1, -1, -1, -1)
                    property vector4d beam8: Qt.vector4d(-1, -1, -1, -1)
                    property vector4d beam9: Qt.vector4d(-1, -1, -1, -1)
                    property vector4d beam10: Qt.vector4d(-1, -1, -1, -1)
                    property vector4d beam11: Qt.vector4d(-1, -1, -1, -1)
                    property vector4d beam12: Qt.vector4d(-1, -1, -1, -1)
                    property vector4d beam13: Qt.vector4d(-1, -1, -1, -1)
                    property vector4d beam14: Qt.vector4d(-1, -1, -1, -1)
                    property vector4d beam15: Qt.vector4d(-1, -1, -1, -1)

                    fragmentShader: "file://" + Quickshell.env("HOME") + "/.config/quickshell/assets/shaders/node_beams_clipped.frag.qsb"
                }

                // NÚCLEO CENTRAL LIQUID GLASS
                Rectangle {
                    id: centralCore
                    width: 136
                    height: 136
                    radius: 68
                    anchors.centerIn: parent
                    z: 5

                    gradient: Gradient {
                        orientation: Gradient.Vertical
                        GradientStop {
                            position: 0.0
                            color: Qt.rgba(popupWin.modeAccent.r * 0.45 + 0.12, popupWin.modeAccent.g * 0.45 + 0.15, popupWin.modeAccent.b * 0.45 + 0.22, 0.85)
                        }
                        GradientStop {
                            position: 1.0
                            color: Qt.rgba(0.10, 0.14, 0.22, 0.92)
                        }
                    }

                    border.width: 2
                    border.color: popupWin.modeAccent

                    scale: coreMouse.pressed ? 0.95 : (coreMouse.containsMouse ? 1.05 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 4

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: NetService.activeTab === "bt" ? "󰂯" : (NetService.activeTab === "wifi" ? "󰤨" : NetService.netIcon)
                            font.family: ThemeService.iconFont
                            font.pixelSize: 34
                            color: ThemeService.textPrimary
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: NetService.activeTab === "bt"
                                ? "Bluetooth"
                                : (NetService.activeTab === "wifi" ? "Wi-Fi" : NetService.connectionName)
                            font.family: ThemeService.fontFamily
                            font.pixelSize: 14
                            font.weight: Font.Black
                            color: ThemeService.textPrimary
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: NetService.isConnected ? ("Conectado · " + NetService.interfaceName) : "Desconectado"
                            font.family: ThemeService.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            color: ThemeService.textSecondary
                        }
                    }

                    MouseArea {
                        id: coreMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NetService.refreshDetails()
                    }
                }

                // TARJETAS ORBITALES FLOTANTES LIQUID GLASS
                Repeater {
                    model: popupWin.orbitCards.length

                    delegate: Rectangle {
                        id: orbitCard
                        required property int index
                        readonly property var cardData: popupWin.orbitCards[index]
                        readonly property real angle: popupWin.orbitAngle + (index / popupWin.orbitCards.length) * Math.PI * 2
                        readonly property real radX: 215
                        readonly property real radY: 118

                        width: 158
                        height: 54
                        radius: 18
                        z: cardMouse.containsMouse ? 20 : 10

                        x: orbitArea.centerX - width / 2 + Math.cos(angle) * radX
                        y: orbitArea.centerY - height / 2 + Math.sin(angle) * radY

                        color: cardData.highlight
                            ? Qt.rgba(popupWin.modeAccent.r * 0.35 + 0.12, popupWin.modeAccent.g * 0.35 + 0.15, popupWin.modeAccent.b * 0.35 + 0.22, 0.88)
                            : (cardMouse.containsMouse ? "#422c3858" : "#cc182034")

                        border.width: 1.2
                        border.color: cardData.highlight || cardMouse.containsMouse
                            ? popupWin.modeAccent
                            : "#48ffffff"

                        scale: cardMouse.pressed ? 0.95 : (cardMouse.containsMouse ? 1.06 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

                        Row {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 10
                            spacing: 9

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: orbitCard.cardData.icon
                                font.family: ThemeService.iconFont
                                font.pixelSize: 18
                                color: popupWin.modeAccent
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1
                                width: parent.width - 36

                                Text {
                                    width: parent.width
                                    elide: Text.ElideRight
                                    text: orbitCard.cardData.title
                                    font.family: ThemeService.fontFamily
                                    font.pixelSize: 12
                                    font.weight: Font.Black
                                    color: ThemeService.textPrimary
                                }

                                Text {
                                    width: parent.width
                                    elide: Text.ElideRight
                                    text: orbitCard.cardData.subtitle
                                    font.family: ThemeService.fontFamily
                                    font.pixelSize: 9
                                    font.bold: true
                                    color: ThemeService.textSecondary
                                }
                            }
                        }

                        MouseArea {
                            id: cardMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: orbitCard.cardData.action !== "none" ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                const act = orbitCard.cardData.action;
                                if (act === "copy_ip") NetService.copyIpToClipboard();
                                else if (act === "speedtest") NetService.runSpeedTest();
                                else if (act === "refresh") NetService.refreshDetails();
                            }
                        }
                    }
                }
            }

            // CONTROLES INFERIORES: Selector de Modo (Ethernet | Wi-Fi | Bluetooth) + Botón Power
            Item {
                id: bottomControls
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottomMargin: 16
                height: 44
                z: 30

                // Selector de pestañas estilo Serpantinum
                Rectangle {
                    anchors.centerIn: parent
                    width: 340
                    height: 40
                    radius: 20
                    color: "#24ffffff"
                    border.width: 1
                    border.color: "#45ffffff"

                    Row {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 4

                        Repeater {
                            model: [
                                { id: "eth", label: "󰈀  Ethernet" },
                                { id: "wifi", label: "󰤨  Wi-Fi" },
                                { id: "bt", label: "󰂯  Bluetooth" }
                            ]

                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool isCurrent: NetService.activeTab === modelData.id

                                width: (340 - 16) / 3
                                height: 32
                                radius: 16
                                color: isCurrent ? popupWin.modeAccent : (tabMa.containsMouse ? "#22ffffff" : "transparent")
                                Behavior on color { ColorAnimation { duration: 180 } }

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.family: ThemeService.fontFamily
                                    font.pixelSize: 12
                                    font.bold: true
                                    color: isCurrent ? "#0d111a" : ThemeService.textPrimary
                                }

                                MouseArea {
                                    id: tabMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: NetService.activeTab = modelData.id
                                }
                            }
                        }
                    }
                }

                // Botón circular de Encendido/Apagado (derecha inferior)
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    anchors.verticalCenter: parent.verticalCenter
                    color: pwrMa.containsMouse ? Qt.lighter(popupWin.modeAccent, 1.15) : popupWin.modeAccent
                    border.width: 1
                    border.color: "#88ffffff"

                    scale: pwrMa.pressed ? 0.92 : (pwrMa.containsMouse ? 1.06 : 1.0)
                    Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

                    Text {
                        anchors.centerIn: parent
                        text: ""
                        font.family: ThemeService.iconFont
                        font.pixelSize: 16
                        color: "#0d111a"
                    }

                    MouseArea {
                        id: pwrMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NetService.toggleCurrentInterfacePower()
                    }
                }
            }
        }
    }
}

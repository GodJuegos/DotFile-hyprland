// ~/.config/quickshell/services/ConfigService.qml
// Propósito: Lee y vigila en tiempo real el archivo ~/.config/quickshell/settings.json.
// Permite cambiar la posición de la barra (top, bottom, left, right) o activar/desactivar
// módulos (como la batería opcional en laptop) sin reiniciar la shell.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell/settings.json"

    // Estado reactivo de la barra
    property string barPosition: "top"       // "top" | "bottom" | "left" | "right"
    property int barThickness: 42
    property int barMargin: 8
    property int barSpacing: 10

    // Visibilidad de módulos
    property bool showWorkspaces: true
    property bool showFocus: true
    property bool showTimeDate: true
    property bool showNetwork: true
    property bool showAudio: true
    property bool showTray: true
    property bool showBattery: false         // Desactivado por defecto en PC; pon true si es laptop

    // Preferencias de audio (evitar que PipeWire fuerce solo audífonos)
    property string preferredAudioRoute: "dual" // "speakers" | "headphones" | "dual" | "hdmi"
    property bool disableAutoMute: true

    // Parámetros de Liquid Glass
    property real glassOpacity: 0.24
    property real glassBorderOpacity: 0.48
    property real glassHighlightOpacity: 0.65
    property int glassCornerRadius: 18

    property var rawData: ({})

    function parseConfig(txt) {
        if (!txt || txt.trim() === "") return;
        try {
            let data = JSON.parse(txt);
            root.rawData = data;

            if (data.bar) {
                if (data.bar.position !== undefined) root.barPosition = String(data.bar.position);
                if (data.bar.thickness !== undefined) root.barThickness = Number(data.bar.thickness);
                if (data.bar.margin !== undefined) root.barMargin = Number(data.bar.margin);
                if (data.bar.spacing !== undefined) root.barSpacing = Number(data.bar.spacing);
                if (data.bar.showWorkspaces !== undefined) root.showWorkspaces = Boolean(data.bar.showWorkspaces);
                if (data.bar.showFocus !== undefined) root.showFocus = Boolean(data.bar.showFocus);
                if (data.bar.showTimeDate !== undefined) root.showTimeDate = Boolean(data.bar.showTimeDate);
                if (data.bar.showNetwork !== undefined) root.showNetwork = Boolean(data.bar.showNetwork);
                if (data.bar.showAudio !== undefined) root.showAudio = Boolean(data.bar.showAudio);
                if (data.bar.showTray !== undefined) root.showTray = Boolean(data.bar.showTray);
                if (data.bar.showBattery !== undefined) root.showBattery = Boolean(data.bar.showBattery);
            }
            if (data.audio) {
                if (data.audio.preferredRoute !== undefined) root.preferredAudioRoute = String(data.audio.preferredRoute);
                if (data.audio.disableAutoMute !== undefined) root.disableAutoMute = Boolean(data.audio.disableAutoMute);
            }
            if (data.glass) {
                if (data.glass.opacity !== undefined) root.glassOpacity = Number(data.glass.opacity);
                if (data.glass.borderOpacity !== undefined) root.glassBorderOpacity = Number(data.glass.borderOpacity);
                if (data.glass.highlightOpacity !== undefined) root.glassHighlightOpacity = Number(data.glass.highlightOpacity);
                if (data.glass.cornerRadius !== undefined) root.glassCornerRadius = Number(data.glass.cornerRadius);
            }
        } catch (e) {
            console.warn("Error leyendo settings.json:", e);
        }
    }

    function saveConfig() {
        let obj = {
            bar: {
                position: root.barPosition,
                thickness: root.barThickness,
                margin: root.barMargin,
                spacing: root.barSpacing,
                showWorkspaces: root.showWorkspaces,
                showFocus: root.showFocus,
                showTimeDate: root.showTimeDate,
                showNetwork: root.showNetwork,
                showAudio: root.showAudio,
                showTray: root.showTray,
                showBattery: root.showBattery
            },
            audio: {
                preferredRoute: root.preferredAudioRoute,
                disableAutoMute: root.disableAutoMute
            },
            glass: {
                opacity: root.glassOpacity,
                borderOpacity: root.glassBorderOpacity,
                highlightOpacity: root.glassHighlightOpacity,
                cornerRadius: root.glassCornerRadius
            }
        };
        settingsFile.setText(JSON.stringify(obj, null, 2) + "\n");
    }

    function setBarPosition(pos) {
        let p = String(pos).toLowerCase().trim();
        if (p === "top" || p === "bottom" || p === "left" || p === "right") {
            root.barPosition = p;
            root.saveConfig();
        }
    }

    function cycleBarPosition() {
        const order = ["top", "right", "bottom", "left"];
        let idx = order.indexOf(root.barPosition);
        let next = order[(idx + 1) % order.length];
        setBarPosition(next);
    }

    FileView {
        id: settingsFile
        path: root.configPath
        watchChanges: true
        blockWrites: true
        onFileChanged: reload()
        onLoaded: root.parseConfig(text())
    }
}

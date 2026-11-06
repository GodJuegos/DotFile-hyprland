// ~/.config/quickshell/services/AudioService.qml
// Propósito: Controla el volumen de PipeWire y soluciona el problema de que
// PipeWire/ALSA priorice solo los audífonos y apague los altavoces.
// Permite alternar entre: Dual (Altavoces + Audífonos), Solo Altavoces, Solo Audífonos y HDMI.

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

Singleton {
    id: root

    // Seguimiento de nodos PipeWire para leer volumen y mute en vivo
    PwObjectTracker {
        objects: Pipewire.nodes ? Pipewire.nodes.values : []
    }

    readonly property PwNode defaultSink: Pipewire.defaultAudioSink
    readonly property int volumePercent: (defaultSink && defaultSink.audio) ? Math.round(defaultSink.audio.volume * 100) : 0
    readonly property bool isMuted: (defaultSink && defaultSink.audio) ? defaultSink.audio.muted : false

    // Ruta activa: "dual" (Altavoces + Audífonos), "speakers" (Altavoces), "headphones" (Audífonos), "hdmi" (TV/Monitor)
    property string currentRoute: ConfigService.preferredAudioRoute || "dual"

    readonly property string routeLabel: {
        if (currentRoute === "speakers") return "Altavoces";
        if (currentRoute === "headphones") return "Audífonos";
        if (currentRoute === "hdmi") return "HDMI TV";
        return "Altavoz + Audíf.";
    }

    readonly property string routeIcon: {
        if (isMuted || volumePercent === 0) return "󰖁";
        if (currentRoute === "headphones") return "󰋋";
        if (currentRoute === "hdmi") return "󰡁";
        if (currentRoute === "dual") return "󱡬";
        return volumePercent > 50 ? "󰕾" : "󰖀";
    }

    function setVolume(pct) {
        if (defaultSink && defaultSink.audio) {
            let clamped = Math.max(0, Math.min(150, pct));
            defaultSink.audio.volume = clamped / 100.0;
        }
    }

    function changeVolume(delta) {
        setVolume(volumePercent + delta);
    }

    function toggleMute() {
        if (defaultSink && defaultSink.audio) {
            defaultSink.audio.muted = !defaultSink.audio.muted;
        }
    }

    // Aplica la ruta elegida sobre PipeWire + mezclador ALSA de la tarjeta Realtek (Generic_1)
    function applyRoute(route) {
        root.currentRoute = route;
        ConfigService.preferredAudioRoute = route;
        ConfigService.saveConfig();

        let cmd = "";
        const analogSink = "alsa_output.pci-0000_08_00.6.analog-stereo";
        const hdmiSink = "alsa_output.pci-0000_01_00.1.hdmi-stereo";

        if (route === "speakers") {
            cmd = "pactl set-default-sink " + analogSink + " 2>/dev/null; " +
                  "pactl set-sink-port " + analogSink + " analog-output-lineout 2>/dev/null; " +
                  "amixer -c Generic_1 sset 'Auto-Mute Mode' Disabled >/dev/null 2>&1; " +
                  "amixer -c Generic_1 sset 'Front' 100% unmute >/dev/null 2>&1; " +
                  "amixer -c Generic_1 sset 'Headphone' mute >/dev/null 2>&1";
        } else if (route === "headphones") {
            cmd = "pactl set-default-sink " + analogSink + " 2>/dev/null; " +
                  "pactl set-sink-port " + analogSink + " analog-output-headphones 2>/dev/null; " +
                  "amixer -c Generic_1 sset 'Auto-Mute Mode' Disabled >/dev/null 2>&1; " +
                  "amixer -c Generic_1 sset 'Headphone' 100% unmute >/dev/null 2>&1; " +
                  "amixer -c Generic_1 sset 'Front' mute >/dev/null 2>&1";
        } else if (route === "hdmi") {
            cmd = "pactl set-default-sink " + hdmiSink + " 2>/dev/null";
        } else {
            // Modo "dual": activa simultáneamente la salida de línea (altavoces) y audífonos sin que PipeWire apague el altavoz
            cmd = "pactl set-default-sink " + analogSink + " 2>/dev/null; " +
                  "pactl set-sink-port " + analogSink + " analog-output-lineout 2>/dev/null; " +
                  "amixer -c Generic_1 sset 'Auto-Mute Mode' Disabled >/dev/null 2>&1; " +
                  "amixer -c Generic_1 sset 'Front' 100% unmute >/dev/null 2>&1; " +
                  "amixer -c Generic_1 sset 'Headphone' 100% unmute >/dev/null 2>&1";
        }

        Quickshell.execDetached(["bash", "-c", cmd]);
    }

    function cycleRoute() {
        const order = ["dual", "speakers", "headphones", "hdmi"];
        let idx = order.indexOf(root.currentRoute);
        let next = order[(idx + 1) % order.length];
        applyRoute(next);
    }

    Component.onCompleted: {
        // Al iniciar, asegura que el altavoz no quede silenciado por la prioridad de audífonos
        Qt.callLater(() => {
            applyRoute(ConfigService.preferredAudioRoute || "dual");
        });
    }
}

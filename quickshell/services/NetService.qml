// ~/.config/quickshell/services/NetService.qml
// Propósito: Servicio central de Red (Ethernet, Wi-Fi y Bluetooth).
// - Calcula en vivo la velocidad de descarga (↓) y subida (↑) desde /proc/net/dev
// - Obtiene IP local, MAC y velocidad física del cable (ej. 1000 Mbps)
// - Controla la apertura de la Cápsula de Configuración de Red (NetworkPopup)
// - Ejecuta el Test de Velocidad (Speedtest Cloudflare + Ping)

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking
import Quickshell.Bluetooth

Singleton {
    id: root

    // Controla si la cápsula/ventana de configuración de Internet está abierta
    property bool popupOpen: false
    property string activeTab: "eth" // "eth" | "wifi" | "bt"

    function togglePopup() {
        root.popupOpen = !root.popupOpen;
        if (root.popupOpen) {
            root.refreshDetails();
        }
    }

    // Estado de conexión principal
    property bool isEthernet: true
    property bool isWifi: false
    property bool isConnected: true
    property string interfaceName: "enp5s0"
    property string connectionName: "Ethernet"
    property int wifiSignal: 100

    // Detalles técnicos para las tarjetas orbitales del popup
    property string localIp: "Obteniendo IP..."
    property string macAddress: "--:--:--:--:--:--"
    property string linkSpeed: "1000 Mbps"
    property bool ipCopiedFeedback: false

    // Velocidad en tiempo real (tráfico actual de la interfaz)
    property real downBytesPerSec: 0
    property real upBytesPerSec: 0
    property string downSpeedText: "0 KB/s"
    property string upSpeedText: "0 KB/s"

    // Estado del botón de Test de Velocidad (Speedtest)
    property bool testRunning: false
    property string lastTestMbps: ""
    property string lastPingMs: ""
    property string testStatusText: "Test Velocidad"

    property double prevRxBytes: -1
    property double prevTxBytes: -1
    property double prevTimestamp: 0

    readonly property string netIcon: {
        if (!isConnected) return "󰤮";
        if (isEthernet) return "󰈀";
        if (wifiSignal >= 75) return "󰤨";
        if (wifiSignal >= 50) return "󰤥";
        if (wifiSignal >= 25) return "󰤢";
        return "󰤟";
    }

    function formatRate(bytesPerSec) {
        if (bytesPerSec < 1024) return "0 KB/s";
        let kb = bytesPerSec / 1024.0;
        if (kb < 1000) return Math.round(kb) + " KB/s";
        let mb = kb / 1024.0;
        return mb.toFixed(1) + " MB/s";
    }

    function parseProcNetDev(content) {
        if (!content) return;
        let lines = content.split("\n");
        let totalRx = 0;
        let totalTx = 0;
        let detectedIface = "";
        let hasEth = false;
        let hasWl = false;

        for (let i = 2; i < lines.length; i++) {
            let line = lines[i].trim();
            if (!line) continue;
            let parts = line.split(":");
            if (parts.length < 2) continue;
            let iface = parts[0].trim();
            if (iface === "lo" || iface.startsWith("docker") || iface.startsWith("veth") || iface.startsWith("br-") || iface.startsWith("virbr")) continue;

            let fields = parts[1].trim().split(/\s+/);
            if (fields.length < 9) continue;

            let rx = parseFloat(fields[0]);
            let tx = parseFloat(fields[8]);

            if (rx > 0 || tx > 0) {
                totalRx += rx;
                totalTx += tx;
                if (iface.startsWith("en") || iface.startsWith("eth")) {
                    hasEth = true;
                    detectedIface = iface;
                } else if (iface.startsWith("wl")) {
                    hasWl = true;
                    if (!detectedIface) detectedIface = iface;
                }
            }
        }

        let now = Date.now();
        if (root.prevRxBytes >= 0 && root.prevTimestamp > 0) {
            let dt = (now - root.prevTimestamp) / 1000.0;
            if (dt > 0.1) {
                let dRx = Math.max(0, (totalRx - root.prevRxBytes) / dt);
                let dTx = Math.max(0, (totalTx - root.prevTxBytes) / dt);
                root.downBytesPerSec = dRx;
                root.upBytesPerSec = dTx;
                root.downSpeedText = root.formatRate(dRx);
                root.upSpeedText = root.formatRate(dTx);
            }
        }

        root.prevRxBytes = totalRx;
        root.prevTxBytes = totalTx;
        root.prevTimestamp = now;

        if (detectedIface !== "") {
            root.interfaceName = detectedIface;
            root.isEthernet = hasEth;
            root.isWifi = !hasEth && hasWl;
            root.isConnected = true;
            root.connectionName = hasEth ? "Ethernet" : "Wi-Fi";
        }
    }

    FileView {
        id: netDevView
        path: "/proc/net/dev"
        onLoaded: root.parseProcNetDev(text())
    }

    // Obtiene IP, MAC y velocidad de enlace (Mbps) de la interfaz activa
    Process {
        id: detailsProc
        command: [
            "bash", "-c",
            "IFACE=\"" + root.interfaceName + "\"; " +
            "IP=$(ip -4 -o addr show dev \"$IFACE\" 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n1); " +
            "MAC=$(cat /sys/class/net/\"$IFACE\"/address 2>/dev/null); " +
            "SPD=$(cat /sys/class/net/\"$IFACE\"/speed 2>/dev/null); " +
            "printf '%s|%s|%s\\n' \"${IP:-Sin IP}\" \"${MAC:-N/A}\" \"${SPD:-1000}\""
        ]
        stdout: SplitParser {
            onRead: data => {
                let parts = data.trim().split("|");
                if (parts.length >= 3) {
                    root.localIp = parts[0] || "Sin IP";
                    root.macAddress = parts[1] || "N/A";
                    let s = parts[2];
                    root.linkSpeed = (s && s !== "-1") ? (s + " Mbps") : "Activo";
                }
            }
        }
    }

    function refreshDetails() {
        detailsProc.running = true;
    }

    function copyIpToClipboard() {
        if (!root.localIp || root.localIp === "Sin IP") return;
        Quickshell.execDetached(["wl-copy", root.localIp]);
        root.ipCopiedFeedback = true;
        copyResetTimer.restart();
    }

    Timer {
        id: copyResetTimer
        interval: 1800
        onTriggered: root.ipCopiedFeedback = false
    }

    function toggleCurrentInterfacePower() {
        if (root.activeTab === "eth") {
            let action = root.isConnected ? "disconnect" : "connect";
            Quickshell.execDetached(["nmcli", "device", action, root.interfaceName]);
            root.isConnected = !root.isConnected;
        } else if (root.activeTab === "wifi") {
            Networking.wifiEnabled = !Networking.wifiEnabled;
        } else if (root.activeTab === "bt") {
            if (Bluetooth.defaultAdapter) {
                Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled;
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netDevView.reload()
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshDetails()
    }

    // Proceso para ejecutar un Speedtest real (descarga de prueba Cloudflare + ping)
    Process {
        id: speedTestProc
        command: [
            "bash", "-c",
            "PING=$(ping -c 2 -W 2 1.1.1.1 2>/dev/null | awk -F'/' 'END{ if ($5 != \"\") printf \"%.0f\", $5; else print \"-\" }'); " +
            "BPS=$(curl -L -s -w '%{speed_download}' -o /dev/null --max-time 8 'https://speed.cloudflare.com/__down?bytes=25000000' 2>/dev/null); " +
            "awk -v bps=\"$BPS\" -v p=\"$PING\" 'BEGIN { mbps = (bps * 8) / 1000000.0; printf \"%.1f Mbps|%s ms\\n\", mbps, p }'"
        ]
        stdout: SplitParser {
            onRead: data => {
                let line = data.trim();
                if (!line) return;
                let parts = line.split("|");
                if (parts.length >= 2) {
                    root.lastTestMbps = parts[0];
                    root.lastPingMs = parts[1];
                    root.testStatusText = parts[0] + " · " + parts[1];
                }
            }
        }
        onExited: {
            root.testRunning = false;
            if (root.lastTestMbps === "" || root.lastTestMbps === "0.0 Mbps") {
                root.testStatusText = "Reintentar Test";
            }
        }
    }

    function runSpeedTest() {
        if (root.testRunning) return;
        root.testRunning = true;
        root.testStatusText = "Midiendo...";
        speedTestProc.running = true;
    }
}

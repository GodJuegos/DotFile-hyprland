// ~/.config/quickshell/shell.qml
// Propósito: Punto de entrada principal de nuestra shell en Quickshell.
// Carga la barra modular Liquid Glass y desactiva los popups de recarga.

import QtQuick
import Quickshell
import "bar"

ShellRoot {
    Connections {
        target: Quickshell
        function onReloadCompleted() { Quickshell.inhibitReloadPopup() }
        function onReloadFailed(err) { console.warn("Reload error:", err) }
    }

    Bar {}
}

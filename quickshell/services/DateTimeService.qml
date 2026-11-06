// ~/.config/quickshell/services/DateTimeService.qml
// Propósito: Provee la hora, minutos, segundos y fecha formateada en español,
// actualizándose cada segundo para el módulo central de la barra.

pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property string hours: "00"
    property string minutes: "00"
    property string seconds: "00"
    property string timeString: "00:00"
    property string dateString: ""
    property string dayNumber: "01"
    property string monthShort: "Ene"
    property string weekdayShort: "Vie"

    readonly property var monthsEs: ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"]
    readonly property var daysEs: ["Dom", "Lun", "Mar", "Mié", "Jue", "Vie", "Sáb"]

    function updateClock() {
        const now = new Date();
        const h = String(now.getHours()).padStart(2, "0");
        const m = String(now.getMinutes()).padStart(2, "0");
        const s = String(now.getSeconds()).padStart(2, "0");

        root.hours = h;
        root.minutes = m;
        root.seconds = s;
        root.timeString = h + ":" + m;

        const dName = daysEs[now.getDay()];
        const dNum = String(now.getDate()).padStart(2, "0");
        const mName = monthsEs[now.getMonth()];

        root.weekdayShort = dName;
        root.dayNumber = dNum;
        root.monthShort = mName;
        root.dateString = dName + ", " + dNum + " " + mName;
    }

    Component.onCompleted: updateClock()

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateClock()
    }
}

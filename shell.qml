import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import qs.ui
import qs.ui.components

PanelWindow {
    id: shell

    readonly property var sinkAudio:
        Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null

    property bool osdActive: false
    property string osdKind: "vol"
    property real osdValue: 0
    property bool osdMuted: false
    property string osdLabel: ""

    property var _layouts: []
    property int _layoutIdx: 0

    property bool _osdReady: false
    property bool _sinkSwitching: false

    property real _bright: -1
    property bool _brightSeen: false
    property string _backlightDir: ""
    property int _backlightRaw: -1
    property int _backlightMax: 0

    readonly property var battery: UPower.displayDevice

    property bool _batterySeen: false
    property bool _batteryWasConnected: false
    property bool _batteryWasFull: false
    property real _batteryLastPercent: -1
    property bool chargeStatus: false

    property bool _wifiSeen: false
    property bool _wifiConnected: false
    property string _wifiName: ""
    property bool _wifiQuerySet: false
    property bool _wifiQueryConnected: false
    property string _wifiQueryName: ""

    property bool _btSeen: false
    property bool _btConnected: false
    property string _btName: ""
    property bool _btQueryConnected: false
    property string _btQueryName: ""

    Timer {
        interval: 1200
        running: true
        onTriggered: shell._osdReady = true
    }

    Timer {
        id: osdHide
        interval: 1500
        onTriggered: shell.osdActive = false
    }

    Timer {
        id: sinkSettle
        interval: 700
        onTriggered: shell._sinkSwitching = false
    }

    function showOsd(kind, value, muted, label) {
        shell.osdKind = kind
        shell.osdValue = Math.max(0, Math.min(1, value))
        shell.osdMuted = muted === true
        shell.osdLabel = label === undefined ? "" : label
        shell.osdActive = true
        osdHide.restart()
    }

    function _applyWifi(connected, name) {
        const displayName = connected ? name : shell._wifiName
        if (!shell._wifiSeen) {
            shell._wifiSeen = true
            shell._wifiConnected = connected
            shell._wifiName = displayName
            return
        }
        if (connected === shell._wifiConnected && displayName === shell._wifiName)
            return
        shell._wifiConnected = connected
        shell._wifiName = displayName
        if (shell._osdReady)
            shell.showOsd("wifi", connected ? 1 : 0, false, displayName)
    }

    function _applyBt(connected, name) {
        const displayName = connected ? name : shell._btName
        if (!shell._btSeen) {
            shell._btSeen = true
            shell._btConnected = connected
            shell._btName = displayName
            return
        }
        if (connected === shell._btConnected && displayName === shell._btName)
            return
        shell._btConnected = connected
        shell._btName = displayName
        if (shell._osdReady)
            shell.showOsd("bt", connected ? 1 : 0, false, displayName)
    }

    function _refreshWifi() {
        shell._wifiQuerySet = false
        shell._wifiQueryConnected = false
        shell._wifiQueryName = ""
        wifiQuery.running = false
        wifiQuery.running = true
    }

    function _refreshBt() {
        shell._btQueryConnected = false
        shell._btQueryName = ""
        btQuery.running = false
        btQuery.running = true
    }

    function langCode(name) {
        var n = String(name).toLowerCase()
        if (n.indexOf("english") === 0) return "EN"
        if (n.indexOf("russian") === 0) return "RU"
        if (n.indexOf("ukrain") === 0) return "UK"
        if (n.indexOf("german") === 0) return "DE"
        if (n.indexOf("french") === 0) return "FR"
        if (n.indexOf("spanish") === 0) return "ES"
        if (n.indexOf("italian") === 0) return "IT"
        if (n.indexOf("polish") === 0) return "PL"
        return String(name).trim().substring(0, 2).toUpperCase()
    }

    // ---------------------------------------------- раскладки (niri)
    Process {
        id: layoutsRead
        running: Compositor.isNiri
        command: ["niri", "msg", "keyboard-layouts"]
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = String(text).split("\n")
                const arr = []
                var cur = 0
                for (var i = 0; i < lines.length; ++i) {
                    const m = lines[i].match(/^\s*(\*)?\s*(\d+)\s+(.*)$/)
                    if (!m)
                        continue
                    const idx = parseInt(m[2])
                    arr[idx] = m[3].trim()
                    if (m[1] === "*")
                        cur = idx
                }
                shell._layouts = arr
                shell._layoutIdx = cur
            }
        }
    }

    Process {
        id: layoutEvents
        running: Compositor.isNiri
        command: ["niri", "msg", "event-stream"]
        stdout: SplitParser {
            onRead: line => {
                const m = line.match(/keyboard layout switched:\s*(\d+)/i)
                if (!m)
                    return
                const idx = parseInt(m[1])
                shell._layoutIdx = idx
                if (shell._osdReady && shell._layouts[idx] !== undefined)
                    shell.showOsd("lang", 0, false, shell.langCode(shell._layouts[idx]))
            }
        }
    }

    Process {
        id: wifiQuery
        running: true
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device", "status"]
        stdout: SplitParser {
            onRead: line => {
                const p = line.split(":")
                if (p[0] !== "wifi")
                    return
                const connected = p[1] === "connected"
                const name = p.slice(2).join(":")
                if (connected || !shell._wifiQuerySet) {
                    shell._wifiQuerySet = true
                    shell._wifiQueryConnected = connected
                    shell._wifiQueryName = connected ? name : ""
                }
            }
        }
        onExited: function () {
            shell._applyWifi(shell._wifiQueryConnected, shell._wifiQueryName)
        }
    }

    Process {
        command: ["nmcli", "monitor"]
        running: true
        stdout: SplitParser {
            onRead: () => shell._refreshWifi()
        }
    }

    Process {
        id: btQuery
        running: true
        command: ["bluetoothctl", "devices", "Connected"]
        stdout: SplitParser {
            onRead: line => {
                const m = line.match(/^Device\s+\S+\s+(.*)$/)
                if (!m)
                    return
                shell._btQueryConnected = true
                shell._btQueryName = m[1].trim()
            }
        }
        onExited: function () {
            shell._applyBt(shell._btQueryConnected, shell._btQueryName)
        }
    }

    Process {
        command: ["bluetoothctl", "--monitor"]
        running: true
        stdout: SplitParser {
            onRead: line => {
                if (/Connected:|\[NEW\]|\[DEL\]/.test(line))
                    shell._refreshBt()
            }
        }
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    onSinkAudioChanged: {
        shell._sinkSwitching = true
        sinkSettle.restart()
    }

    Connections {
        target: shell.sinkAudio
        enabled: shell.sinkAudio !== null
        function onVolumeChanged() {
            if (shell._osdReady && !shell._sinkSwitching)
                shell.showOsd("vol", shell.sinkAudio.volume, shell.sinkAudio.muted)
        }
        function onMutedChanged() {
            if (shell._osdReady && !shell._sinkSwitching)
                shell.showOsd("vol", shell.sinkAudio.volume, shell.sinkAudio.muted)
        }
    }

    // ---------------------------------------------------- яркость (backlight)
    // The sysfs files are tiny; watch them in-process instead of spawning a
    // shell (and `ls`/`cat`) every 150 ms. A slow in-process reload stays as a
    // fallback for drivers that do not emit inotify events for sysfs.
    function _backlightInt(value) {
        const n = parseInt(String(value).trim(), 10)
        return isNaN(n) ? -1 : n
    }

    function _applyBacklight() {
        if (shell._backlightRaw < 0 || !(shell._backlightMax > 0))
            return
        const ratio = shell._backlightRaw / shell._backlightMax
        if (!shell._brightSeen) {
            shell._brightSeen = true
            shell._bright = ratio
            return
        }
        if (Math.abs(ratio - shell._bright) < 0.005)
            return
        shell._bright = ratio
        if (shell._osdReady)
            shell.showOsd("bright", ratio, false)
    }

    function _setBacklightMax(value) {
        shell._backlightMax = Math.max(0, shell._backlightInt(value))
        shell._applyBacklight()
    }

    function _setBacklightRaw(value) {
        shell._backlightRaw = shell._backlightInt(value)
        shell._applyBacklight()
    }

    Process {
        id: backlightProbe
        running: true
        command: ["sh", "-c",
            "for d in /sys/class/backlight/*; do " +
            "[ -r \"$d/brightness\" ] && [ -r \"$d/max_brightness\" ] && " +
            "{ printf '%s\\n' \"$d\"; break; }; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                const dir = String(text).trim()
                if (dir.length === 0)
                    return
                shell._backlightDir = dir
                backlightMaxFile.path = dir + "/max_brightness"
            }
        }
    }

    FileView {
        id: backlightMaxFile
        preload: true
        printErrors: false
        onLoaded: shell._setBacklightMax(text())
        onTextChanged: shell._setBacklightMax(text())
    }

    FileView {
        id: backlightFile
        preload: true
        watchChanges: true
        printErrors: false
        path: shell._backlightDir.length > 0
              ? shell._backlightDir + "/brightness" : ""
        onLoaded: shell._setBacklightRaw(text())
        onTextChanged: shell._setBacklightRaw(text())
    }

    Timer {
        interval: 250
        running: shell._backlightDir.length > 0
        repeat: true
        onTriggered: backlightFile.reload()
    }

    function _batteryPercent() {
        const b = shell.battery
        if (!b || !b.ready)
            return -1
        const raw = b.percentage
        return Math.max(0, Math.min(100, raw <= 1 ? raw * 100 : raw))
    }

    function _batteryConnected() {
        const b = shell.battery
        if (!b)
            return false
        if (UPower.onBattery === false)
            return true
        return b.state === UPowerDeviceState.Charging
            || b.state === UPowerDeviceState.PendingCharge
            || b.state === UPowerDeviceState.FullyCharged
    }

    function _applyBattery() {
        const p = shell._batteryPercent()
        if (p < 0)
            return
        const b = shell.battery
        const connected = shell._batteryConnected()
        const full = connected && (p >= 100 || b.state === UPowerDeviceState.FullyCharged)

        shell.chargeStatus = connected && !full

        if (!shell._batterySeen) {
            shell._batterySeen = true
            shell._batteryWasConnected = connected
            shell._batteryWasFull = full
            shell._batteryLastPercent = p
            return
        }

        const stateChanged = connected !== shell._batteryWasConnected
        const crossed80 = connected && shell._batteryLastPercent < 80 && p >= 80
        const reachedFull = full && !shell._batteryWasFull

        if (shell._osdReady && (stateChanged || crossed80 || reachedFull)) {
            const title = full ? "FULL" : (connected ? "CHARGING" : "UNPLUGGED")
            shell.showOsd("charge", p / 100, !connected, title)
        }

        shell._batteryWasConnected = connected
        shell._batteryWasFull = full
        shell._batteryLastPercent = p
    }

    Connections {
        target: UPower
        function onOnBatteryChanged() { shell._applyBattery() }
    }

    Connections {
        target: shell.battery
        enabled: shell.battery !== null && shell.battery !== undefined
        function onReadyChanged() { shell._applyBattery() }
        function onPercentageChanged() { shell._applyBattery() }
        function onStateChanged() { shell._applyBattery() }
    }

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Math.max(Theme.size.settingsHeight + Theme.space.xs,
                             notificationPill.visible
                                 ? notificationPill.y + notificationPill.height + Theme.space.lg
                                 : 0)

    WlrLayershell.namespace: "symbiont"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    color: "transparent"

    mask: Region {
        intersection: Intersection.Combine

        Region {
            x: backdrop.x
            y: backdrop.y
            width: backdrop.width
            height: backdrop.height
        }

        Region {
            x: notificationPill.visible ? notificationPill.x : 0
            y: notificationPill.visible ? notificationPill.y : 0
            width: notificationPill.visible ? notificationPill.width : 0
            height: notificationPill.visible ? notificationPill.height : 0
        }
    }

    TopBackdrop {
        id: backdrop
        screen: shell.screen
        volumeActive: shell.osdActive
        volume: shell.osdValue
        osdKind: shell.osdKind
        chargeStatus: shell.chargeStatus
        osdMuted: shell.osdMuted
        osdLabel: shell.osdLabel
        anchors.top: parent.top
        x: {
            const w = parent.width
            const centered = w / 2 - backdrop.width / 2
            const rightEdge = w / 2 + Theme.size.dropWidth / 2 - backdrop.width
            return centered + (rightEdge - centered) * backdrop.anchorMix
        }
    }

    NotificationPill {
        id: notificationPill
        mascotCenterX: backdrop.x + backdrop.mascotCenterX
        mascotBottomY: Theme.size.dropHeight
        suspended: backdrop.menuOpen

        onAttentionRequested: function (px, py) {
            backdrop.glanceAt(px, py)
        }

        onAttentionReleased: backdrop.releaseAttention()
    }

    NotificationNeck {
        mascotCenterX: notificationPill.mascotCenterX
        topY: notificationPill.mascotBottomY
        mergeY: notificationPill.y - notificationPill.mascotBottomY
        strength: notificationPill.visible ? notificationPill.neckOpacity : 0
        pinch: notificationPill.neckPinch
        fillColor: notificationPill.fillColor
    }
}

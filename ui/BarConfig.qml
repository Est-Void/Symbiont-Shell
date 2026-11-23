pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Bar module layout. Three ordered buckets feed one flat row:
//
//   left + center + right
//
// "mascot" is mandatory and may sit anywhere in that row. Modules before it
// extend the droplet to the left, modules after it extend it to the right.
// The file is rewritten atomically whenever the layout changes.
Singleton {
    id: root

    readonly property string configHome:
        Quickshell.env("XDG_CONFIG_HOME")
        || (Quickshell.env("HOME") + "/.config")
    readonly property string filePath: root.configHome + "/symbiont/bar.json"

    readonly property var registry: ({
        "clock": "barmodules/BarClock.qml",
        "language": "barmodules/BarLanguage.qml",
        "network": "barmodules/BarNetwork.qml",
        "bluetooth": "barmodules/BarBluetooth.qml",
        "volume": "barmodules/BarVolume.qml",
        "battery": "barmodules/BarBattery.qml"
    })

    readonly property var knownModules: [
        "clock", "language", "network", "bluetooth", "volume", "battery"
    ]

    readonly property var defaultZones: ({
        left: ["language", "network", "clock"],
        center: ["mascot"],
        right: ["bluetooth", "volume", "battery"]
    })

    property var left: ["language", "network", "clock"]
    property var center: ["mascot"]
    property var right: ["bluetooth", "volume", "battery"]

    property bool ready: false

    property string _path: ""

    readonly property var order: root.left.concat(root.center, root.right)
    readonly property int mascotIndex: root.order.indexOf("mascot")
    readonly property var leftModules:
        root.mascotIndex > 0 ? root.order.slice(0, root.mascotIndex) : []
    readonly property var rightModules:
        root.mascotIndex >= 0 ? root.order.slice(root.mascotIndex + 1) : []
    readonly property bool hasModules: root.order.length > 1

    function isKnown(module) {
        return module === "mascot" || root.knownModules.indexOf(module) >= 0
    }

    function sourceFor(module) {
        return Object.prototype.hasOwnProperty.call(root.registry, module)
            ? root.registry[module] : ""
    }

    function availableModules() {
        return root.knownModules.concat(["mascot"]).join(" ")
    }

    function toJson() {
        return root._serialize()
    }

    function add(zone, module) {
        const z = root._zoneName(zone)
        const id = String(module || "").trim().toLowerCase()
        if (z.length === 0 || !root.isKnown(id) || root.order.indexOf(id) >= 0)
            return
        const list = root._copyZone(z)
        list.push(id)
        root._setZone(z, list)
        root._persist()
    }

    function remove(zone, module) {
        const z = root._zoneName(zone)
        const id = String(module || "").trim().toLowerCase()
        if (z.length === 0 || id === "mascot")
            return
        const list = root._copyZone(z)
        const idx = list.indexOf(id)
        if (idx < 0)
            return
        list.splice(idx, 1)
        root._setZone(z, list)
        root._persist()
    }

    function move(zone, module, index) {
        const z = root._zoneName(zone)
        const id = String(module || "").trim().toLowerCase()
        if (z.length === 0)
            return
        const list = root._copyZone(z)
        const from = list.indexOf(id)
        if (from < 0)
            return
        list.splice(from, 1)
        const n = parseInt(String(index), 10)
        const to = isNaN(n) ? list.length : Math.max(0, Math.min(list.length, n))
        list.splice(to, 0, id)
        root._setZone(z, list)
        root._persist()
    }

    function setZone(zone, modules) {
        const z = root._zoneName(zone)
        if (z.length === 0)
            return
        root._setZone(z, Array.isArray(modules) ? modules.slice() : [])
        root._persist()
    }

    function reset() {
        root._applyZones(root.defaultZones)
        root._persist()
    }

    function reload() {
        configFile.reload()
    }

    function _zoneName(zone) {
        const z = String(zone || "").trim().toLowerCase()
        return z === "left" || z === "center" || z === "right" ? z : ""
    }

    function _copyZone(zone) {
        const list = zone === "left" ? root.left
            : zone === "center" ? root.center : root.right
        return list.slice()
    }

    function _setZone(zone, list) {
        const normalized = root._normalize({
            left: zone === "left" ? list : root.left,
            center: zone === "center" ? list : root.center,
            right: zone === "right" ? list : root.right
        })
        root._applyNormalized(normalized)
    }

    function _clean(list, seen) {
        const out = []
        if (!Array.isArray(list))
            return out
        for (let i = 0; i < list.length; ++i) {
            const id = String(list[i] || "").trim().toLowerCase()
            if (id === "mascot") {
                if (seen.mascot)
                    continue
                seen.mascot = true
                out.push(id)
            } else if (Object.prototype.hasOwnProperty.call(root.registry, id)
                       && !seen[id]) {
                seen[id] = true
                out.push(id)
            }
        }
        return out
    }

    function _normalize(zones) {
        const source = zones || {}
        const seen = ({})
        const left = root._clean(source.left, seen)
        const center = root._clean(source.center, seen)
        const right = root._clean(source.right, seen)
        if (!seen.mascot)
            center.unshift("mascot")
        return { left: left, center: center, right: right }
    }

    function _applyNormalized(zones) {
        if (JSON.stringify(zones.left) === JSON.stringify(root.left)
                && JSON.stringify(zones.center) === JSON.stringify(root.center)
                && JSON.stringify(zones.right) === JSON.stringify(root.right))
            return
        root.left = zones.left
        root.center = zones.center
        root.right = zones.right
    }

    function _applyZones(zones) {
        root._applyNormalized(root._normalize(zones))
    }

    function _applyText(value) {
        let parsed = null
        const text = String(value || "").trim()
        if (text.length > 0) {
            try {
                parsed = JSON.parse(text)
            } catch (e) {
                parsed = null
            }
        }
        root._applyZones(parsed || root.defaultZones)
    }

    function _serialize() {
        return JSON.stringify({
            version: 1,
            left: root.left,
            center: root.center,
            right: root.right
        }, null, 2) + "\n"
    }

    function _persist() {
        if (!root.ready || root._path.length === 0)
            return
        const next = root._serialize()
        if (configFile.text() === next)
            return
        configFile.setText(next)
    }

    Process {
        id: ensureDir
        running: true
        command: ["mkdir", "-p", root.configHome + "/symbiont"]
        onExited: root._path = root.filePath
    }

    FileView {
        id: configFile
        path: root._path
        preload: true
        watchChanges: true
        atomicWrites: true
        printErrors: false

        onLoaded: {
            root._applyText(configFile.text())
            root.ready = true
            root._persist()
        }

        onLoadFailed: {
            root._applyZones(root.defaultZones)
            root.ready = true
            root._persist()
        }

        onFileChanged: configFile.reload()

        onTextChanged: {
            if (!root.ready)
                return
            root._applyText(configFile.text())
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Io
import qs.ui
import qs.ui.components

Item {
    id: root

    property string host: "—"
    property string os: "—"
    property string kernel: "—"
    property string cpu: "—"
    property string memory: "—"
    property string uptime: "—"
    property string session: "—"
    property string desktop: "—"
    property string shellPath: "—"
    property string load: "—"
    property bool active: false

    Process {
        id: systemInfoProbe
        running: root.active
        command: ["sh", "-c",
            "printf 'HOST=%s\\n' \"$(uname -n)\"; " +
            "printf 'KERNEL=%s\\n' \"$(uname -srm)\"; " +
            ". /etc/os-release; printf 'OS=%s\\n' \"$PRETTY_NAME\"; " +
            "printf 'UPTIME=%s\\n' \"$(uptime -p)\"; " +
            "printf 'CPU=%s\\n' \"$(sed -n 's/^model name[[:space:]]*:[[:space:]]*//p' /proc/cpuinfo | head -n 1)\"; " +
            "printf 'MEMORY=%s MB\\n' \"$(($(sed -n 's/^MemTotal:[[:space:]]*\\([0-9]*\\).*/\\1/p' /proc/meminfo) / 1024))\"; " +
            "printf 'SESSION=%s\\n' \"${XDG_SESSION_TYPE:-unknown}\"; " +
            "printf 'DESKTOP=%s\\n' \"${XDG_CURRENT_DESKTOP:-unknown}\"; " +
            "printf 'SHELL=%s\\n' \"${SHELL:-unknown}\"; " +
            "printf 'LOAD=%s\\n' \"$(cut -d' ' -f1-3 /proc/loadavg)\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const data = {}
                const lines = String(text).trim().split("\n")
                for (const line of lines) {
                    const eq = line.indexOf("=")
                    if (eq < 0)
                        continue
                    data[line.slice(0, eq)] = line.slice(eq + 1)
                }
                root.host = data.HOST || root.host
                root.os = data.OS || root.os
                root.kernel = data.KERNEL || root.kernel
                root.cpu = data.CPU || root.cpu
                root.memory = data.MEMORY || root.memory
                root.uptime = data.UPTIME || root.uptime
                root.session = data.SESSION || root.session
                root.desktop = data.DESKTOP || root.desktop
                root.shellPath = data.SHELL || root.shellPath
                root.load = data.LOAD || root.load
            }
        }
    }

    Column {
        anchors.fill: parent
        spacing: Theme.space.md

        Item {
            width: parent.width
            height: Theme.space.xl

            Text {
                anchors.left: parent.left
                anchors.top: parent.top
                text: "SYSTEM"
                color: Theme.color.textPrimary
                font.family: Theme.font.mono[0]
                font.pixelSize: Theme.type.label.size
                font.weight: Theme.type.label.weight
                font.letterSpacing: Theme.type.label.tracking
                font.capitalization: Font.AllUppercase
                renderType: Text.NativeRendering
            }

            Text {
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                text: "OVERVIEW"
                color: Theme.color.textTertiary
                font.family: Theme.font.mono[0]
                font.pixelSize: Theme.type.labelSm.size
                font.letterSpacing: Theme.type.labelSm.tracking
                font.capitalization: Font.AllUppercase
                renderType: Text.NativeRendering
            }
        }

        Repeater {
            model: ListModel {
                ListElement { name: "OS"; valueKey: "os" }
                ListElement { name: "HOST"; valueKey: "host" }
                ListElement { name: "KERNEL"; valueKey: "kernel" }
                ListElement { name: "CPU"; valueKey: "cpu" }
                ListElement { name: "MEMORY"; valueKey: "memory" }
                ListElement { name: "UPTIME"; valueKey: "uptime" }
                ListElement { name: "SESSION"; valueKey: "session" }
                ListElement { name: "DESKTOP"; valueKey: "desktop" }
                ListElement { name: "SHELL"; valueKey: "shellPath" }
                ListElement { name: "LOAD"; valueKey: "load" }
            }

            SettingsRow {
                required property string name
                required property string valueKey
                width: parent.width
                label: name
                value: root[valueKey] || ""
            }
        }
    }
}

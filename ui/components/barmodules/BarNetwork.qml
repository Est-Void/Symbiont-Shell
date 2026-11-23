import QtQuick
import qs.ui
import qs.ui.components

Item {
    id: root

    property var host: null

    readonly property bool connected:
        root.host ? root.host.barWifiConnected === true : false
    readonly property string name:
        root.host ? String(root.host.barWifiName || "") : ""
    readonly property string label:
        root.connected ? (root.name.length > 0 ? root.name : "WIFI") : "OFFLINE"
    readonly property real textW:
        Math.min(labelMetric.implicitWidth, Theme.size.barModuleTextMax)

    implicitWidth: icon.width + Theme.space.xs + root.textW
    implicitHeight: Theme.size.dropHeight

    BarGlyph {
        id: icon
        x: 0
        anchors.verticalCenter: parent.verticalCenter
        kind: "wifi"
        off: !root.connected
        color: root.connected ? Theme.color.textPrimary : Theme.color.textTertiary
    }

    Text {
        id: labelMetric
        visible: false
        text: root.label
        font.family: Theme.font.mono[0]
        font.pixelSize: Theme.type.monoValue.size
        font.weight: Theme.type.monoValue.weight
        font.letterSpacing: Theme.type.monoValue.tracking
        font.capitalization: Font.AllUppercase
    }

    Text {
        x: icon.width + Theme.space.xs
        width: root.textW
        y: (root.height - implicitHeight) / 2
        text: root.label
        color: root.connected ? Theme.color.textSecondary : Theme.color.textTertiary
        elide: Text.ElideRight
        font.family: Theme.font.mono[0]
        font.pixelSize: Theme.type.monoValue.size
        font.weight: Theme.type.monoValue.weight
        font.letterSpacing: Theme.type.monoValue.tracking
        font.capitalization: Font.AllUppercase
        renderType: Text.NativeRendering
    }

    Accessible.role: Accessible.StaticText
    Accessible.name: root.connected
        ? "Wi-Fi connected: " + root.label
        : "Wi-Fi offline"
}

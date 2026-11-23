import QtQuick
import qs.ui
import qs.ui.components

Item {
    id: root

    property var host: null

    readonly property real level:
        root.host && root.host.barVolume >= 0 ? root.host.barVolume : 0
    readonly property bool muted:
        root.host ? root.host.barVolumeMuted === true : false
    readonly property string label:
        root.muted ? "MUTE" : Math.round(Math.max(0, Math.min(1, root.level)) * 100) + "%"
    readonly property real textW: Math.min(labelMetric.implicitWidth,
                                           Theme.size.barModuleTextMax)

    implicitWidth: icon.width + Theme.space.xs + root.textW
    implicitHeight: Theme.size.dropHeight

    BarGlyph {
        id: icon
        x: 0
        anchors.verticalCenter: parent.verticalCenter
        kind: "volume"
        off: root.muted
        color: root.muted ? Theme.color.textTertiary : Theme.color.textPrimary
    }

    Text {
        id: labelMetric
        visible: false
        text: root.label
        font.family: Theme.font.mono[0]
        font.pixelSize: Theme.type.monoValue.size
        font.weight: Theme.type.monoValue.weight
        font.letterSpacing: Theme.type.monoValue.tracking
    }

    Text {
        x: icon.width + Theme.space.xs
        width: root.textW
        y: (root.height - implicitHeight) / 2
        text: root.label
        color: root.muted ? Theme.color.textTertiary : Theme.color.textSecondary
        font.family: Theme.font.mono[0]
        font.pixelSize: Theme.type.monoValue.size
        font.weight: Theme.type.monoValue.weight
        font.letterSpacing: Theme.type.monoValue.tracking
        renderType: Text.NativeRendering
    }

    Accessible.role: Accessible.StaticText
    Accessible.name: root.muted ? "Volume muted"
        : "Volume " + Math.round(root.level * 100) + " percent"
}

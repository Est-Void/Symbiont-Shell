import QtQuick
import qs.ui

Item {
    id: root

    property var host: null

    readonly property string label: {
        const value = root.host ? String(root.host.barLanguage || "") : ""
        return value.length > 0 ? value : "--"
    }

    implicitWidth: labelText.implicitWidth
    implicitHeight: Theme.size.dropHeight

    Text {
        id: labelText
        y: (root.height - implicitHeight) / 2
        text: root.label
        color: Theme.color.textSecondary
        font.family: Theme.font.mono[0]
        font.pixelSize: Theme.type.monoValue.size
        font.weight: Theme.type.monoValue.weight
        font.letterSpacing: Theme.type.monoValue.tracking
        font.capitalization: Font.AllUppercase
        renderType: Text.NativeRendering
    }

    Accessible.role: Accessible.StaticText
    Accessible.name: "Keyboard layout " + root.label
}

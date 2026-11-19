pragma ComponentBehavior: Bound

import QtQuick
import qs.ui

BracketFrame {
    id: root

    property string label: ""

    readonly property real pillPad: Theme.space.snug

    pillWidth: Math.max(root.pillHeight, langText.implicitWidth + root.pillPad * 2)
    pillHeight: Theme.size.connectionIcon + Theme.space.xxs

    Text {
        id: langText
        anchors.centerIn: parent
        text: root.label
        color: Theme.color.accentText
        font.family: Theme.font.mono[0]
        font.pixelSize: Theme.type.monoValue.size
        font.letterSpacing: Theme.type.monoValue.tracking
        font.capitalization: Font.AllUppercase
    }
}

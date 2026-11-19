pragma ComponentBehavior: Bound

import QtQuick
import qs.ui

Item {
    id: root

    property string label: ""
    property bool selected: false
    signal clicked()

    implicitWidth: Theme.size.settingsRailWidth - Theme.space.lg
    implicitHeight: Theme.size.settingsRowHeight
    activeFocusOnTab: true
    focus: root.selected
    Accessible.role: Accessible.ListItem
    Accessible.name: root.label
    Accessible.selected: root.selected

    Rectangle {
        id: pill
        anchors.fill: parent
        radius: height / 2
        color: root.selected ? Theme.color.surfaceInverse
            : selectorTap.pressed ? Theme.color.surface3
            : selectorHover.hovered ? Theme.color.surface2
            : Theme.color.transparent
        border.width: root.selected ? 0 : Theme.size.hairline
        border.color: Theme.color.borderSubtle

        Text {
            anchors.centerIn: parent
            text: root.label
            color: root.selected ? Theme.color.textInverse : Theme.color.textPrimary
            font.family: Theme.font.mono[0]
            font.pixelSize: Theme.type.label.size
            font.weight: Theme.type.label.weight
            font.letterSpacing: Theme.type.label.tracking
            font.capitalization: Font.AllUppercase
            renderType: Text.NativeRendering
        }
    }

    Rectangle {
        anchors.fill: pill
        anchors.margins: -Theme.size.focusRingOffset
        radius: pill.radius + Theme.size.focusRingOffset
        color: Theme.color.transparent
        border.width: root.activeFocus ? Theme.size.focusRingWidth : 0
        border.color: Theme.color.accent
        visible: root.activeFocus
    }

    HoverHandler {
        id: selectorHover
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        id: selectorTap
        onTapped: {
            root.forceActiveFocus()
            root.clicked()
        }
    }

    Keys.onReturnPressed: root.clicked()
    Keys.onSpacePressed: root.clicked()
}

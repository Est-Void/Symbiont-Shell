pragma ComponentBehavior: Bound

import QtQuick
import qs.ui

Item {
    id: root

    property bool checked: false
    property string label: ""

    signal toggled(bool value)

    implicitWidth: Theme.size.toggleWidth
    implicitHeight: Theme.size.toggleHeight
    activeFocusOnTab: root.enabled
    opacity: root.enabled ? 1 : Theme.size.disabledOpacity

    Accessible.role: Accessible.CheckBox
    Accessible.name: root.label
    Accessible.checkable: true
    Accessible.checked: root.checked

    readonly property int duration: Theme.motion.reducedMotion
        ? Theme.motion.instant : Theme.motion.fast

    function toggle() {
        if (!root.enabled)
            return
        root.toggled(!root.checked)
    }

    Keys.onReturnPressed: root.toggle()
    Keys.onEnterPressed: root.toggle()
    Keys.onSpacePressed: root.toggle()

    Rectangle {
        id: track
        anchors.fill: parent
        radius: height / 2
        color: root.checked ? Theme.color.surfaceInverse : Theme.color.surface3
        border.width: Theme.size.hairline
        border.color: root.checked ? Theme.color.transparent : Theme.color.borderDefault

        Behavior on color {
            ColorAnimation { duration: root.duration }
        }
    }

    Rectangle {
        id: knob
        width: Theme.size.toggleKnob
        height: Theme.size.toggleKnob
        y: (root.height - height) / 2
        x: root.checked ? root.width - width - Theme.size.toggleInset
                        : Theme.size.toggleInset
        radius: height / 2
        color: root.checked ? Theme.color.textInverse : Theme.color.textSecondary

        Behavior on x {
            NumberAnimation {
                duration: root.duration
                easing.type: Easing.OutCubic
            }
        }
        Behavior on color {
            ColorAnimation { duration: root.duration }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Theme.size.focusRingOffset
        radius: height / 2
        color: Theme.color.transparent
        border.width: Theme.size.focusRingWidth
        border.color: Theme.color.accent
        visible: root.activeFocus
    }

    HoverHandler {
        enabled: root.enabled
        cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
        enabled: root.enabled
        onTapped: {
            root.forceActiveFocus()
            root.toggle()
        }
    }
}

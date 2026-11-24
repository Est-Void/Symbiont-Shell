pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.ui
import qs.ui.components

PanelWindow {
    id: root

    property bool open: false
    property bool alive: false
    property real mascotStartX: 0
    property real mascotStartY: 0
    property bool placeholderOn: false
    property bool floatingMode: false
    property bool reserveSpace: false

    signal closeRequested()
    signal floatingModeToggled(bool value)
    signal reserveSpaceToggled(bool value)

    readonly property real menuWidth: Theme.size.debugWidth
    readonly property real menuHeight: Theme.size.debugHeight
    readonly property real menuX: Math.round((root.width - root.menuWidth) / 2)
    readonly property real menuY: Math.round((root.height - root.menuHeight) / 2)
    readonly property real mascotTargetX:
        root.menuX + root.menuWidth - Theme.size.debugPadding - Theme.size.dropWidth / 2
    readonly property real mascotTargetY:
        root.menuY + Theme.size.debugHeaderHeight / 2

    property real flow: root.open ? 1 : 0
    Behavior on flow {
        NumberAnimation {
            duration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.slow
            easing.type: Easing.InOutCubic
        }
    }

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"
    visible: root.alive

    WlrLayershell.namespace: "symbiont-debug"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    mask: Region {
        x: 0
        y: 0
        width: root.alive ? root.width : 0
        height: root.alive ? root.height : 0
    }

    function openMenu() {
        if (root.open)
            return
        closeTimer.stop()
        root.alive = true
        root.open = true
        focusTimer.restart()
    }

    function togglePlaceholder() {
        root.placeholderOn = !root.placeholderOn
    }

    function togglePlaceholderIfOpen() {
        if (root.open)
            root.togglePlaceholder()
    }

    function closeMenu() {
        if (!root.open)
            return
        root.open = false
        closeTimer.restart()
        root.closeRequested()
    }

    function toggle() {
        if (root.open)
            root.closeMenu()
        else
            root.openMenu()
    }

    Timer {
        id: closeTimer
        interval: (Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.slow)
                  + Theme.motion.instant
        onTriggered: root.alive = false
    }

    Timer {
        id: focusTimer
        interval: Theme.motion.fast
        onTriggered: card.forceActiveFocus()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.color.scrim
        opacity: root.flow
        visible: root.alive
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.open
        onClicked: root.closeMenu()
    }

    FocusScope {
        id: card
        x: root.menuX
        y: root.menuY + (1 - root.flow) * Theme.size.debugEnterOffset
        width: root.menuWidth
        height: root.menuHeight
        opacity: root.flow
        scale: Theme.size.debugEnterScale + (1 - Theme.size.debugEnterScale) * root.flow
        transformOrigin: Item.Center
        focus: root.open
        activeFocusOnTab: root.open

        Accessible.role: Accessible.Dialog
        Accessible.name: "Debug menu"

        Keys.onEscapePressed: root.closeMenu()
        Keys.onSpacePressed: root.togglePlaceholder()
        Keys.onReturnPressed: root.togglePlaceholder()
        Keys.onEnterPressed: root.togglePlaceholder()

        Squircle {
            anchors.fill: parent
            n: 4
            radius: Theme.size.debugRadius
            fillColor: Theme.color.surface1
            strokeColor: Theme.color.borderSubtle
            strokeWidth: Theme.size.hairline
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Item {
            id: header
            width: parent.width
            height: Theme.size.debugHeaderHeight

            Column {
                anchors.centerIn: parent
                spacing: Theme.space.xs

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "DEBUG"
                    color: Theme.color.textPrimary
                    font.family: Theme.font.dot[0]
                    font.pixelSize: Theme.size.debugTitleSize
                    font.weight: 400
                    font.letterSpacing: Theme.size.debugTitleTracking
                    font.capitalization: Font.AllUppercase
                    renderType: Text.QtRendering
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "SYMBIONT SHELL"
                    color: Theme.color.textTertiary
                    font.family: Theme.font.mono[0]
                    font.pixelSize: Theme.type.labelSm.size
                    font.letterSpacing: Theme.type.labelSm.tracking
                    font.capitalization: Font.AllUppercase
                    renderType: Text.NativeRendering
                }
            }
        }

        Rectangle {
            x: 0
            y: header.height
            width: parent.width
            height: Theme.size.hairline
            color: Theme.color.borderSubtle
        }

        Column {
            id: body
            x: Theme.size.debugPadding
            y: header.height + Theme.space.xl
            width: parent.width - Theme.size.debugPadding * 2
            spacing: Theme.space.md

            Rectangle {
                id: toggleRow
                width: body.width
                height: Theme.size.debugRowHeight
                radius: Theme.radius.md
                color: Theme.color.surface2
                border.width: Theme.size.hairline
                border.color: Theme.color.borderDefault

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.space.md
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.space.xxs

                    Text {
                        text: "PLACEHOLDER"
                        color: Theme.color.textPrimary
                        font.family: Theme.font.mono[0]
                        font.pixelSize: Theme.type.label.size
                        font.weight: Theme.type.label.weight
                        font.letterSpacing: Theme.type.label.tracking
                        font.capitalization: Font.AllUppercase
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: "NOTHING CONNECTED"
                        color: Theme.color.textTertiary
                        font.family: Theme.font.mono[0]
                        font.pixelSize: Theme.type.labelSm.size
                        font.letterSpacing: Theme.type.labelSm.tracking
                        font.capitalization: Font.AllUppercase
                        renderType: Text.NativeRendering
                    }
                }

                NToggle {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.space.md
                    anchors.verticalCenter: parent.verticalCenter
                    checked: root.placeholderOn
                    label: "Placeholder toggle"
                    onToggled: function (value) { root.placeholderOn = value }
                }
            }

            Rectangle {
                id: appearanceRow
                width: body.width
                height: Theme.size.debugRowHeight
                radius: Theme.radius.md
                color: Theme.color.surface2
                border.width: Theme.size.hairline
                border.color: Theme.color.borderDefault

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.space.md
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.space.xxs

                    Text {
                        text: "APPEARANCE"
                        color: Theme.color.textPrimary
                        font.family: Theme.font.mono[0]
                        font.pixelSize: Theme.type.label.size
                        font.weight: Theme.type.label.weight
                        font.letterSpacing: Theme.type.label.tracking
                        font.capitalization: Font.AllUppercase
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: root.floatingMode ? "FLOATING · DETACHED" : "ATTACHED · TOP EDGE"
                        color: Theme.color.textTertiary
                        font.family: Theme.font.mono[0]
                        font.pixelSize: Theme.type.labelSm.size
                        font.letterSpacing: Theme.type.labelSm.tracking
                        font.capitalization: Font.AllUppercase
                        renderType: Text.NativeRendering
                    }
                }

                NToggle {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.space.md
                    anchors.verticalCenter: parent.verticalCenter
                    checked: root.floatingMode
                    label: "Floating appearance"
                    onToggled: function (value) { root.floatingModeToggled(value) }
                }
            }

            Rectangle {
                id: paddingRow
                width: body.width
                height: Theme.size.debugRowHeight
                radius: Theme.radius.md
                color: Theme.color.surface2
                border.width: Theme.size.hairline
                border.color: Theme.color.borderDefault

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.space.md
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.space.xxs

                    Text {
                        text: "BAR PADDING"
                        color: Theme.color.textPrimary
                        font.family: Theme.font.mono[0]
                        font.pixelSize: Theme.type.label.size
                        font.weight: Theme.type.label.weight
                        font.letterSpacing: Theme.type.label.tracking
                        font.capitalization: Font.AllUppercase
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: "EDGE INSETS · "
                              + BarConfig.paddingSteps[0] + "–"
                              + BarConfig.paddingSteps[BarConfig.paddingSteps.length - 1]
                              + " PX"
                        color: Theme.color.textTertiary
                        font.family: Theme.font.mono[0]
                        font.pixelSize: Theme.type.labelSm.size
                        font.letterSpacing: Theme.type.labelSm.tracking
                        font.capitalization: Font.AllUppercase
                        renderType: Text.NativeRendering
                    }
                }

                NStepper {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.space.md
                    anchors.verticalCenter: parent.verticalCenter
                    values: BarConfig.paddingSteps
                    value: BarConfig.edgePadding
                    label: "Bar edge padding"
                    onStepped: function (value) { BarConfig.setEdgePadding(value) }
                }
            }

            Rectangle {
                id: gapRow
                width: body.width
                height: Theme.size.debugRowHeight
                radius: Theme.radius.md
                color: Theme.color.surface2
                border.width: Theme.size.hairline
                border.color: Theme.color.borderDefault

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.space.md
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.space.xxs

                    Text {
                        text: "MODULE GAP"
                        color: Theme.color.textPrimary
                        font.family: Theme.font.mono[0]
                        font.pixelSize: Theme.type.label.size
                        font.weight: Theme.type.label.weight
                        font.letterSpacing: Theme.type.label.tracking
                        font.capitalization: Font.AllUppercase
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: "BETWEEN MODULES · "
                              + BarConfig.gapSteps[0] + "–"
                              + BarConfig.gapSteps[BarConfig.gapSteps.length - 1]
                              + " PX"
                        color: Theme.color.textTertiary
                        font.family: Theme.font.mono[0]
                        font.pixelSize: Theme.type.labelSm.size
                        font.letterSpacing: Theme.type.labelSm.tracking
                        font.capitalization: Font.AllUppercase
                        renderType: Text.NativeRendering
                    }
                }

                NStepper {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.space.md
                    anchors.verticalCenter: parent.verticalCenter
                    values: BarConfig.gapSteps
                    value: BarConfig.moduleGap
                    label: "Gap between bar modules"
                    onStepped: function (value) { BarConfig.setModuleGap(value) }
                }
            }

            Rectangle {
                id: reserveRow
                width: body.width
                height: Theme.size.debugRowHeight
                radius: Theme.radius.md
                color: Theme.color.surface2
                border.width: Theme.size.hairline
                border.color: Theme.color.borderDefault

                Column {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.space.md
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.space.xxs

                    Text {
                        text: "WINDOW SPACE"
                        color: Theme.color.textPrimary
                        font.family: Theme.font.mono[0]
                        font.pixelSize: Theme.type.label.size
                        font.weight: Theme.type.label.weight
                        font.letterSpacing: Theme.type.label.tracking
                        font.capitalization: Font.AllUppercase
                        renderType: Text.NativeRendering
                    }

                    Text {
                        text: root.reserveSpace
                              ? "RESERVED · WINDOWS BELOW BAR"
                              : "FREE · BAR OVERLAPS WINDOWS"
                        color: Theme.color.textTertiary
                        font.family: Theme.font.mono[0]
                        font.pixelSize: Theme.type.labelSm.size
                        font.letterSpacing: Theme.type.labelSm.tracking
                        font.capitalization: Font.AllUppercase
                        renderType: Text.NativeRendering
                    }
                }

                NToggle {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.space.md
                    anchors.verticalCenter: parent.verticalCenter
                    checked: root.reserveSpace
                    label: "Reserve screen space for the bar"
                    onToggled: function (value) { root.reserveSpaceToggled(value) }
                }
            }
        }

        Text {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: Theme.size.debugPadding
            anchors.bottomMargin: Theme.space.lg
            text: "SPACE TOGGLE · ESC OR CLICK OUTSIDE"
            color: Theme.color.textTertiary
            font.family: Theme.font.mono[0]
            font.pixelSize: Theme.type.labelSm.size
            font.letterSpacing: Theme.type.labelSm.tracking
            font.capitalization: Font.AllUppercase
            renderType: Text.NativeRendering
        }
    }

    Mascot {
        id: mascot
        width: Theme.size.dropWidth
        height: Theme.size.dropHeight
        x: root.mascotStartX - width / 2
           + (root.mascotTargetX - width / 2 - (root.mascotStartX - width / 2)) * root.flow
        y: root.mascotStartY - height / 2
           + (root.mascotTargetY - height / 2 - (root.mascotStartY - height / 2)) * root.flow
        screen: root.screen
        visible: root.alive
        opacity: root.flow
    }
}

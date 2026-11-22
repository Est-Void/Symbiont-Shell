pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.ui
import qs.ui.components

PanelWindow {
    id: root

    property bool open: false
    property bool alive: false
    property bool floating: false
    property real topAnchorY: 0
    property real mascotStartX: 0
    property real mascotStartY: 0
    property var backdropMascot: null
    readonly property var mascotItem: mascot

    signal closeRequested()

    readonly property real panelPadding: Theme.size.launcherPadding
    readonly property real fullWidth: Math.min(Theme.size.launcherWidth,
                                                Math.max(0, root.width - Theme.space.xl * 2))
    readonly property real fullX: Math.round((root.width - root.fullWidth) / 2)
    readonly property real fullY:
        root.floating ? root.topAnchorY + Theme.size.dropHeight + Theme.size.launcherGap : 0
    readonly property real topInset: root.floating ? root.panelPadding : 0
    readonly property real maxFullHeight:
        Math.max(0, root.height - root.fullY - Theme.space.xl)
    readonly property real maxHeight:
        Math.max(Theme.size.dropHeight,
                 Math.min(Math.round(root.height * Theme.size.launcherHeightRatio),
                          root.maxFullHeight))
    readonly property real listPitch:
        Theme.size.launcherRowHeight + Theme.size.launcherRowGap
    readonly property real listSpace:
        Math.max(0, root.maxHeight - root.chromeHeight)
    readonly property int fitRows:
        Math.max(1, Math.floor((root.listSpace + Theme.size.launcherRowGap) / root.listPitch))
    readonly property int wantRows:
        root.filteredClips.length === 0 ? 3
            : Math.min(root.fitRows, root.filteredClips.length)
    readonly property real listHeight:
        root.wantRows * root.listPitch - Theme.size.launcherRowGap
    readonly property real fullHeight:
        Math.max(Theme.size.dropHeight, root.chromeHeight + root.listHeight)
    readonly property real chromeHeight:
        root.topInset + Theme.size.launcherHeaderHeight
        + Theme.space.xs + Theme.space.xxs + Theme.space.sm
        + Theme.size.launcherSearchHeight
        + Theme.size.launcherGap * 2
        + Theme.space.xxs + Theme.space.xs
        + Theme.size.launcherFooterHeight + Theme.space.snug

    readonly property string query: searchField.text
    readonly property var filteredClips: {
        const src = ClipHistory.entries
        const out = []
        const q = String(root.query).trim().toLowerCase()
        for (let i = 0; i < src.length; ++i) {
            const e = src[i]
            if (!e)
                continue
            if (q.length > 0) {
                const hay = (String(e.preview || "") + " "
                             + String(e.types || "") + " "
                             + String(e.kind || "")).toLowerCase()
                if (hay.indexOf(q) === -1)
                    continue
            }
            out.push(e)
        }
        return out
    }

    property real flow: root.open ? 1 : 0
    Behavior on flow {
        NumberAnimation {
            duration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.slow
            easing.type: Easing.InOutCubic
        }
    }

    readonly property real contentOpacity:
        Math.max(0, Math.min(1, (root.flow - 0.35) / 0.65))
    readonly property real startWidth:
        root.floating ? Theme.size.dropHeight : Theme.size.dropWidth
    readonly property real panelWidth:
        root.startWidth + (root.fullWidth - root.startWidth) * root.flow
    readonly property real panelHeight:
        Theme.size.dropHeight + (root.fullHeight - Theme.size.dropHeight) * root.flow
    readonly property real panelX: Math.round((root.width - root.panelWidth) / 2)
    readonly property real panelY:
        root.floating
            ? root.topAnchorY + (Theme.size.dropHeight + Theme.size.launcherGap) * root.flow
            : 0

    readonly property real surfaceShoulder:
        root.floating ? 0
                      : Theme.size.dropTopRadius
                        + (Theme.size.launcherShoulder - Theme.size.dropTopRadius) * root.flow
    readonly property real surfaceBottomRadius:
        root.floating ? Theme.size.launcherRadius
                      : Theme.size.dropBodyRadius
                        + (Theme.size.launcherRadius - Theme.size.dropBodyRadius) * root.flow

    readonly property real mascotTargetX:
        root.fullX + root.panelPadding + Theme.size.dropWidth / 2
    readonly property real mascotTargetY:
        root.fullY + root.topInset + Theme.size.launcherHeaderHeight / 2

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"
    visible: root.alive

    // Warm surface, same lifecycle as the launcher: once mapped the layer
    // stays alive; when parked nothing is drawn and the mask is empty.
    readonly property bool interactive: root.open || root.flow > 0.001

    WlrLayershell.namespace: "symbiont-clipboard"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive
                                           : WlrKeyboardFocus.None

    mask: Region {
        x: 0
        y: 0
        width: root.interactive ? root.width : 0
        height: root.interactive ? root.height : 0
    }

    function openClipboard() {
        if (root.open) {
            focusTimer.restart()
            return
        }
        closeTimer.stop()
        if (root.backdropMascot)
            mascot.syncVisualFrom(root.backdropMascot)
        root.alive = true
        root.open = true
        focusTimer.restart()
    }

    function closeClipboard() {
        if (!root.open)
            return
        root.open = false
        searchField.text = ""
        list.reset()
        closeTimer.restart()
        root.closeRequested()
    }

    function toggleClipboard() {
        if (root.open)
            root.closeClipboard()
        else
            root.openClipboard()
    }

    function handleEscape() {
        if (root.query.length > 0) {
            searchField.clear()
            return
        }
        root.closeClipboard()
    }

    function clipEntry(entry) {
        if (!entry)
            return
        ClipHistory.copyToClipboard(entry)
        root.closeClipboard()
    }

    function aimMascotAt(px, py) {
        if (!root.alive)
            return
        mascot.aimLocal(px - mascot.x, py - mascot.y)
    }

    Timer {
        id: closeTimer
        interval: (Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.slow)
                  + Theme.motion.instant
        onTriggered: {
            if (root.backdropMascot)
                root.backdropMascot.syncVisualFrom(mascot)
        }
    }

    Timer {
        id: focusTimer
        interval: Theme.motion.fast
        onTriggered: searchField.focusInput()
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.color.scrim
        opacity: root.flow
        visible: root.flow > 0.001
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.open
        onClicked: root.closeClipboard()

        HoverHandler {
            id: scrimHover
            onPointChanged: root.aimMascotAt(point.position.x, point.position.y)
            onHoveredChanged: {
                if (!hovered && !panelHover.hovered)
                    mascot.lookAt(0, 0)
            }
        }
    }

    FocusScope {
        id: panel
        x: root.panelX
        y: root.panelY
        width: root.panelWidth
        height: root.panelHeight
        clip: true
        visible: root.flow > 0.001
        focus: root.open
        activeFocusOnTab: root.open

        Accessible.role: Accessible.Dialog
        Accessible.name: "Clipboard"

        Keys.onEscapePressed: root.handleEscape()

        Squircle {
            anchors.fill: parent
            visible: root.floating
            n: 4
            radius: Theme.size.launcherRadius
            segments: 44
            strokeWidth: root.flow >= 1 ? Theme.size.hairline : 0
            fillColor: Theme.color.surface1
            strokeColor: Theme.color.borderSubtle
        }

        AttachedSurface {
            anchors.fill: parent
            visible: !root.floating
            n: 4
            segments: 40
            shoulder: root.surfaceShoulder
            bottomRadius: root.surfaceBottomRadius
            strokeWidth: root.flow >= 1 ? Theme.size.hairline : 0
            fillColor: Theme.color.surface1
            strokeColor: Theme.color.borderSubtle
        }

        HoverHandler {
            id: panelHover
            onPointChanged: root.aimMascotAt(panel.x + point.position.x,
                                             panel.y + point.position.y)
            onHoveredChanged: {
                if (!hovered && !scrimHover.hovered)
                    mascot.lookAt(0, 0)
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        Item {
            id: content
            x: Math.round((root.panelWidth - root.fullWidth) / 2)
            y: 0
            width: root.fullWidth
            height: root.fullHeight
            opacity: root.contentOpacity

            Item {
                id: header
                x: root.panelPadding
                y: root.topInset
                width: Math.max(0, content.width - root.panelPadding * 2)
                height: Theme.size.launcherHeaderHeight

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.size.dropWidth + Theme.space.md
                    anchors.verticalCenter: parent.verticalCenter
                    text: "CLIPBOARD"
                    color: Theme.color.textPrimary
                    font.family: Theme.font.mono[0]
                    font.pixelSize: Theme.type.label.size
                    font.weight: Theme.type.label.weight
                    font.letterSpacing: Theme.type.label.tracking
                    font.capitalization: Font.AllUppercase
                    renderType: Text.NativeRendering
                }

                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: Theme.space.sm

                    DotText {
                        anchors.verticalCenter: parent.verticalCenter
                        width: implicitWidth
                        height: implicitHeight
                        value: String(root.filteredClips.length)
                        size: Theme.type.numericDot.size
                        gapRatio: 0.1
                        color: Theme.color.textPrimary
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "CLIPS"
                        color: Theme.color.textTertiary
                        font.family: Theme.font.mono[0]
                        font.pixelSize: Theme.type.labelSm.size
                        font.weight: Theme.type.labelSm.weight
                        font.letterSpacing: Theme.type.labelSm.tracking
                        font.capitalization: Font.AllUppercase
                        renderType: Text.NativeRendering
                    }
                }
            }

            DotRule {
                id: headerRule
                x: root.panelPadding
                y: header.y + header.height + Theme.space.xs
                width: Math.max(0, content.width - root.panelPadding * 2)
                color: Theme.color.borderSubtle
            }

            NTextField {
                id: searchField
                x: root.panelPadding
                y: headerRule.y + headerRule.height + Theme.space.sm
                width: Math.max(0, content.width - root.panelPadding * 2)
                height: Theme.size.launcherSearchHeight
                placeholder: "SEARCH CLIPBOARD"
                leadingDots: true

                onNavigationRequested: function (delta) { list.move(delta) }
                onAccepted: list.activateCurrent()
                onTextChanged: list.reset()
            }

            Item {
                id: list

                x: root.panelPadding
                y: searchField.y + searchField.height + Theme.size.launcherGap
                width: Math.max(0, content.width - root.panelPadding * 2)
                height: root.listHeight

                function move(delta) {
                    if (root.filteredClips.length === 0)
                        return
                    currentIndex = Math.max(0, Math.min(root.filteredClips.length - 1,
                                                        currentIndex + delta))
                    view.positionViewAtIndex(currentIndex, ListView.Contain)
                }

                function reset() {
                    currentIndex = 0
                    view.positionViewAtBeginning()
                }

                function activateCurrent() {
                    if (currentIndex < 0 || currentIndex >= root.filteredClips.length)
                        return
                    root.clipEntry(root.filteredClips[currentIndex])
                }

                property int currentIndex: 0

                ListView {
                    id: view
                    anchors.fill: parent
                    anchors.rightMargin: Theme.size.scrollbarHoverWidth + Theme.space.xs
                    clip: true
                    model: root.filteredClips
                    spacing: Theme.size.launcherRowGap
                    boundsBehavior: Flickable.StopAtBounds

                    ScrollBar.vertical: ScrollBar {
                        id: vbar
                        policy: ScrollBar.AsNeeded
                        width: vbar.hovered
                            ? Theme.size.scrollbarHoverWidth : Theme.size.scrollbarWidth
                        contentItem: Rectangle {
                            implicitWidth: vbar.width
                            radius: Theme.radius.pill
                            color: Theme.color.borderStrong
                        }
                        background: null

                        Behavior on width {
                            NumberAnimation {
                                duration: Theme.motion.reducedMotion
                                    ? Theme.motion.instant : Theme.motion.base
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    delegate: ClipboardRow {
                        required property var modelData
                        required property int index

                        entry: modelData
                        number: index + 1
                        width: view.width
                        current: index === list.currentIndex
                        showDivider: index < root.filteredClips.length - 1
                        onActivated: root.clipEntry(root.filteredClips[index])
                    }
                }

                Column {
                    anchors.centerIn: parent
                    spacing: Theme.space.md
                    visible: root.filteredClips.length === 0

                    DotCluster {
                        anchors.horizontalCenter: parent.horizontalCenter
                        pattern: ["0011100", "0110110", "1100011", "1000001",
                                  "1100011", "0110110", "0011100"]
                        dotSize: Theme.space.xxs
                        pitch: Theme.space.xs
                        color: Theme.color.borderStrong
                    }

                    Column {
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: Theme.space.sm

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.query.length > 0 ? "NO RESULTS" : "CLIPBOARD EMPTY"
                            horizontalAlignment: Text.AlignHCenter
                            color: Theme.color.textSecondary
                            font.family: Theme.font.mono[0]
                            font.pixelSize: Theme.type.label.size
                            font.weight: Theme.type.label.weight
                            font.letterSpacing: Theme.type.label.tracking
                            font.capitalization: Font.AllUppercase
                            renderType: Text.NativeRendering
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: root.query.length > 0
                                ? "QUERY \u2014 \u201C" + root.query + "\u201D"
                                : "COPY SOMETHING TO START"
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            color: Theme.color.textTertiary
                            font.family: Theme.font.mono[0]
                            font.pixelSize: Theme.type.labelSm.size
                            font.weight: Theme.type.labelSm.weight
                            font.letterSpacing: Theme.type.labelSm.tracking
                            font.capitalization: Font.AllUppercase
                            renderType: Text.NativeRendering
                        }
                    }
                }
            }

            DotRule {
                id: footerRule
                x: root.panelPadding
                y: list.y + list.height + Theme.size.launcherGap
                width: Math.max(0, content.width - root.panelPadding * 2)
                color: Theme.color.borderSubtle
            }

            Text {
                x: root.panelPadding
                y: footerRule.y + footerRule.height + Theme.space.xs
                width: Math.max(0, content.width - root.panelPadding * 2)
                height: Theme.size.launcherFooterHeight
                verticalAlignment: Text.AlignVCenter
                text: "↑↓ SELECT · ENTER COPY · ESC CLOSE"
                elide: Text.ElideRight
                color: Theme.color.textTertiary
                font.family: Theme.font.mono[0]
                font.pixelSize: Theme.type.labelSm.size
                font.weight: Theme.type.labelSm.weight
                font.letterSpacing: Theme.type.labelSm.tracking
                font.capitalization: Font.AllUppercase
                renderType: Text.NativeRendering
            }
        }
    }

    Mascot {
        id: mascot
        width: Theme.size.dropWidth
        height: Theme.size.launcherHeaderHeight
        x: root.mascotStartX - width / 2
           + (root.mascotTargetX - root.mascotStartX) * root.flow
        y: root.mascotStartY - height / 2
           + (root.mascotTargetY - root.mascotStartY) * root.flow
        screen: root.screen
        visible: root.flow > 0.001
    }
}

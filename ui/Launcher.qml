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
    readonly property int listRows:
        Math.max(1, Math.floor((root.listSpace + Theme.size.launcherRowGap) / root.listPitch))
    readonly property real listHeight:
        root.listRows * root.listPitch - Theme.size.launcherRowGap
    readonly property real fullHeight:
        Math.max(Theme.size.dropHeight, root.chromeHeight + root.listHeight)
    readonly property real chromeHeight:
        root.topInset + Theme.size.launcherHeaderHeight
        + Theme.space.xs + Theme.space.xxs + Theme.space.sm
        + Theme.size.launcherSearchHeight
        + Theme.size.launcherGap * 2
        + Theme.space.xxs + Theme.space.xs
        + Theme.size.launcherFooterHeight + Theme.space.snug

    readonly property var allApps: DesktopEntries.applications.values
    readonly property string query: searchField.text
    readonly property var filteredApps: {
        const out = []
        const source = root.allApps
        if (!source)
            return out
        const q = String(root.query).trim().toLowerCase()
        for (let i = 0; i < source.length; ++i) {
            const entry = source[i]
            if (!entry || entry.noDisplay === true)
                continue
            const name = String(entry.name || "")
            if (name.length === 0)
                continue
            if (q.length > 0) {
                const hay = (name + " " + String(entry.genericName || "")
                             + " " + String(entry.comment || "")).toLowerCase()
                if (hay.indexOf(q) === -1)
                    continue
            }
            out.push(entry)
        }
        out.sort(function (a, b) {
            const an = String(a.name || "").toLowerCase()
            const bn = String(b.name || "").toLowerCase()
            return an < bn ? -1 : (an > bn ? 1 : 0)
        })
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

    // Warm surface: once mapped the layer stays alive so re-opens skip the
    // ~90ms Wayland re-map; when parked nothing is drawn and the mask is
    // empty, so there is no visual and no input cost.
    readonly property bool interactive: root.open || root.flow > 0.001

    WlrLayershell.namespace: "symbiont-launcher"
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

    function openLauncher() {
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

    function closeLauncher() {
        if (!root.open)
            return
        root.open = false
        // Reset the query while the panel is fading out, so the next open
        // starts from a clean, already-built state instead of rebuilding it.
        searchField.text = ""
        list.reset()
        closeTimer.restart()
        root.closeRequested()
    }

    function toggleLauncher() {
        if (root.open)
            root.closeLauncher()
        else
            root.openLauncher()
    }

    function handleEscape() {
        if (root.query.length > 0) {
            searchField.clear()
            return
        }
        root.closeLauncher()
    }

    function launchApp(app) {
        if (!app)
            return
        app.execute()
        root.closeLauncher()
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
        onClicked: root.closeLauncher()

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
        Accessible.name: "Launcher"

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
                    text: "LAUNCHER"
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
                        value: String(root.filteredApps.length)
                        size: Theme.type.numericDot.size
                        gapRatio: 0.1
                        color: Theme.color.textPrimary
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: "APPS"
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
                placeholder: "SEARCH APPLICATIONS"
                leadingDots: true

                onNavigationRequested: function (delta) { list.move(delta) }
                onAccepted: list.activateCurrent()
                onTextChanged: list.reset()
            }

            LauncherList {
                id: list
                x: root.panelPadding
                y: searchField.y + searchField.height + Theme.size.launcherGap
                width: Math.max(0, content.width - root.panelPadding * 2)
                height: root.listHeight
                apps: root.filteredApps
                query: root.query
                onActivated: function (app) { root.launchApp(app) }
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
                text: "↑↓ SELECT · ENTER LAUNCH · ESC CLOSE"
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

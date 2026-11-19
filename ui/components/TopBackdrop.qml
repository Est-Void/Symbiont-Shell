import QtQuick
import QtQuick.Shapes
import qs.ui
import qs.ui.components

Item {
    id: root

    property var screen: null
    property string mode: "droplet"
    property string mascotPosition: "center"
    property bool volumeActive: false
    property real volume: 0
    property string osdKind: "vol"
    property bool osdMuted: false
    property string osdLabel: ""
    property bool chargeStatus: false
    readonly property bool chargeActive: root.volumeActive && root.osdKind === "charge"
    readonly property bool langActive: root.volumeActive && root.osdKind === "lang"
    readonly property bool wifiActive: root.volumeActive && root.osdKind === "wifi"
    readonly property bool btActive: root.volumeActive && root.osdKind === "bt"
    readonly property bool statusActive: root.langActive || root.wifiActive || root.btActive
    readonly property real statusWidth: root.langActive ? langCtl.implicitWidth
        : root.wifiActive ? wifiCtl.implicitWidth
        : btCtl.implicitWidth
    readonly property bool menuOpen: root.mode === "menu"
    readonly property bool settingsOpen: root.mode === "settings"
    readonly property bool centeredMode: root.mode === "menu" || root.settingsOpen || root.volumeActive
    readonly property int expandDuration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.slow
    readonly property int expandEasing: Easing.InOutCubic
    property bool panelContentVisible: false

    onModeChanged: {
        if (root.mode === "menu" || root.mode === "settings") {
            root.panelContentVisible = false
            panelRevealTimer.restart()
        } else {
            panelRevealTimer.stop()
            root.panelContentVisible = false
        }
    }

    Timer {
        id: panelRevealTimer
        interval: root.expandDuration
        repeat: false
        onTriggered: root.panelContentVisible = true
    }


    // 1 = right-edge anchored (droplet / bar), 0 = centered (menu / volume)
    property real anchorMix: root.centeredMode ? 0 : 1
    Behavior on anchorMix {
        NumberAnimation {
            duration: root.expandDuration
            easing.type: root.expandEasing
        }
    }

    function aimAtCursor(p) {
        if (!mascot || root.width <= 0 || root.height <= 0)
            return
        const ex = mascot.x + mascot.width / 2
        const ey = mascot.y + mascot.height / 2
        mascot.lookAt((p.x - ex) / (root.width / 2),
                      (p.y - ey) / (root.height / 2))
    }

    readonly property real mascotBox: Theme.size.dropWidth
    readonly property real mascotCenterX: mascot.x + mascot.width / 2
    readonly property real mascotCenterY: mascot.y + mascot.height / 2

    function glanceAt(px, py) {
        if (!mascot || hoverCtl.hovered)
            return
        const mx = root.x + root.mascotCenterX
        const my = root.y + root.mascotCenterY
        const nx = Math.max(-1, Math.min(1, (px - mx) / Theme.size.notificationGazeSpanX))
        const ny = Math.max(-1, Math.min(1, (py - my) / Theme.size.notificationGazeSpanY))
        mascot.notificationGaze(nx, ny)
    }

    function releaseAttention() {
        if (!mascot)
            return
        mascot.releaseNotificationGaze()
        if (!hoverCtl.hovered)
            mascot.lookAt(0, 0)
    }

    width: root.chargeActive ? Theme.size.chargeWidth
         : root.statusActive ? (root.statusWidth + Theme.space.lg * 2)
         : root.settingsOpen ? Theme.size.settingsWidth
         : root.menuOpen ? Theme.size.menuWidth
         : root.volumeActive ? (volumeCtl.implicitWidth + Theme.space.lg * 2)
         : root.mode === "bar" ? (barLayout.implicitWidth + Theme.size.mascotModuleGap + root.mascotBox)
         : Theme.size.dropWidth
    height: root.chargeActive ? Theme.size.chargeHeight
          : root.statusActive ? Theme.size.dropHeight
          : root.settingsOpen ? Theme.size.settingsHeight
          : root.menuOpen ? Theme.size.menuHeight : Theme.size.dropHeight

    clip: true

    Behavior on width {
        NumberAnimation {
            duration: root.expandDuration
            easing.type: root.expandEasing
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: root.expandDuration
            easing.type: root.expandEasing
        }
    }

    readonly property real cx: width / 2
    readonly property real topHalf: width / 2
    property real topRadius: root.chargeActive ? Theme.radius.lg
                         : root.settingsOpen ? Theme.size.settingsTopRadius
                         : root.menuOpen ? Theme.size.menuTopRadius
                         : root.mode === "bar" ? Theme.size.barTopRadius
                         : Theme.size.dropTopRadius
    Behavior on topRadius {
        NumberAnimation {
            duration: root.expandDuration
            easing.type: root.expandEasing
        }
    }

    readonly property real bodyHalf: Math.max(width / 2 - topRadius, 0)
    property real bottomR: root.chargeActive ? Theme.radius.lg
                         : root.settingsOpen ? Theme.size.settingsBottomRadius
                         : root.menuOpen ? Theme.size.menuBottomRadius
                         : root.mode === "bar" ? Theme.size.barBottomRadius
                         : Theme.size.dropBodyRadius
    Behavior on bottomR {
        NumberAnimation {
            duration: root.expandDuration
            easing.type: root.expandEasing
        }
    }

    readonly property real shapeHeight: root.height
    readonly property real cyBottom: shapeHeight - bottomR

    Accessible.role: Accessible.Graphic
    Accessible.name: "Top bar backdrop"

    function closeMenu() {
        if (root.mode !== "menu" && root.mode !== "settings")
            return
        root.mode = hoverCtl.hovered ? "bar" : "droplet"
    }

    function outlinePoints() {
        const cx = root.cx
        const topHalf = root.topHalf
        const bodyHalf = root.bodyHalf
        const bottomR = root.bottomR
        const cyBottom = root.cyBottom
        const R = root.topRadius

        const right = [Qt.point(cx + topHalf, 0)]

        const filletSteps = 20
        for (let i = 1; i <= filletSteps; ++i) {
            const a = (i / filletSteps) * Math.PI / 2
            right.push(Qt.point(
                cx + bodyHalf + R - R * Math.sin(a),
                R - R * Math.cos(a)
            ))
        }

        if (cyBottom > R)
            right.push(Qt.point(cx + bodyHalf, cyBottom))

        const bottomRx = Math.min(bottomR, bodyHalf)
        const bottomRy = bottomR
        const cornerSteps = 20
        for (let i = 1; i <= cornerSteps; ++i) {
            const a = (i / cornerSteps) * Math.PI / 2
            right.push(Qt.point(
                cx + bodyHalf - bottomRx + bottomRx * Math.cos(a),
                cyBottom + bottomRy * Math.sin(a)
            ))
        }

        const points = right.slice()
        points.push(Qt.point(cx - bodyHalf + bottomRx, cyBottom + bottomRy))
        for (let i = right.length - 2; i >= 0; --i)
            points.push(Qt.point(2 * cx - right[i].x, right[i].y))
        return points
    }

    Keys.onEscapePressed: root.closeMenu()

    Shape {
        x: 0
        y: 0
        width: root.width
        height: root.shapeHeight

        ShapePath {
            fillColor: Theme.color.surface1
            strokeColor: Theme.color.borderSubtle
            strokeWidth: Theme.size.hairline
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.RoundCap

            PathPolyline {
                path: root.outlinePoints()
            }
        }
    }

    Item {
        id: head
        x: 0
        y: 0
        width: root.width
        height: root.chargeActive || root.settingsOpen ? root.height : Theme.size.dropHeight

        // Left modules stay anchored next to the mascot (right side),
        // so during the width animation the pill reveals them via clip
        // instead of the modules sliding in.
        BarLayout {
            id: barLayout
            y: 0
            width: barLayout.implicitWidth
            height: head.height
            x: mascot.x - Theme.size.mascotModuleGap - barLayout.implicitWidth
            visible: root.mode === "bar" && !root.volumeActive
            mascotPosition: root.mascotPosition
            charging: root.chargeStatus
        }

        Mascot {
            id: mascot
            width: root.mascotBox
            height: root.settingsOpen ? Theme.size.dropHeight : head.height
            y: root.settingsOpen ? (Theme.size.settingsHeaderHeight - Theme.size.dropHeight) / 2 : 0
            x: {
                const rightAligned = head.width - width
                const centered = (head.width - width) / 2
                return centered + (rightAligned - centered) * root.anchorMix
            }
            screen: root.screen
            volumeActive: root.volumeActive
            transformOrigin: Item.Center
            opacity: root.volumeActive ? 0 : 1
            scale: root.volumeActive ? 0.5 : 1
            visible: opacity > 0.01
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.slow
                    easing.type: Easing.InOutCubic
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: Theme.motion.slow
                    easing.type: Easing.InOutCubic
                }
            }
        }

        VolumeControl {
            id: volumeCtl
            width: volumeCtl.implicitWidth
            height: volumeCtl.implicitHeight
            anchors.centerIn: parent
            volume: root.volume
            kind: root.osdKind
            muted: root.osdMuted
            opacity: root.volumeActive && !root.chargeActive && !root.statusActive ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.slow
                    easing.type: Easing.InOutCubic
                }
            }
            transform: Scale {
                id: vscale
                origin.x: volumeCtl.width / 2
                origin.y: volumeCtl.height / 2
                xScale: root.volumeActive ? 1 : 0.35
                yScale: root.volumeActive ? 1 : 0.9
                Behavior on xScale {
                    NumberAnimation {
                        duration: Theme.motion.slow
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on yScale {
                    NumberAnimation {
                        duration: Theme.motion.slow
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        LangPill {
            id: langCtl
            width: langCtl.implicitWidth
            height: langCtl.implicitHeight
            anchors.centerIn: parent
            label: root.osdLabel
            opacity: root.langActive ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.slow
                    easing.type: Easing.InOutCubic
                }
            }
            transform: Scale {
                id: langScale
                origin.x: langCtl.width / 2
                origin.y: langCtl.height / 2
                xScale: root.langActive ? 1 : 0.35
                yScale: root.langActive ? 1 : 0.9
                Behavior on xScale {
                    NumberAnimation {
                        duration: Theme.motion.slow
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on yScale {
                    NumberAnimation {
                        duration: Theme.motion.slow
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        ConnectionWifi {
            id: wifiCtl
            width: wifiCtl.implicitWidth
            height: wifiCtl.implicitHeight
            anchors.centerIn: parent
            connected: root.volume > 0.5
            name: root.osdLabel
            opacity: root.wifiActive ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.slow
                    easing.type: Easing.InOutCubic
                }
            }
            transform: Scale {
                id: wifiScale
                origin.x: wifiCtl.width / 2
                origin.y: wifiCtl.height / 2
                xScale: root.wifiActive ? 1 : 0.35
                yScale: root.wifiActive ? 1 : 0.9
                Behavior on xScale {
                    NumberAnimation {
                        duration: Theme.motion.slow
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on yScale {
                    NumberAnimation {
                        duration: Theme.motion.slow
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        ConnectionBt {
            id: btCtl
            width: btCtl.implicitWidth
            height: btCtl.implicitHeight
            anchors.centerIn: parent
            connected: root.volume > 0.5
            name: root.osdLabel
            opacity: root.btActive ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.slow
                    easing.type: Easing.InOutCubic
                }
            }
            transform: Scale {
                id: btScale
                origin.x: btCtl.width / 2
                origin.y: btCtl.height / 2
                xScale: root.btActive ? 1 : 0.35
                yScale: root.btActive ? 1 : 0.9
                Behavior on xScale {
                    NumberAnimation {
                        duration: Theme.motion.slow
                        easing.type: Easing.OutCubic
                    }
                }
                Behavior on yScale {
                    NumberAnimation {
                        duration: Theme.motion.slow
                        easing.type: Easing.OutCubic
                    }
                }
            }
        }

        ChargeControl {
            id: chargeCtl
            x: 0
            y: 0
            width: chargeCtl.implicitWidth
            height: chargeCtl.implicitHeight
            value: root.volume
            charging: !root.osdMuted
            label: root.osdLabel
            opacity: root.chargeActive ? 1 : 0
            visible: opacity > 0.01
            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.slow
                    easing.type: Easing.InOutCubic
                }
            }
        }

        SettingsMenu {
            id: settingsMenu
            x: 0
            y: 0
            width: head.width
            height: head.height
            opacity: root.settingsOpen && root.panelContentVisible ? 1 : 0
            visible: root.settingsOpen && opacity > 0.01

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.fast
                    easing.type: Easing.OutCubic
                }
            }
        }

        Item {
            id: menuButton
            readonly property real size: Theme.space.lg
            readonly property real hitSize: Theme.space.xxl
            x: head.width - hitSize
            y: 0
            width: hitSize
            height: hitSize
            opacity: root.panelContentVisible ? 1 : 0
            visible: root.menuOpen && opacity > 0.01
            z: 1

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.fast
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: (Theme.size.dropHeight - menuButton.size) / 2
                anchors.rightMargin: Theme.space.md
                width: menuButton.size
                height: width
                radius: width / 2
                color: menuHover.hovered ? Theme.color.accentHover : Theme.color.accent

                Canvas {
                    id: gearIcon
                    anchors.centerIn: parent
                    width: Theme.space.md
                    height: width
                    onPaint: {
                        const ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        ctx.strokeStyle = Theme.color.accentText
                        ctx.lineWidth = Theme.size.hairline * 1.5
                        ctx.lineCap = "round"
                        const cx = width / 2
                        const cy = height / 2
                        const inner = width * 0.27
                        const outer = width * 0.46
                        ctx.beginPath()
                        for (let i = 0; i < 8; ++i) {
                            const a = i * Math.PI / 4
                            ctx.moveTo(cx + Math.cos(a) * inner, cy + Math.sin(a) * inner)
                            ctx.lineTo(cx + Math.cos(a) * outer, cy + Math.sin(a) * outer)
                        }
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.arc(cx, cy, inner, 0, Math.PI * 2)
                        ctx.stroke()
                        ctx.beginPath()
                        ctx.arc(cx, cy, inner * 0.3, 0, Math.PI * 2)
                        ctx.stroke()
                    }
                }
            }

            Accessible.role: Accessible.Button
            Accessible.name: "Open settings"

            HoverHandler {
                id: menuHover
                cursorShape: Qt.PointingHandCursor
            }
        }

        TapHandler {
            onTapped: {
                const p = menuButton.mapFromItem(head, point.position.x, point.position.y)
                const inMenuButton = p.x >= 0 && p.x <= menuButton.width
                    && p.y >= 0 && p.y <= menuButton.height
                if (root.settingsOpen) {
                    return
                } else if (root.menuOpen) {
                    if (inMenuButton) {
                        root.mode = "settings"
                        root.forceActiveFocus()
                    } else {
                        root.closeMenu()
                    }
                } else {
                    root.mode = "menu"
                    root.forceActiveFocus()
                }
            }
        }
    }

    HoverHandler {
        id: hoverCtl
        onPointChanged: {
            if (hoverCtl.hovered)
                root.aimAtCursor(hoverCtl.point.position)
        }
        onHoveredChanged: {
            if (hoverCtl.hovered) {
                root.aimAtCursor(hoverCtl.point.position)
                if (root.mode === "droplet")
                    root.mode = "bar"
            } else {
                if (root.menuOpen || root.settingsOpen)
                    root.closeMenu()
                else if (root.mode === "bar")
                    root.mode = "droplet"
            }
        }
    }
}
import QtQuick
import QtQuick.Shapes
import qs.ui
import qs.ui.components

Item {
    id: root

    property var screen: null
    property var host: null
    property bool volumeActive: false
    property bool debugOpen: false
    property bool launcherOpen: false
    property bool floating: false

    // Hover opens the bar temporarily; IPC open pins it until IPC close.
    property bool pinned: false
    property bool hoverOpen: false
    readonly property bool open: root.pinned || root.hoverOpen
    readonly property bool barExpanded: root.open && !root.volumeActive

    readonly property var mascotItem: barLayout.mascotItem
    property real volume: 0
    property string osdKind: "vol"
    property bool osdMuted: false
    property string osdLabel: ""
    readonly property bool chargeActive: root.volumeActive && root.osdKind === "charge"
    readonly property bool langActive: root.volumeActive && root.osdKind === "lang"
    readonly property bool wifiActive: root.volumeActive && root.osdKind === "wifi"
    readonly property bool btActive: root.volumeActive && root.osdKind === "bt"
    readonly property bool statusActive: root.langActive || root.wifiActive || root.btActive
    readonly property real statusWidth: root.langActive ? langCtl.implicitWidth
        : root.wifiActive ? wifiCtl.implicitWidth
        : btCtl.implicitWidth
    readonly property real chargePanelWidth:
        Theme.size.chargeValueWidth + Theme.space.sm + Theme.size.chargeTrackWidth
        + Theme.space.md * 2
    readonly property bool centeredMode: root.volumeActive
    readonly property int expandDuration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.slow
    readonly property int expandEasing: Easing.InOutCubic


    // 1 = right-edge anchored (droplet / bar), 0 = centered (volume / floating)
    property real anchorMix: root.floating || root.centeredMode ? 0 : 1
    Behavior on anchorMix {
        NumberAnimation {
            duration: root.expandDuration
            easing.type: root.expandEasing
        }
    }

    function aimAtCursor(p) {
        if (!root.mascotItem || root.width <= 0 || root.height <= 0)
            return
        root.mascotItem.lookAt((p.x - root.mascotCenterX) / (root.width / 2),
                               (p.y - root.mascotCenterY) / (root.height / 2))
    }

    readonly property real mascotBox:
        root.floating ? Theme.size.dropHeight : Theme.size.dropWidth
    readonly property real mascotCenterX: barLayout.mascotCenterX
    readonly property real mascotCenterY: barLayout.mascotCenterY

    function openBar() {
        root.pinned = true
        root.hoverOpen = true
    }

    function closeBar() {
        root.pinned = false
        root.hoverOpen = false
    }

    function toggleBar() {
        if (root.pinned)
            root.closeBar()
        else
            root.openBar()
    }

    function glanceAt(px, py) {
        if (!root.mascotItem || hoverCtl.hovered)
            return
        const mx = root.x + root.mascotCenterX
        const my = root.y + root.mascotCenterY
        const nx = Math.max(-1, Math.min(1, (px - mx) / Theme.size.notificationGazeSpanX))
        const ny = Math.max(-1, Math.min(1, (py - my) / Theme.size.notificationGazeSpanY))
        root.mascotItem.notificationGaze(nx, ny)
    }

    function releaseAttention() {
        if (!root.mascotItem)
            return
        root.mascotItem.releaseNotificationGaze()
        if (!hoverCtl.hovered)
            root.mascotItem.lookAt(0, 0)
    }

    opacity: root.debugOpen ? 0 : 1
    visible: !root.launcherOpen && opacity > 0.001
    Behavior on opacity {
        NumberAnimation {
            duration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.slow
            easing.type: Easing.InOutCubic
        }
    }

    width: root.chargeActive ? root.chargePanelWidth
         : root.statusActive ? (root.statusWidth + Theme.space.md * 2)
         : root.volumeActive ? (volumeCtl.implicitWidth + Theme.space.md * 2)
         : root.barExpanded ? barLayout.implicitWidth
         : root.floating ? Theme.size.dropHeight
         : Theme.size.dropWidth
    height: root.chargeActive ? Theme.size.chargeHeight : Theme.size.dropHeight

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
                         : root.barExpanded ? Theme.size.barTopRadius
                         : Theme.size.dropTopRadius
    Behavior on topRadius {
        NumberAnimation {
            duration: root.expandDuration
            easing.type: root.expandEasing
        }
    }

    readonly property real bodyHalf: Math.max(width / 2 - topRadius, 0)
    property real bottomR: root.chargeActive ? Theme.radius.lg
                         : root.barExpanded ? Theme.size.barBottomRadius
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

    Shape {
        x: 0
        y: 0
        width: root.width
        height: root.shapeHeight
        visible: !root.floating

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

    Rectangle {
        x: 0
        y: 0
        width: root.width
        height: root.shapeHeight
        radius: height / 2
        color: Theme.color.surface1
        border.width: Theme.size.hairline
        border.color: Theme.color.borderSubtle
        visible: root.floating
    }

    Item {
        id: head
        x: 0
        y: 0
        width: root.width
        height: root.chargeActive ? root.height : Theme.size.dropHeight

        BarLayout {
            id: barLayout
            x: 0
            y: 0
            width: root.width
            height: head.height
            host: root.host
            screen: root.screen
            expanded: root.open
            contentActive: !root.volumeActive
            volumeActive: root.volumeActive
            mascotHidden: root.volumeActive || root.debugOpen
            mascotBox: root.mascotBox
            leftModules: BarConfig.leftModules
            rightModules: BarConfig.rightModules
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
            width: root.chargePanelWidth
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
                if (!root.pinned)
                    root.hoverOpen = true
            } else if (!root.pinned) {
                root.hoverOpen = false
            }
        }
    }
}

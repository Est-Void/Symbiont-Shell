import QtQuick
import QtQuick.Shapes
import qs.ui

Item {
    id: root

    property var screen: null
    property string mode: "droplet"
    readonly property bool menuOpen: root.mode === "menu"

    width: root.mode === "menu" ? Theme.size.menuWidth
         : root.mode === "bar" ? Theme.size.barPlaceholderWidth
         : Theme.size.dropWidth
    height: root.menuOpen ? Theme.size.menuHeight : Theme.size.dropHeight

    Behavior on width {
        NumberAnimation {
            duration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.base
            easing.type: Easing.InOutCubic
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.base
            easing.type: Easing.InOutCubic
        }
    }

    readonly property real cx: width / 2
    readonly property real topHalf: width / 2
    property real topRadius: root.menuOpen ? Theme.size.menuTopRadius
                         : root.mode === "bar" ? Theme.size.barTopRadius
                         : Theme.size.dropTopRadius
    Behavior on topRadius {
        NumberAnimation {
            duration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.base
            easing.type: Easing.InOutCubic
        }
    }

    readonly property real bodyHalf: Math.max(width / 2 - topRadius, 0)
    property real bottomR: root.menuOpen ? Theme.size.menuBottomRadius
                         : root.mode === "bar" ? Theme.size.barBottomRadius
                         : Theme.size.dropBodyRadius
    Behavior on bottomR {
        NumberAnimation {
            duration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.base
            easing.type: Easing.InOutCubic
        }
    }

    readonly property real shapeHeight: root.height
    readonly property real cyBottom: shapeHeight - bottomR

    Accessible.role: Accessible.Graphic
    Accessible.name: "Top bar backdrop"

    function closeMenu() {
        if (root.mode !== "menu")
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
        height: Theme.size.dropHeight

        Mascot {
            anchors.fill: parent
            screen: root.screen
        }

        TapHandler {
            onTapped: {
                if (root.mode === "menu") {
                    root.closeMenu()
                } else {
                    root.mode = "menu"
                    root.forceActiveFocus()
                }
            }
        }
    }

    HoverHandler {
        id: hoverCtl
        onHoveredChanged: {
            if (hoverCtl.hovered) {
                if (root.mode === "droplet")
                    root.mode = "bar"
            } else {
                if (root.mode === "menu")
                    root.closeMenu()
                else if (root.mode === "bar")
                    root.mode = "droplet"
            }
        }
    }
}

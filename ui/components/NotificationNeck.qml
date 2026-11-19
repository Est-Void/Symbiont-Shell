pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.ui

Item {
    id: root

    property real mascotCenterX: 0
    property real topY: 0
    property real mergeY: 0
    property real strength: 0
    property real pinch: 0
    property color fillColor: Theme.color.surface1

    width: Theme.size.notificationNeckWidth
    height: Theme.size.notificationNeckHeight
    x: root.mascotCenterX - root.width / 2
    y: root.topY
    opacity: Math.max(0, Math.min(1, root.strength))
    visible: opacity > 0.001

    readonly property real _topHalf: root.width * 0.21
    readonly property real _waistHalf: root._topHalf * 0.45 * (1 - Math.max(0, Math.min(1, root.pinch)))
    readonly property real _bottomHalf: root.width * 0.44
    readonly property real _midY: root.height / 2

    function _smooth(t) {
        return t * t * (3 - 2 * t)
    }

    function _halfAt(y) {
        if (y <= root._midY) {
            const t = root._midY > 0 ? y / root._midY : 0
            return root._topHalf + (root._waistHalf - root._topHalf) * root._smooth(t)
        }
        const t = root.height > root._midY
            ? (y - root._midY) / (root.height - root._midY) : 0
        return root._waistHalf + (root._bottomHalf - root._waistHalf) * root._smooth(t)
    }

    function _fillPath() {
        const cx = root.width / 2
        const steps = 12
        const pts = [Qt.point(cx - root._topHalf, 0)]

        for (let i = 1; i <= steps; ++i) {
            const y = root.height * i / steps
            pts.push(Qt.point(cx - root._halfAt(y), y))
        }

        for (let i = steps; i >= 0; --i) {
            const y = root.height * i / steps
            pts.push(Qt.point(cx + root._halfAt(y), y))
        }

        return pts
    }

    function _leftPath() {
        const cx = root.width / 2
        const steps = 10
        const end = Math.max(0, Math.min(root.height, root.mergeY))
        const pts = [Qt.point(cx - root._topHalf, 0)]

        for (let i = 1; i <= steps; ++i) {
            const y = end * i / steps
            pts.push(Qt.point(cx - root._halfAt(y), y))
        }

        return pts
    }

    function _rightPath() {
        const cx = root.width / 2
        const steps = 10
        const end = Math.max(0, Math.min(root.height, root.mergeY))
        const pts = [Qt.point(cx + root._topHalf, 0)]

        for (let i = 1; i <= steps; ++i) {
            const y = end * i / steps
            pts.push(Qt.point(cx + root._halfAt(y), y))
        }

        return pts
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.fillColor
            strokeColor: "transparent"

            PathPolyline {
                path: root._fillPath()
            }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: Theme.color.borderDefault
            strokeWidth: Theme.size.hairline
            capStyle: ShapePath.FlatCap

            PathPolyline {
                path: root._leftPath()
            }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: Theme.color.borderDefault
            strokeWidth: Theme.size.hairline
            capStyle: ShapePath.FlatCap

            PathPolyline {
                path: root._rightPath()
            }
        }
    }
}

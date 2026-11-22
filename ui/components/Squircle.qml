pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.ui

Item {
    id: root

    property real n: 4
    property real radius: Theme.radius.lg
    property real topLeftRadius: root.radius
    property real topRightRadius: root.radius
    property real bottomLeftRadius: root.radius
    property real bottomRightRadius: root.radius
    property color fillColor: Theme.color.surface1
    property color strokeColor: Theme.color.borderSubtle
    property real strokeWidth: Theme.size.hairline
    property int segments: 72

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.fillColor
            strokeColor: root.strokeColor
            strokeWidth: root.strokeWidth
            joinStyle: ShapePath.RoundJoin

            PathPolyline {
                path: {
                    const pts = []
                    const w = root.width
                    const h = root.height
                    if (w <= 0 || h <= 0)
                        return pts

                    const power = 2 / root.n
                    const perCorner = Math.max(3, Math.round(root.segments / 4))

                    function clamp(r) {
                        return Math.max(0, Math.min(r, w / 2, h / 2))
                    }

                    function push(x, y) {
                        pts.push(Qt.point(x, y))
                    }

                    const tl = clamp(root.topLeftRadius)
                    const tr = clamp(root.topRightRadius)
                    const br = clamp(root.bottomRightRadius)
                    const bl = clamp(root.bottomLeftRadius)

                    push(tl, 0)
                    push(w - tr, 0)

                    for (let i = 1; i <= perCorner; ++i) {
                        const t = Math.PI / 2 - (i / perCorner) * Math.PI / 2
                        push(w - tr + tr * Math.pow(Math.cos(t), power),
                             tr - tr * Math.pow(Math.sin(t), power))
                    }

                    push(w, h - br)

                    for (let i = 1; i <= perCorner; ++i) {
                        const t = (i / perCorner) * Math.PI / 2
                        push(w - br + br * Math.pow(Math.cos(t), power),
                             h - br + br * Math.pow(Math.sin(t), power))
                    }

                    push(bl, h)

                    for (let i = 1; i <= perCorner; ++i) {
                        const t = Math.PI / 2 - (i / perCorner) * Math.PI / 2
                        push(bl - bl * Math.pow(Math.cos(t), power),
                             h - bl + bl * Math.pow(Math.sin(t), power))
                    }

                    push(0, tl)

                    for (let i = 1; i <= perCorner; ++i) {
                        const t = (i / perCorner) * Math.PI / 2
                        push(tl - tl * Math.pow(Math.cos(t), power),
                             tl - tl * Math.pow(Math.sin(t), power))
                    }

                    return pts
                }
            }
        }
    }
}

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.ui

Item {
    id: root

    property real n: 4
    property real radius: Theme.radius.lg
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
                    const r = Math.max(0, Math.min(root.radius, w / 2, h / 2))
                    const power = 2 / root.n
                    const perCorner = Math.max(3, Math.round(root.segments / 4))

                    function push(x, y) {
                        pts.push(Qt.point(x, y))
                    }

                    if (r < 0.5) {
                        push(0, 0)
                        push(w, 0)
                        push(w, h)
                        push(0, h)
                        return pts
                    }

                    push(r, 0)
                    push(w - r, 0)

                    for (let i = 1; i <= perCorner; ++i) {
                        const t = Math.PI / 2 - (i / perCorner) * Math.PI / 2
                        push(w - r + r * Math.pow(Math.cos(t), power),
                             r - r * Math.pow(Math.sin(t), power))
                    }

                    push(w, h - r)

                    for (let i = 1; i <= perCorner; ++i) {
                        const t = (i / perCorner) * Math.PI / 2
                        push(w - r + r * Math.pow(Math.cos(t), power),
                             h - r + r * Math.pow(Math.sin(t), power))
                    }

                    push(r, h)

                    for (let i = 1; i <= perCorner; ++i) {
                        const t = Math.PI / 2 - (i / perCorner) * Math.PI / 2
                        push(r - r * Math.pow(Math.cos(t), power),
                             h - r + r * Math.pow(Math.sin(t), power))
                    }

                    push(0, r)

                    for (let i = 1; i <= perCorner; ++i) {
                        const t = (i / perCorner) * Math.PI / 2
                        push(r - r * Math.pow(Math.cos(t), power),
                             r - r * Math.pow(Math.sin(t), power))
                    }

                    return pts
                }
            }
        }
    }
}

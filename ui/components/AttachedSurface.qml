pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.ui

Item {
    id: root

    property real n: 4
    property real shoulder: Theme.size.launcherShoulder
    property real bottomRadius: Theme.size.launcherRadius
    property color fillColor: Theme.color.surface1
    property color strokeColor: Theme.color.borderSubtle
    property real strokeWidth: Theme.size.hairline
    property int segments: 40

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
                    const s = Math.max(0, Math.min(root.shoulder, w / 2, h / 2))
                    const bodyWidth = Math.max(0, w - s * 2)
                    const b = Math.max(0, Math.min(root.bottomRadius,
                                                    bodyWidth / 2, h - s))

                    function push(x, y) {
                        pts.push(Qt.point(x, y))
                    }

                    push(0, 0)

                    for (let i = 1; i <= perCorner; ++i) {
                        const t = (i / perCorner) * Math.PI / 2
                        push(s * Math.sin(t), s * (1 - Math.cos(t)))
                    }

                    push(s, h - b)

                    for (let i = 1; i <= perCorner; ++i) {
                        const t = (i / perCorner) * Math.PI / 2
                        push(s + b * (1 - Math.pow(Math.cos(t), power)),
                             h - b + b * Math.pow(Math.sin(t), power))
                    }

                    push(w - s - b, h)

                    for (let i = 1; i <= perCorner; ++i) {
                        const t = (i / perCorner) * Math.PI / 2
                        push(w - s - b + b * Math.pow(Math.sin(t), power),
                             h - b + b * Math.pow(Math.cos(t), power))
                    }

                    push(w - s, s)

                    for (let i = 1; i <= perCorner; ++i) {
                        const t = Math.PI / 2 - (i / perCorner) * Math.PI / 2
                        push(w - s * Math.sin(t), s * (1 - Math.cos(t)))
                    }

                    return pts
                }
            }
        }
    }
}

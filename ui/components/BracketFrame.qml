pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.ui

Item {
    id: root

    property real pillWidth: 0
    property real pillHeight: 0

    default property alias content: pill.data

    readonly property real bracketR: Theme.size.mascotRingRadius
    readonly property real gapBracket: Theme.space.xs
    readonly property real sweep: 130

    implicitWidth: root.bracketR * 2 + root.gapBracket * 2 + root.pillWidth
    implicitHeight: Math.max(root.bracketR * 2, root.pillHeight)

    Rectangle {
        id: pill
        x: root.bracketR + root.gapBracket
        width: root.pillWidth
        height: root.pillHeight
        anchors.verticalCenter: parent.verticalCenter
        radius: height / 2
        color: Theme.color.accent
    }

    Item {
        width: root.bracketR
        height: root.bracketR * 2
        x: 0
        y: (root.implicitHeight - height) / 2

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme.color.textPrimary
                strokeWidth: Theme.size.mascotArcWidth
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                PathPolyline {
                    path: {
                        var pts = []
                        const R = root.bracketR
                        const a1 = 180 - root.sweep / 2
                        for (var i = 0; i <= 20; ++i) {
                            const t = (a1 + i * root.sweep / 20) * Math.PI / 180
                            pts.push(Qt.point(R + R * Math.cos(t), R + R * Math.sin(t)))
                        }
                        return pts
                    }
                }
            }
        }
    }

    Item {
        width: root.bracketR
        height: root.bracketR * 2
        x: root.implicitWidth - root.bracketR
        y: (root.implicitHeight - height) / 2

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme.color.textPrimary
                strokeWidth: Theme.size.mascotArcWidth
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                PathPolyline {
                    path: {
                        var pts = []
                        const R = root.bracketR
                        const a1 = -root.sweep / 2
                        for (var i = 0; i <= 20; ++i) {
                            const t = (a1 + i * root.sweep / 20) * Math.PI / 180
                            pts.push(Qt.point(R * Math.cos(t), R + R * Math.sin(t)))
                        }
                        return pts
                    }
                }
            }
        }
    }
}

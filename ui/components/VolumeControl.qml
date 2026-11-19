import QtQuick
import QtQuick.Shapes
import qs.ui

Item {
    id: root

    property real volume: 0
    property string kind: "vol"
    property bool muted: false

    readonly property color fillColor: Theme.color.accent

    readonly property real barW: 120
    readonly property real barH: 10
    readonly property real iconS: 18
    readonly property real gapInner: Theme.space.sm
    readonly property real gapBracket: Theme.space.xs
    readonly property real bracketR: Theme.size.mascotRingRadius
    readonly property real sweep: 130

    readonly property real spacer: Theme.size.hairline
    readonly property bool both: !root.muted && root.volume > 0.0001 && root.volume < 0.9999
    readonly property real fillW: root.both
        ? root.volume * (root.barW - root.spacer)
        : root.volume * root.barW
    readonly property real emptyW: root.both
        ? (1 - root.volume) * (root.barW - root.spacer)
        : (1 - root.volume) * root.barW

    implicitWidth: root.bracketR + root.gapBracket + root.iconS + root.gapInner
        + root.barW + root.gapBracket + root.bracketR
    implicitHeight: Math.max(root.iconS, root.barH, root.bracketR * 2)

    Item {
        id: leftBracket
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
                        var R = root.bracketR
                        var cx = R
                        var cy = R
                        var steps = 20
                        var a1 = 180 - root.sweep / 2
                        for (var i = 0; i <= steps; ++i) {
                            var t = (a1 + i * root.sweep / steps) * Math.PI / 180
                            pts.push(Qt.point(cx + R * Math.cos(t), cy + R * Math.sin(t)))
                        }
                        return pts
                    }
                }
            }
        }
    }

    Item {
        id: icon
        width: root.iconS
        height: root.iconS
        x: root.bracketR + root.gapBracket
        anchors.verticalCenter: parent.verticalCenter

        Shape {
            id: speaker
            anchors.fill: parent
            visible: root.kind === "vol"
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: Theme.color.textPrimary
                strokeColor: "transparent"
                joinStyle: ShapePath.RoundJoin

                PathMove { x: 3; y: iconS / 2 - 3 }
                PathLine { x: 8; y: iconS / 2 - 3 }
                PathLine { x: 13; y: iconS / 2 - 8 }
                PathLine { x: 13; y: iconS / 2 + 8 }
                PathLine { x: 8; y: iconS / 2 + 3 }
                PathLine { x: 3; y: iconS / 2 + 3 }
                PathLine { x: 3; y: iconS / 2 - 3 }
            }
        }

        Rectangle {
            id: muteSlash
            visible: root.kind === "vol" && root.muted
            width: iconS * 1.25
            height: Theme.size.mascotArcWidth
            radius: height / 2
            color: Theme.color.textPrimary
            anchors.centerIn: parent
            rotation: -45
        }

        Shape {
            id: sun
            anchors.fill: parent
            visible: root.kind === "bright"
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: Theme.color.textPrimary
                strokeColor: "transparent"

                PathPolyline {
                    path: {
                        var pts = []
                        var cx = iconS / 2
                        var cy = iconS / 2
                        var r = 3.6
                        var steps = 20
                        for (var i = 0; i <= steps; ++i) {
                            var t = i * 2 * Math.PI / steps
                            pts.push(Qt.point(cx + r * Math.cos(t), cy + r * Math.sin(t)))
                        }
                        return pts
                    }
                }
            }

            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme.color.textPrimary
                strokeWidth: 1.5
                capStyle: ShapePath.RoundCap

                PathMove { x: 9; y: 2.5 }
                PathLine { x: 9; y: 4.5 }
                PathMove { x: 9; y: 13.5 }
                PathLine { x: 9; y: 15.5 }
                PathMove { x: 2.5; y: 9 }
                PathLine { x: 4.5; y: 9 }
                PathMove { x: 13.5; y: 9 }
                PathLine { x: 15.5; y: 9 }
                PathMove { x: 4.4; y: 4.4 }
                PathLine { x: 5.8; y: 5.8 }
                PathMove { x: 12.2; y: 12.2 }
                PathLine { x: 13.6; y: 13.6 }
                PathMove { x: 13.6; y: 4.4 }
                PathLine { x: 12.2; y: 5.8 }
                PathMove { x: 5.8; y: 12.2 }
                PathLine { x: 4.4; y: 13.6 }
            }
        }
    }

    Item {
        id: bar
        width: root.barW
        height: root.barH
        x: icon.x + icon.width + root.gapInner
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            id: muteBar
            width: root.barW
            height: root.barH
            radius: height / 2
            color: Theme.color.surface3
            visible: root.muted
        }

        Rectangle {
            id: filled
            visible: !root.muted
            width: root.fillW
            height: root.barH
            radius: height / 2
            color: root.fillColor
            Behavior on width {
                NumberAnimation {
                    duration: Theme.motion.slow
                    easing.type: Easing.OutCubic
                }
            }
        }

        Rectangle {
            id: empty
            visible: !root.muted
            x: root.fillW + (root.both ? root.spacer : 0)
            width: root.emptyW
            height: root.barH
            radius: height / 2
            color: Theme.color.surface3
            Behavior on width {
                NumberAnimation {
                    duration: Theme.motion.slow
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on x {
                NumberAnimation {
                    duration: Theme.motion.slow
                    easing.type: Easing.OutCubic
                }
            }
        }
    }

    Item {
        id: rightBracket
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
                        var R = root.bracketR
                        var cx = 0
                        var cy = R
                        var steps = 20
                        var a1 = -root.sweep / 2
                        for (var i = 0; i <= steps; ++i) {
                            var t = (a1 + i * root.sweep / steps) * Math.PI / 180
                            pts.push(Qt.point(cx + R * Math.cos(t), cy + R * Math.sin(t)))
                        }
                        return pts
                    }
                }
            }
        }
    }
}
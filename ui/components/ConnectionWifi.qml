pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.ui

BracketFrame {
    id: root

    property bool connected: false
    property string name: ""

    readonly property real iconS: Theme.size.connectionIcon
    readonly property real pad: Theme.space.xs
    readonly property real gapInner: Theme.space.xs
    readonly property real maxTextW: Theme.size.menuWidth
        - root.bracketR * 2 - root.gapBracket * 2
        - root.iconS - root.gapInner - root.pad * 2
    readonly property string fullText: (root.connected ? "CONNECTED" : "DISCONNECTED")
        + ": " + root.name
    readonly property real textW: Math.max(Theme.size.chargeTrackWidth,
                                           Math.min(textMetric.implicitWidth, root.maxTextW))

    pillWidth: root.pad * 2 + root.iconS + root.gapInner + root.textW
    pillHeight: Math.max(root.iconS + root.pad * 2,
                         bodyText.implicitHeight + root.pad * 2)

    function arcPoints(cx, cy, r, a1, a2) {
        var pts = []
        for (var i = 0; i <= 12; ++i) {
            const t = (a1 + (a2 - a1) * i / 12) * Math.PI / 180
            pts.push(Qt.point(cx + r * Math.cos(t), cy + r * Math.sin(t)))
        }
        return pts
    }

    Text {
        id: textMetric
        visible: false
        text: root.fullText
        font.family: Theme.font.ui[0]
        font.pixelSize: Theme.type.monoValue.size
    }

    Item {
        width: root.iconS
        height: root.iconS
        x: root.pad
        anchors.verticalCenter: parent.verticalCenter

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme.color.accentText
                strokeWidth: 1.4
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin

                PathPolyline { path: root.arcPoints(8, 12.5, 2.6, 210, 330) }
                PathPolyline { path: root.arcPoints(8, 12.5, 5.2, 210, 330) }
                PathPolyline { path: root.arcPoints(8, 12.5, 7.8, 210, 330) }
            }
        }

        Rectangle {
            width: 2.2
            height: 2.2
            radius: width / 2
            x: 6.9
            y: 11.4
            color: Theme.color.accentText
        }

        Rectangle {
            visible: !root.connected
            width: root.iconS * 1.2
            height: Theme.size.mascotArcWidth
            radius: height / 2
            anchors.centerIn: parent
            rotation: -45
            color: Theme.color.accentText
        }
    }

    Text {
        id: bodyText
        x: root.pad + root.iconS + root.gapInner
        width: root.textW
        anchors.verticalCenter: parent.verticalCenter
        text: root.fullText
        color: Theme.color.accentText
        font.family: Theme.font.ui[0]
        font.pixelSize: Theme.type.monoValue.size
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
    }
}

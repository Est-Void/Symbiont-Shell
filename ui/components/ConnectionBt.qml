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
    readonly property real maxTextW: Theme.size.connectionMaxWidth
        - root.bracketR * 2 - root.gapBracket * 2
        - root.iconS - root.gapInner - root.pad * 2
    readonly property string fullText: (root.connected ? "CONNECTED" : "DISCONNECTED")
        + ": " + root.name
    readonly property real textW: Math.max(Theme.size.chargeTrackWidth,
                                           Math.min(textMetric.implicitWidth, root.maxTextW))

    pillWidth: root.pad * 2 + root.iconS + root.gapInner + root.textW
    pillHeight: Math.max(root.iconS + root.pad * 2,
                         bodyText.implicitHeight + root.pad * 2)

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

                PathMove { x: 8; y: 1 }
                PathLine { x: 8; y: 15 }
                PathMove { x: 8; y: 1 }
                PathLine { x: 12.5; y: 5.5 }
                PathLine { x: 3.5; y: 12.5 }
                PathLine { x: 8; y: 15 }
                PathMove { x: 8; y: 15 }
                PathLine { x: 12.5; y: 10.5 }
                PathLine { x: 3.5; y: 3.5 }
                PathLine { x: 8; y: 1 }
            }
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

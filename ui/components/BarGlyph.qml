import QtQuick
import QtQuick.Shapes
import qs.ui

Item {
    id: root

    property string kind: "wifi"
    property color color: Theme.color.textPrimary
    property bool off: false

    implicitWidth: Theme.size.barModuleIcon
    implicitHeight: Theme.size.barModuleIcon

    Accessible.role: Accessible.Graphic
    Accessible.name: root.kind

    readonly property real _art: 16

    function arcPoints(cx, cy, r, a1, a2) {
        const pts = []
        for (let i = 0; i <= 12; ++i) {
            const t = (a1 + (a2 - a1) * i / 12) * Math.PI / 180
            pts.push(Qt.point(cx + r * Math.cos(t), cy + r * Math.sin(t)))
        }
        return pts
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        visible: root.kind === "wifi"
        transform: Scale {
            origin.x: 0
            origin.y: 0
            xScale: root.width / root._art
            yScale: root.height / root._art
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: root.color
            strokeWidth: Theme.size.iconStroke
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathPolyline { path: root.arcPoints(8, 12.5, 2.6, 210, 330) }
            PathPolyline { path: root.arcPoints(8, 12.5, 5.2, 210, 330) }
            PathPolyline { path: root.arcPoints(8, 12.5, 7.8, 210, 330) }
        }

        ShapePath {
            fillColor: root.color
            strokeColor: "transparent"

            PathMove { x: 6.9; y: 11.4 }
            PathLine { x: 9.1; y: 11.4 }
            PathLine { x: 9.1; y: 13.6 }
            PathLine { x: 6.9; y: 13.6 }
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        visible: root.kind === "bluetooth"
        transform: Scale {
            origin.x: 0
            origin.y: 0
            xScale: root.width / root._art
            yScale: root.height / root._art
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: root.color
            strokeWidth: Theme.size.iconStroke
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin

            PathMove { x: 8; y: 1.5 }
            PathLine { x: 8; y: 14.5 }
            PathMove { x: 8; y: 1.5 }
            PathLine { x: 12; y: 5.5 }
            PathLine { x: 4; y: 12 }
            PathLine { x: 8; y: 14.5 }
            PathMove { x: 8; y: 14.5 }
            PathLine { x: 12; y: 10.5 }
            PathLine { x: 4; y: 4 }
            PathLine { x: 8; y: 1.5 }
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        visible: root.kind === "volume"
        transform: Scale {
            origin.x: 0
            origin.y: 0
            xScale: root.width / root._art
            yScale: root.height / root._art
        }

        ShapePath {
            fillColor: root.color
            strokeColor: root.color
            strokeWidth: Theme.size.hairline
            joinStyle: ShapePath.RoundJoin

            PathMove { x: 1.5; y: 6 }
            PathLine { x: 5; y: 6 }
            PathLine { x: 9; y: 2.5 }
            PathLine { x: 9; y: 13.5 }
            PathLine { x: 5; y: 10 }
            PathLine { x: 1.5; y: 10 }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: root.color
            strokeWidth: Theme.size.iconStroke
            capStyle: ShapePath.RoundCap

            PathMove { x: 11.2; y: 5.6 }
            PathLine { x: 12.6; y: 8 }
            PathLine { x: 11.2; y: 10.4 }
        }
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        visible: root.off
        transform: Scale {
            origin.x: 0
            origin.y: 0
            xScale: root.width / root._art
            yScale: root.height / root._art
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: Theme.color.textTertiary
            strokeWidth: Theme.size.iconStroke
            capStyle: ShapePath.RoundCap

            PathMove { x: 2.5; y: 13.5 }
            PathLine { x: 13.5; y: 2.5 }
        }
    }
}

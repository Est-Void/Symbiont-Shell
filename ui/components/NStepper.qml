pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import qs.ui

// Fixed-step numeric stepper: minus / value / plus over a constrained list
// of allowed values. Stepping past the ends is a no-op and the buttons
// dim at the bounds. Keyboard: Left / Right while the stepper has focus.
Item {
    id: root

    property real value: 0
    property var values: []
    property string label: ""

    signal stepped(real value)

    readonly property int index: root._indexOf(root.value)
    readonly property bool atMin: root.index <= 0
    readonly property bool atMax: root.index >= root.values.length - 1

    implicitWidth: dec.width + Theme.space.sm + valueText.implicitWidth
                   + Theme.space.sm + inc.width
    implicitHeight: Theme.size.stepperButton
    activeFocusOnTab: true

    Accessible.role: Accessible.SpinBox
    Accessible.name: root.label + " " + root.value

    function _indexOf(v) {
        let idx = root.values.indexOf(v)
        if (idx >= 0)
            return idx
        let best = 0
        let bestDist = Infinity
        for (let i = 0; i < root.values.length; ++i) {
            const dist = Math.abs(root.values[i] - v)
            if (dist < bestDist) {
                bestDist = dist
                best = i
            }
        }
        return best
    }

    function step(delta) {
        const next = Math.max(0, Math.min(root.values.length - 1, root.index + delta))
        if (next !== root.index)
            root.stepped(root.values[next])
    }

    Keys.onLeftPressed: root.step(-1)
    Keys.onRightPressed: root.step(1)

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Theme.size.focusRingOffset
        radius: height / 2
        color: Theme.color.transparent
        border.width: Theme.size.focusRingWidth
        border.color: Theme.color.accent
        visible: root.activeFocus
    }

    component StepButton: Item {
        id: btn

        property bool plus: false
        readonly property bool disabled: btn.plus ? root.atMax : root.atMin
        readonly property bool hot: mouse.containsMouse || btn.activeFocus

        width: Theme.size.stepperButton
        height: Theme.size.stepperButton
        anchors.verticalCenter: parent.verticalCenter
        opacity: btn.disabled ? Theme.size.disabledOpacity : 1
        activeFocusOnTab: false

        Accessible.role: Accessible.Button
        Accessible.name: btn.plus ? "Increase" : "Decrease"

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: btn.hot && !btn.disabled ? Theme.color.surface3
                                            : Theme.color.transparent
            border.width: Theme.size.hairline
            border.color: Theme.color.borderStrong
        }

        Shape {
            width: 12
            height: 12
            anchors.centerIn: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme.color.textPrimary
                strokeWidth: Theme.size.iconStroke
                capStyle: ShapePath.RoundCap

                PathPolyline { path: [Qt.point(2, 6), Qt.point(10, 6)] }
                PathPolyline {
                    path: btn.plus ? [Qt.point(6, 2), Qt.point(6, 10)] : []
                }
            }
        }

        MouseArea {
            id: mouse
            anchors.fill: parent
            hoverEnabled: true
            enabled: !btn.disabled
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                root.forceActiveFocus()
                root.step(btn.plus ? 1 : -1)
            }
        }
    }

    StepButton {
        id: dec
        x: 0
    }

    Text {
        id: valueText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text: String(root.values[root.index] !== undefined
                     ? root.values[root.index] : root.value).padStart(2, "0")
        color: Theme.color.textPrimary
        font.family: Theme.font.mono[0]
        font.pixelSize: Theme.type.monoValue.size
        font.letterSpacing: Theme.type.monoValue.tracking
        renderType: Text.NativeRendering
    }

    StepButton {
        id: inc
        plus: true
        x: root.width - width
    }
}

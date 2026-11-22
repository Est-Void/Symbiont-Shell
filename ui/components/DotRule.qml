pragma ComponentBehavior: Bound

import QtQuick
import qs.ui

// Dotted 1px-class divider (§4.4): a horizontal run of tiny dots.
Item {
    id: root

    property color color: Theme.color.borderSubtle
    property real dotSize: Theme.space.xxs
    property real pitch: Theme.space.xxs + Theme.space.xs

    implicitWidth: 0
    implicitHeight: root.dotSize
    width: implicitWidth
    height: implicitHeight

    onColorChanged: canvas.requestPaint()
    onDotSizeChanged: canvas.requestPaint()
    onPitchChanged: canvas.requestPaint()

    Canvas {
        id: canvas
        anchors.fill: parent
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            const r = root.dotSize / 2
            const count = Math.max(0, Math.floor((width - root.dotSize) / root.pitch) + 1)
            ctx.fillStyle = String(root.color)
            for (let i = 0; i < count; ++i) {
                ctx.beginPath()
                ctx.arc(i * root.pitch + r, height / 2, r, 0, Math.PI * 2)
                ctx.fill()
            }
        }
    }
}

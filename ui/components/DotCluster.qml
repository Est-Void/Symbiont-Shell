pragma ComponentBehavior: Bound

import QtQuick
import qs.ui

// Dithered dot-cluster glyph (§7.2): a grid of dots driven by a
// "1"/"0" pattern, e.g. the 7x7 dotted circle used as an abstract mark.
Item {
    id: root

    property var pattern: []
    property real dotSize: Theme.space.xxs
    property real pitch: Theme.space.xs
    property color color: Theme.color.textSecondary

    readonly property int rows: root.pattern.length
    readonly property int cols: root.rows > 0 ? String(root.pattern[0]).length : 0

    implicitWidth: Math.max(0, (root.cols - 1) * root.pitch + root.dotSize)
    implicitHeight: Math.max(0, (root.rows - 1) * root.pitch + root.dotSize)
    width: implicitWidth
    height: implicitHeight

    onPatternChanged: canvas.requestPaint()
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
            ctx.fillStyle = String(root.color)
            for (let row = 0; row < root.rows; ++row) {
                const line = String(root.pattern[row])
                for (let col = 0; col < line.length && col < root.cols; ++col) {
                    if (line[col] !== "1")
                        continue
                    ctx.beginPath()
                    ctx.arc(col * root.pitch + r, row * root.pitch + r, r, 0, Math.PI * 2)
                    ctx.fill()
                }
            }
        }
    }
}

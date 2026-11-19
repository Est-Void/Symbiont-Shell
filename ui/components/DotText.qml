pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: dt

    property string value: ""
    property real size: 14
    property real gapRatio: 0.22
    property color color: "#ffffff"

    readonly property real dotSize: dt.size / (7 + 6 * dt.gapRatio)
    readonly property real gap: dt.dotSize * dt.gapRatio
    readonly property real pitch: dt.dotSize + dt.gap
    property real charGap: dt.dotSize + dt.gap

    readonly property var glyphs: ({
        "0": ["01110", "10001", "10001", "10001", "10001", "10001", "01110"],
        "1": ["00100", "01100", "00100", "00100", "00100", "00100", "01110"],
        "2": ["01110", "10001", "00001", "00010", "00100", "01000", "11111"],
        "3": ["11111", "00010", "00100", "00010", "00001", "10001", "01110"],
        "4": ["00010", "00110", "01010", "10010", "11111", "00010", "00010"],
        "5": ["11111", "10000", "11110", "00001", "00001", "10001", "01110"],
        "6": ["00110", "01000", "10000", "11110", "10001", "10001", "01110"],
        "7": ["11111", "00001", "00010", "00100", "01000", "01000", "01000"],
        "8": ["01110", "10001", "10001", "01110", "10001", "10001", "01110"],
        "9": ["01110", "10001", "10001", "01111", "00001", "00010", "01100"],
        ":": ["0", "0", "1", "0", "0", "1", "0"],
        ".": ["0", "0", "0", "0", "0", "0", "1"],
        "-": ["000", "000", "000", "111", "000", "000", "000"],
        "%": ["11001", "11010", "00100", "00100", "00100", "01011", "10011"],
        "°": ["111", "101", "111", "000", "000", "000", "000"],
        " ": ["00", "00", "00", "00", "00", "00", "00"]
    })

    implicitWidth: {
        const s = String(dt.value)
        if (!s.length)
            return 0
        let w = 0
        for (let i = 0; i < s.length; i++) {
            const g = dt.glyphs[s[i]]
            w += (g ? g[0].length : 3) * dt.pitch
        }
        return w + (s.length - 1) * dt.charGap - dt.gap
    }
    implicitHeight: 7 * dt.pitch - dt.gap

    onValueChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
    onSizeChanged: canvas.requestPaint()
    onGapRatioChanged: canvas.requestPaint()
    onCharGapChanged: canvas.requestPaint()

    // One Canvas instead of one Rectangle per dot: no scene-graph item churn
    // when the value changes, and no work at all while the value is stable.
    Canvas {
        id: canvas
        width: dt.width > 0 ? dt.width : dt.implicitWidth
        height: dt.height > 0 ? dt.height : dt.implicitHeight
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            const s = String(dt.value)
            if (s.length === 0)
                return

            ctx.fillStyle = String(dt.color)
            const pitch = dt.pitch
            const radius = dt.dotSize / 2
            let x = 0

            for (let i = 0; i < s.length; i++) {
                const glyph = dt.glyphs[s[i]]
                if (glyph) {
                    for (let row = 0; row < glyph.length; row++) {
                        const line = glyph[row]
                        for (let col = 0; col < line.length; col++) {
                            if (line[col] !== "1")
                                continue
                            ctx.beginPath()
                            ctx.arc(x + col * pitch + radius,
                                    row * pitch + radius,
                                    radius, 0, Math.PI * 2)
                            ctx.fill()
                        }
                    }
                    x += glyph[0].length * pitch
                } else {
                    x += 3 * pitch
                }
                if (i < s.length - 1)
                    x += dt.charGap
            }
        }
    }
}

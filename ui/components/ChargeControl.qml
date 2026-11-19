pragma ComponentBehavior: Bound

import QtQuick
import qs.ui
import qs.ui.components

Item {
    id: root

    property real value: 0
    property bool charging: true
    property string label: "CHARGING"

    readonly property int percent: Math.round(Math.max(0, Math.min(1, root.value)) * 100)
    readonly property string status: root.label.length > 0
        ? root.label
        : (root.charging ? "CHARGING" : "UNPLUGGED")

    implicitWidth: Theme.size.chargeWidth
    implicitHeight: Theme.size.chargeHeight
    clip: true

    Row {
        anchors.centerIn: parent
        spacing: Theme.space.sm

        DotText {
            id: valueText
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -Theme.size.hairline / 2
            value: root.percent + "%"
            size: Theme.type.heading.size + Theme.size.hairline
            gapRatio: 0.1
            color: Theme.color.textPrimary
        }

        Column {
            anchors.bottom: valueText.bottom

            Text {
                id: statusText
                width: Theme.size.chargeTrackWidth
                text: root.status
                color: Theme.color.textSecondary
                font.family: Theme.font.mono[0]
                font.pixelSize: Theme.type.label.size
                font.weight: Theme.type.label.weight
                font.letterSpacing: Theme.type.label.tracking
                font.capitalization: Font.AllUppercase
                renderType: Text.NativeRendering
            }

            Item {
                id: track
                width: Theme.size.chargeTrackWidth
                height: Theme.size.chargeTrackHeight

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: Theme.color.surface3
                }

                Rectangle {
                    width: track.width * Math.max(0, Math.min(1, root.value))
                    height: track.height
                    radius: height / 2
                    color: Theme.color.accent

                    Behavior on width {
                        NumberAnimation {
                            duration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.base
                            easing.type: Easing.OutCubic
                        }
                    }

                    Canvas {
                        anchors.fill: parent
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()

                        onPaint: {
                            const ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            const pitch = Theme.size.chargeDitherPitch
                            const dot = Theme.size.hairline
                            const pattern = ["10000", "00010", "00100", "00000", "01000", "00001", "00000"]
                            ctx.fillStyle = String(Theme.color.surface3)
                            for (let y = 0; y < height; y += pitch) {
                                const row = pattern[Math.floor(y / pitch) % pattern.length]
                                for (let x = 0; x < width; x += pitch) {
                                    if (row[Math.floor(x / pitch) % row.length] === "1")
                                        ctx.fillRect(x, y, dot, dot)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

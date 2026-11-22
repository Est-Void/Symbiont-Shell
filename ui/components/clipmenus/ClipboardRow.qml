pragma ComponentBehavior: Bound

import QtQuick
import qs.ui
import qs.ui.components

// Clipboard manifest row: registration index, glyph tile (dot cluster for
// text, image mark for bitmaps), one-line preview, mono timestamp and a
// long-stem arrow on hover (§7.2). Keyboard "current" row is the primary
// capsule: inverse fill (§8.1).
Item {
    id: root

    property var entry: null
    property int number: 0
    property bool current: false
    property bool showDivider: false

    signal activated()

    readonly property bool hovered: rowMouse.containsMouse
    readonly property bool engaged: root.current || root.hovered
    readonly property bool isImage: root.entry && root.entry.kind === "image"
    readonly property string previewText: root.entry && root.entry.preview
        ? String(root.entry.preview) : ""
    readonly property string kindLabel: root.isImage
        ? "IMAGE" + (root.entry && root.entry.types
            ? " \u00B7 " + String(root.entry.types).split(",").filter(function (t) {
                  return t.indexOf("image/") === 0
              }).map(function (t) {
                  return t.substring(6).toUpperCase()
              }).slice(0, 1).join("")
            : "")
        : ""
    readonly property string timeLabel: root.entry && root.entry.timestamp
        ? Qt.formatDateTime(new Date(root.entry.timestamp), "hh:mm") : "--:--"

    width: parent ? parent.width : 0
    height: Theme.size.launcherRowHeight

    Accessible.role: Accessible.ListItem
    Accessible.name: root.isImage ? root.kindLabel : root.previewText
    Accessible.description: root.timeLabel

    Rectangle {
        id: background

        anchors.fill: parent
        radius: Theme.radius.pill
        color: root.current ? Theme.color.surfaceInverse
             : root.hovered ? Theme.color.surface2
             : Theme.color.transparent

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.instant
            }
        }
    }

    Text {
        id: indexText

        x: Theme.space.md
        width: Theme.space.lg
        anchors.verticalCenter: parent.verticalCenter
        text: root.number > 0 ? String(root.number).padStart(2, "0") : "--"
        color: root.current ? Theme.color.textInverse : Theme.color.textTertiary
        opacity: root.current ? 0.64 : 1.0
        font.family: Theme.font.mono[0]
        font.pixelSize: Theme.type.labelSm.size
        font.weight: Theme.type.labelSm.weight
        font.letterSpacing: Theme.type.labelSm.tracking
        renderType: Text.NativeRendering

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motion.instant
            }
        }
    }

    Item {
        id: tile

        x: indexText.x + indexText.width + Theme.space.snug
        width: Theme.size.launcherIconTile
        height: Theme.size.launcherIconTile
        anchors.verticalCenter: parent.verticalCenter

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: root.current ? Theme.color.bgBase : Theme.color.surface2
            border.width: Theme.size.hairline
            border.color: Theme.color.borderSubtle

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.instant
                }
            }
        }

        DotCluster {
            anchors.centerIn: parent
            pattern: ["11", "11", "11"]
            dotSize: Theme.space.xxs
            pitch: Theme.space.xs
            color: root.current ? Theme.color.textInverse : Theme.color.textSecondary
            visible: !root.isImage
        }

        Canvas {
            id: imageGlyph
            anchors.centerIn: parent
            width: Theme.size.launcherIconGlyph
            height: Theme.size.launcherIconGlyph
            visible: root.isImage
            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.strokeStyle = root.current
                    ? String(Theme.color.textInverse)
                    : String(Theme.color.textSecondary)
                ctx.lineWidth = Theme.size.iconStroke
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                const inset = Theme.space.xs
                const right = width - inset
                const bottom = height - inset
                ctx.beginPath()
                ctx.rect(inset, inset, right - inset, bottom - inset)
                ctx.moveTo(inset, bottom - 3)
                ctx.lineTo(inset + 5, bottom - 8)
                ctx.lineTo(inset + 9, bottom - 4)
                ctx.lineTo(inset + 12, bottom - 7)
                ctx.lineTo(right, bottom - 3)
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(right - 5, inset + 4, 1.5, 0, Math.PI * 2)
                ctx.stroke()
            }
        }
    }

    Text {
        id: previewText

        anchors.left: tile.right
        anchors.leftMargin: Theme.space.snug
        anchors.right: timeText.visible ? timeText.left : arrowItem.left
        anchors.rightMargin: Theme.space.md
        anchors.verticalCenter: parent.verticalCenter
        text: root.isImage ? root.kindLabel : root.previewText
        elide: Text.ElideRight
        color: root.current ? Theme.color.textInverse : Theme.color.textPrimary
        font.family: root.isImage ? Theme.font.mono[0] : Theme.font.ui[0]
        font.pixelSize: root.isImage ? Theme.type.monoValue.size : Theme.type.body.size
        font.weight: root.isImage ? Theme.type.monoValue.weight : Theme.type.body.weight
        font.letterSpacing: root.isImage ? Theme.type.monoValue.tracking : 0
        font.capitalization: root.isImage ? Font.AllUppercase : Font.MixedCase
        renderType: root.isImage ? Text.NativeRendering : Text.QtRendering
    }

    Text {
        id: timeText

        anchors.right: arrowItem.left
        anchors.rightMargin: Theme.space.sm
        anchors.verticalCenter: parent.verticalCenter
        text: root.timeLabel
        visible: text.length > 0
        color: root.current ? Theme.color.textInverse : Theme.color.textTertiary
        opacity: root.current ? 0.64 : 1.0
        font.family: Theme.font.mono[0]
        font.pixelSize: Theme.type.monoValue.size
        font.weight: Theme.type.monoValue.weight
        font.letterSpacing: Theme.type.monoValue.tracking
        renderType: Text.NativeRendering

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motion.instant
            }
        }
    }

    Item {
        id: arrowItem

        readonly property bool on: root.engaged
        readonly property color glyphColor: root.current
            ? Theme.color.textInverse : Theme.color.textPrimary
        readonly property real shiftBase: arrowItem.on ? 0 : -Theme.space.xs
        property real shift: arrowItem.shiftBase

        width: Theme.space.lg
        height: Theme.space.lg
        anchors.right: parent.right
        anchors.rightMargin: Theme.space.md
        anchors.verticalCenter: parent.verticalCenter
        opacity: arrowItem.on ? 1 : 0
        transform: Translate {
            x: arrowItem.shift
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motion.instant
            }
        }
        Behavior on shift {
            NumberAnimation {
                duration: Theme.motion.instant
            }
        }
        onOnChanged: arrowCanvas.requestPaint()
        onGlyphColorChanged: arrowCanvas.requestPaint()

        Canvas {
            id: arrowCanvas
            anchors.fill: parent
            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)

                const y = height / 2
                const tip = width - Theme.space.sm
                const head = Theme.space.xs + 1
                ctx.strokeStyle = String(arrowItem.glyphColor)
                ctx.lineWidth = Theme.size.iconStroke
                ctx.lineCap = "round"
                ctx.lineJoin = "round"
                ctx.beginPath()
                ctx.moveTo(Theme.space.xxs, y)
                ctx.lineTo(tip, y)
                ctx.moveTo(tip - head, y - head)
                ctx.lineTo(tip, y)
                ctx.lineTo(tip - head, y + head)
                ctx.stroke()
            }
        }
    }

    DotRule {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: tile.x + tile.width + Theme.space.snug
        visible: root.showDivider && !root.engaged
    }

    MouseArea {
        id: rowMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }
}

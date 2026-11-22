pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.ui
import qs.ui.components

// Launcher manifest row: registration index, circular icon tile, name,
// trailing mono metadata and a long-stem arrow on hover (§7.2).
// Keyboard "current" row is the primary-action capsule: inverse fill (§8.1).
Item {
    id: root

    property var app: null
    property int number: 0
    property bool current: false
    property bool showDivider: false

    signal activated()

    readonly property bool hovered: rowMouse.containsMouse
    readonly property bool engaged: root.current || root.hovered
    readonly property string appName: root.app && root.app.name
        ? String(root.app.name) : ""
    readonly property string appGenericName: root.app && root.app.genericName
        ? String(root.app.genericName) : ""
    readonly property string iconSource: root.app && root.app.icon
        ? Quickshell.iconPath(String(root.app.icon), true) : ""
    readonly property string indexLabel: root.number > 0
        ? String(root.number).padStart(2, "0") : "--"

    width: parent ? parent.width : 0
    height: Theme.size.launcherRowHeight

    Accessible.role: Accessible.ListItem
    Accessible.name: root.appName
    Accessible.description: root.appGenericName

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
        text: root.indexLabel
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

        Image {
            id: appIcon
            anchors.centerIn: parent
            width: Theme.size.launcherIconGlyph
            height: Theme.size.launcherIconGlyph
            source: root.iconSource
            sourceSize.width: 64
            sourceSize.height: 64
            fillMode: Image.PreserveAspectFit
            smooth: true
            asynchronous: true
            visible: source !== "" && status === Image.Ready
        }

        Text {
            anchors.centerIn: parent
            text: root.appName.length > 0 ? root.appName.charAt(0).toUpperCase() : "?"
            visible: !appIcon.visible
            color: root.current ? Theme.color.textInverse : Theme.color.textSecondary
            font.family: Theme.font.mono[0]
            font.pixelSize: Theme.type.label.size
            font.weight: Theme.type.label.weight
            font.capitalization: Font.AllUppercase
            renderType: Text.NativeRendering
        }
    }

    Text {
        id: nameText

        anchors.left: tile.right
        anchors.leftMargin: Theme.space.snug
        anchors.right: genericText.visible ? genericText.left : arrowItem.left
        anchors.rightMargin: Theme.space.md
        anchors.verticalCenter: parent.verticalCenter
        text: root.appName
        elide: Text.ElideRight
        color: root.current ? Theme.color.textInverse : Theme.color.textPrimary
        font.family: Theme.font.ui[0]
        font.pixelSize: Theme.type.body.size
        font.weight: Theme.type.body.weight
    }

    Text {
        id: genericText

        anchors.right: arrowItem.left
        anchors.rightMargin: Theme.space.sm
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(parent.width * 0.38, implicitWidth)
        text: root.appGenericName
        visible: text.length > 0
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignRight
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

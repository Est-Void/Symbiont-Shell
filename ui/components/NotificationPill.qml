pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.ui
import qs.ui.components

Item {
    id: root

    property real mascotCenterX: 0
    property real mascotBottomY: Theme.size.dropHeight
    property bool suspended: false

    property var shown: null
    property string phase: "idle"

    property real flowX: 1
    property real flowY: 1
    property real riseOffset: 0
    property real contentOpacity: 0
    property real neckOpacity: 0
    property real neckPinch: 0
    property real _deadline: 0
    property real _pausedAt: 0

    signal attentionRequested(real px, real py)
    signal attentionReleased()

    readonly property real margin: Theme.space.lg
    readonly property real padX: Theme.space.snug
    readonly property real padY: Theme.space.sm
    readonly property real iconSize: Theme.size.notificationIcon
    readonly property real closeSize: Theme.size.notificationClose
    readonly property real rowGap: Theme.space.snug
    readonly property bool hovered: pillHover.hovered || closeMouse.containsMouse
    readonly property bool held: root.hovered || root.activeFocus || closeBtn.activeFocus
    readonly property bool expanded: root.held && root.phase === "visible"
    readonly property color fillColor: clickArea.pressed ? Theme.color.surface3
        : root.held ? Theme.color.surface2 : Theme.color.surface1

    readonly property int enterDuration: Theme.motion.reducedMotion
        ? Theme.motion.instant : Theme.motion.notificationIn
    readonly property int leaveDuration: Theme.motion.reducedMotion
        ? Theme.motion.instant : Theme.motion.notificationOut

    width: Theme.size.notificationWidth
    height: implicitHeight
    implicitHeight: row.height + root.padY * 2

    x: Math.max(root.margin,
                Math.min((parent ? parent.width : root.width) - root.width - root.margin,
                         root.mascotCenterX - root.width / 2))
    y: root.mascotBottomY + Theme.space.snug

    visible: opacity > 0.001 && !root.suspended
    opacity: 0
    activeFocusOnTab: visible
    focus: false

    Accessible.role: Accessible.Notification
    Accessible.name: root.shown
        ? ((root.shown.urgent ? "Critical: " : "") + root.shown.appName + ": " + root.shown.message)
        : ""

    transform: [
        Translate { y: root.riseOffset },
        Scale {
            origin.x: Math.max(0, Math.min(root.width, root.mascotCenterX - root.x))
            origin.y: 0
            xScale: root.flowX
            yScale: root.flowY
        }
    ]

    Keys.onReturnPressed: root.requestActivate()
    Keys.onEnterPressed: root.requestActivate()
    Keys.onSpacePressed: root.requestActivate()
    Keys.onEscapePressed: root.requestDismiss()

    Squircle {
        id: background
        anchors.fill: parent
        n: 4
        radius: Theme.radius.md
        fillColor: root.fillColor
        strokeColor: Theme.color.borderSubtle
        strokeWidth: Theme.size.hairline
    }

    Squircle {
        anchors.fill: parent
        anchors.margins: -Theme.size.focusRingOffset
        n: 4
        radius: Theme.radius.md
        fillColor: "transparent"
        strokeColor: Theme.color.accent
        strokeWidth: Theme.size.focusRingWidth
        visible: root.activeFocus
    }

    HoverHandler {
        id: pillHover
    }

    MouseArea {
        id: clickArea
        anchors.fill: parent
        enabled: root.phase === "visible"
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton

        onClicked: function (mouse) {
            if (root.phase !== "visible")
                return
            if (mouse.button === Qt.RightButton)
                root.requestDismiss()
            else
                root.requestActivate()
        }
    }

    Item {
        id: contentLayer
        anchors.fill: parent
        opacity: root.contentOpacity
        enabled: root.phase === "visible"

        Item {
            id: row
            x: root.padX
            y: root.padY
            width: root.width - root.padX * 2 - root.closeSize - root.rowGap
            height: Math.max(root.iconSize, textColumn.implicitHeight)

            Item {
                id: iconBox
                x: 0
                y: root.expanded ? 0 : (row.height - height) / 2
                width: root.iconSize
                height: root.iconSize

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: Theme.color.surface2
                    border.width: Theme.size.hairline
                    border.color: Theme.color.borderSubtle
                }

                Image {
                    id: appIcon
                    anchors.centerIn: parent
                    width: root.iconSize - Theme.space.snug
                    height: width
                    source: root.shown ? root.shown.icon : ""
                    sourceSize.width: 48
                    sourceSize.height: 48
                    visible: source !== "" && status === Image.Ready
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                    layer.enabled: visible
                    layer.effect: MultiEffect {
                        saturation: -1.0
                        contrast: 1.05
                    }
                }

                Item {
                    visible: !appIcon.visible
                    width: 15
                    height: 15
                    anchors.centerIn: parent

                    Repeater {
                        model: 9

                        Rectangle {
                            required property int index
                            x: (index % 3) * 6
                            y: Math.floor(index / 3) * 6
                            width: 3
                            height: 3
                            radius: 1.5
                            color: Theme.color.textSecondary
                        }
                    }
                }

                Rectangle {
                    id: urgentDot
                    visible: root.shown ? root.shown.urgent : false
                    width: 6
                    height: 6
                    radius: width / 2
                    color: Theme.color.accent
                    border.width: 2
                    border.color: Theme.color.surface1
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: -1
                    anchors.topMargin: -1
                }
            }

            Column {
                id: textColumn
                x: iconBox.width + root.rowGap
                y: 0
                width: row.width - x
                spacing: Theme.space.xxs

                Text {
                    id: appLabel
                    width: textColumn.width
                    text: root.shown
                        ? (root.shown.appName.length > 0 ? root.shown.appName : "NOTIFICATION")
                        : ""
                    color: Theme.color.textSecondary
                    elide: Text.ElideRight
                    font.family: Theme.font.mono[0]
                    font.pixelSize: Theme.type.labelSm.size
                    font.weight: Theme.type.labelSm.weight
                    font.letterSpacing: Theme.type.labelSm.tracking
                    font.capitalization: Font.AllUppercase
                    renderType: Text.NativeRendering
                }

                Text {
                    width: textColumn.width
                    text: root.shown ? root.shown.message : ""
                    color: Theme.color.textPrimary
                    wrapMode: Text.WordWrap
                    maximumLineCount: root.expanded ? 12 : 1
                    elide: Text.ElideRight
                    font.family: Theme.font.ui[0]
                    font.pixelSize: Theme.type.bodySm.size
                    font.weight: Theme.type.bodySm.weight
                    font.letterSpacing: Theme.type.bodySm.tracking
                    lineHeight: Theme.type.bodySm.lineHeight
                    lineHeightMode: Text.ProportionalHeight
                }
            }
        }

        Item {
            id: closeBtn
            x: root.width - root.padX - root.closeSize
            y: root.expanded ? root.padY : (root.height - height) / 2
            width: root.closeSize
            height: root.closeSize
            activeFocusOnTab: root.phase === "visible"
            opacity: 1

            Accessible.role: Accessible.Button
            Accessible.name: "Dismiss notification"

            Keys.onReturnPressed: root.requestDismiss()
            Keys.onEnterPressed: root.requestDismiss()
            Keys.onSpacePressed: root.requestDismiss()
            Keys.onEscapePressed: root.requestDismiss()

            Rectangle {
                anchors.fill: parent
                anchors.margins: -Theme.size.focusRingOffset
                radius: height / 2
                color: "transparent"
                border.width: Theme.size.focusRingWidth
                border.color: Theme.color.accent
                visible: closeBtn.activeFocus
            }

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: closeMouse.containsMouse || closeBtn.activeFocus
                       ? Theme.color.surface3 : Theme.color.transparent
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
                    strokeColor: root.held || closeBtn.activeFocus
                                 ? Theme.color.accentHover : Theme.color.accent
                    strokeWidth: 1.5
                    capStyle: ShapePath.RoundCap

                    PathMove { x: 2; y: 2 }
                    PathLine { x: 10; y: 10 }
                    PathMove { x: 10; y: 2 }
                    PathLine { x: 2; y: 10 }
                }
            }

            MouseArea {
                id: closeMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.requestDismiss()
            }
        }
    }

    ParallelAnimation {
        id: enterAnim

        SequentialAnimation {
            NumberAnimation {
                target: root
                property: "flowX"
                to: 0.30
                duration: Math.round(root.enterDuration * 0.32)
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: root
                property: "flowX"
                to: 1
                duration: Math.round(root.enterDuration * 0.68)
                easing.type: Easing.OutQuint
            }
        }

        SequentialAnimation {
            NumberAnimation {
                target: root
                property: "flowY"
                to: Theme.size.notificationStretch
                duration: Math.round(root.enterDuration * 0.72)
                easing.type: Easing.OutQuint
            }
            NumberAnimation {
                target: root
                property: "flowY"
                to: 1
                duration: Math.round(root.enterDuration * 0.28)
                easing.type: Easing.InOutCubic
            }
        }

        NumberAnimation {
            target: root
            property: "riseOffset"
            to: 0
            duration: root.enterDuration
            easing.type: Easing.OutQuint
        }

        SequentialAnimation {
            PauseAnimation {
                duration: Math.round(root.enterDuration * 0.42)
            }
            NumberAnimation {
                target: root
                property: "contentOpacity"
                to: 1
                duration: Math.round(root.enterDuration * 0.46)
                easing.type: Easing.OutCubic
            }
        }

        SequentialAnimation {
            PauseAnimation {
                duration: Math.round(root.enterDuration * 0.75)
            }
            NumberAnimation {
                target: root
                property: "neckPinch"
                to: 1
                duration: Math.round(root.enterDuration * 0.2)
                easing.type: Easing.InCubic
            }
        }

        SequentialAnimation {
            PauseAnimation {
                duration: Math.round(root.enterDuration * 0.9)
            }
            NumberAnimation {
                target: root
                property: "neckOpacity"
                to: 0
                duration: Math.round(root.enterDuration * 0.1)
                easing.type: Easing.InCubic
            }
        }

        onFinished: {
            if (root.phase !== "appearing")
                return
            root.phase = "visible"
            if (root.shown && root.shown.timeout > 0)
                root._deadline = Date.now() + root.shown.timeout
        }
    }

    ParallelAnimation {
        id: absorbAnim

        NumberAnimation {
            target: root
            property: "contentOpacity"
            to: 0
            duration: Math.round(root.leaveDuration * 0.35)
            easing.type: Easing.InCubic
        }

        SequentialAnimation {
            NumberAnimation {
                target: root
                property: "flowX"
                to: 0.32
                duration: Math.round(root.leaveDuration * 0.45)
                easing.type: Easing.InCubic
            }
            NumberAnimation {
                target: root
                property: "flowX"
                to: Theme.size.notificationFlowOutX
                duration: Math.round(root.leaveDuration * 0.55)
                easing.type: Easing.InQuart
            }
        }

        SequentialAnimation {
            NumberAnimation {
                target: root
                property: "flowY"
                to: Theme.size.notificationStretch
                duration: Math.round(root.leaveDuration * 0.35)
                easing.type: Easing.OutCubic
            }
            NumberAnimation {
                target: root
                property: "flowY"
                to: Theme.size.notificationFlowOutY
                duration: Math.round(root.leaveDuration * 0.65)
                easing.type: Easing.InQuart
            }
        }

        NumberAnimation {
            target: root
            property: "riseOffset"
            to: -Theme.size.notificationRise
            duration: root.leaveDuration
            easing.type: Easing.InQuart
        }

        SequentialAnimation {
            PauseAnimation {
                duration: Math.round(root.leaveDuration * 0.7)
            }
            NumberAnimation {
                target: root
                property: "opacity"
                to: 0
                duration: Math.round(root.leaveDuration * 0.3)
                easing.type: Easing.InCubic
            }
        }

        SequentialAnimation {
            PauseAnimation {
                duration: Math.round(root.leaveDuration * 0.15)
            }
            NumberAnimation {
                target: root
                property: "neckOpacity"
                to: 1
                duration: Math.round(root.leaveDuration * 0.25)
                easing.type: Easing.OutCubic
            }
            PauseAnimation {
                duration: Math.round(root.leaveDuration * 0.35)
            }
            NumberAnimation {
                target: root
                property: "neckOpacity"
                to: 0
                duration: Math.round(root.leaveDuration * 0.25)
                easing.type: Easing.InCubic
            }
        }

        NumberAnimation {
            target: root
            property: "neckPinch"
            to: 0
            duration: Math.round(root.leaveDuration * 0.6)
            easing.type: Easing.OutCubic
        }

        onFinished: root._finishAbsorb()
    }

    Timer {
        id: lifeTimer
        interval: 200
        repeat: true
        running: root.phase === "visible" && root.shown !== null
                 && root.shown.timeout > 0 && !root.suspended

        onTriggered: {
            if (root.phase !== "visible" || !root.shown)
                return
            if (root.held) {
                if (root._pausedAt <= 0)
                    root._pausedAt = Date.now()
                return
            }
            if (root._deadline > 0 && Date.now() >= root._deadline)
                root._expireCurrent()
        }
    }

    Timer {
        id: nextTimer
        interval: Theme.motion.notificationQueue
        onTriggered: root._openNext()
    }

    Connections {
        target: Notify
        function onRevisionChanged() { root._onNotifyChanged() }
    }

    Component.onCompleted: root._openNext()

    onHeldChanged: {
        if (root.phase !== "visible" || !root.shown)
            return
        if (root.held) {
            if (root._deadline > 0 && root._pausedAt <= 0)
                root._pausedAt = Date.now()
        } else if (root._pausedAt > 0) {
            root._deadline += Date.now() - root._pausedAt
            root._pausedAt = 0
        }
    }

    onSuspendedChanged: {
        if (root.suspended) {
            if (root.phase !== "idle" && root._deadline > 0 && root._pausedAt <= 0)
                root._pausedAt = Date.now()
            return
        }
        if (root._pausedAt > 0 && root._deadline > 0) {
            root._deadline += Date.now() - root._pausedAt
            root._pausedAt = 0
        }
        if (root.phase === "idle") {
            if (Notify.count > 0)
                root._openNext()
        } else {
            root._emitAttention()
        }
    }

    function _snapshot(entry) {
        const summary = String(entry.summary || "")
        const body = String(entry.body || "")
        let message = body
        if (summary.length > 0 && body.length > 0)
            message = summary + ": " + body
        else if (summary.length > 0 && body.length === 0)
            message = summary
        return {
            id: Number(entry.nid),
            seq: Number(entry.seq),
            appName: String(entry.appName || ""),
            message: message,
            icon: String(entry.icon || ""),
            urgent: entry.urgent === true,
            timeout: Number(entry.timeout || 0)
        }
    }

    function _head() {
        return Notify.count > 0 ? Notify.model.get(0) : null
    }

    function _openNext() {
        if (root.phase !== "idle" || root.suspended)
            return
        const entry = root._head()
        if (!entry)
            return

        root.shown = root._snapshot(entry)
        root._deadline = 0
        root._pausedAt = 0
        root.phase = "appearing"
        root.opacity = 1
        root.contentOpacity = 0
        root.neckOpacity = 1
        root.neckPinch = 0
        root.flowX = Theme.size.notificationFlowInX
        root.flowY = Theme.size.notificationFlowInY
        root.riseOffset = -Theme.size.notificationRise
        nextTimer.stop()
        enterAnim.restart()
        root._emitAttention()
    }

    function _onNotifyChanged() {
        if (root.phase === "idle") {
            if (Notify.count > 0)
                root._openNext()
            return
        }
        if (!root.shown)
            return
        const head = root._head()
        if (head && Number(head.nid) === root.shown.id && Number(head.seq) === root.shown.seq)
            return
        if (root.phase !== "absorbing")
            root._beginAbsorb()
    }

    function _beginAbsorb() {
        if (root.phase === "absorbing" || root.phase === "idle")
            return
        enterAnim.stop()
        root.phase = "absorbing"
        root._emitAttention()
        absorbAnim.restart()
    }

    function _finishAbsorb() {
        if (root.phase !== "absorbing")
            return
        root.phase = "idle"
        root.shown = null
        root.opacity = 0
        root.contentOpacity = 0
        root.neckOpacity = 0
        root.neckPinch = 0
        root.flowX = 1
        root.flowY = 1
        root.riseOffset = 0
        root.attentionReleased()
        nextTimer.restart()
    }

    function _expireCurrent() {
        if (!root.shown)
            return
        const id = root.shown.id
        Notify.expireToast(id)
        root._beginAbsorb()
    }

    function requestActivate() {
        if (root.phase !== "visible" || !root.shown)
            return
        const id = root.shown.id
        Notify.activate(id)
        root._beginAbsorb()
    }

    function requestDismiss() {
        if (root.phase !== "visible" || !root.shown)
            return
        const id = root.shown.id
        Notify.dismissToast(id)
        root._beginAbsorb()
    }

    function _emitAttention() {
        if (!root.shown)
            return
        root.attentionRequested(root.x + root.width / 2,
                                root.y + root.height / 2)
    }
}

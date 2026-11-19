import QtQuick
import QtQuick.Shapes
import Quickshell.Io
import qs.ui

Item {
    id: root

    anchors.fill: parent

    property var screen: null

    property real aimX: 0
    property real aimY: 0
    property real trackAngle: 0
    property real trackRadius: 0

    property bool rolling: false
    property bool _rollLoop: false

    property real blink: 0
    property bool sleeping: false
    property real sleep: 0
    property real lastSaccade: 0

    property real lastMovement: Date.now()
    property real lastCursorX: -99999
    property real lastCursorY: -99999
    property bool cursorTracking: false
    property int cursorFailures: 0
    property bool _blinking: false
    property bool _doubleBlink: false

    readonly property real cx: width / 2
    readonly property real cy: height / 2
    readonly property real ringRadius: Theme.size.mascotRingRadius
    readonly property real gapAngle: Theme.size.mascotGapAngle * (1 - Theme.size.mascotSleepGap * root.sleep)
    readonly property real sweep: 180 - root.gapAngle
    readonly property real sphereDiameter: 2 * ringRadius * Theme.size.mascotSphereRatio
    readonly property real closure: Math.min(1, root.blink + root.sleep * Theme.size.mascotSleepLid)
    readonly property real eyeWidth: root.sphereDiameter * (1 + Theme.size.mascotSquash * root.closure)
    readonly property real eyeHeight: root.sphereDiameter - (root.sphereDiameter - Theme.size.mascotBlinkHeight) * root.closure
    readonly property real eyeX: (root.screen ? root.screen.x : 0) + cx
    readonly property real eyeY: (root.screen ? root.screen.y : 0) + cy

    Accessible.role: Accessible.Graphic
    Accessible.name: "Symbiont mascot"

    Behavior on sleep {
        enabled: !Theme.motion.reducedMotion
        NumberAnimation { duration: Theme.motion.slow; easing.type: Easing.InOutCubic }
    }

    Behavior on blink {
        NumberAnimation { duration: Theme.motion.blinkMove; easing.type: Easing.OutCubic }
    }

    onSleepingChanged: {
        root.sleep = root.sleeping ? 1 : 0
        if (root.sleeping) {
            root.stopRoll()
            root.aimX = 0
            root.aimY = 0
            root.trackTo(0, 0, Theme.motion.slow)
        } else {
            root.blinkOnce(false)
        }
    }

    function animateOrbit(angle, radius, dur, easingType) {
        let d = angle - orbit.angle
        d = ((d + 180) % 360 + 360) % 360 - 180
        angleAnim.stop()
        radiusAnim.stop()
        angleAnim.easing.type = easingType
        angleAnim.from = orbit.angle
        angleAnim.to = orbit.angle + d
        angleAnim.duration = dur
        radiusAnim.easing.type = easingType
        radiusAnim.from = orbit.radius
        radiusAnim.to = radius
        radiusAnim.duration = dur
        angleAnim.start()
        radiusAnim.start()
    }

    function trackTo(tx, ty, dur) {
        const mag = Math.min(1, Math.sqrt(tx * tx + ty * ty))
        root.trackRadius = mag * Theme.size.mascotGazeRange
        root.trackAngle = Math.atan2(ty, tx) * 180 / Math.PI
        root.animateOrbit(root.trackAngle, root.trackRadius,
                          Theme.motion.reducedMotion ? Theme.motion.instant : dur,
                          Easing.OutQuint)
    }

    function aimGaze(tx, ty) {
        tx = Math.max(-1, Math.min(1, tx))
        ty = Math.max(-1, Math.min(1, ty))
        if (root.sleeping) {
            tx = 0
            ty = 0
        }
        const dx = tx - root.aimX
        const dy = ty - root.aimY
        if (dx * dx + dy * dy < Theme.size.gazeSaccadeThreshold * Theme.size.gazeSaccadeThreshold)
            return
        const now = Date.now()
        if (now - root.lastSaccade < Theme.motion.saccadeHold)
            return
        root.lastSaccade = now
        if (root.rolling)
            root.stopRoll()
        root.aimX = tx
        root.aimY = ty
        root.trackTo(tx, ty, Theme.motion.saccade)
        if (Math.random() < 0.12)
            root.blinkOnce(false)
    }

    function aimLocal(px, py) {
        if (root.cursorTracking)
            return
        const hw = root.width / 2
        const hh = root.height / 2
        if (hw <= 0 || hh <= 0)
            return
        root.lastMovement = Date.now()
        if (root.sleeping)
            root.sleeping = false
        root.aimGaze((px - root.cx) / hw, (py - root.cy) / hh)
    }

    function startRoll() {
        if (Theme.motion.reducedMotion || root.rolling || root.sleeping)
            return
        root.rolling = true
        root._rollLoop = Math.random() < 0.35
        const dir = Math.random() < 0.5 ? -1 : 1
        const arcSweep = root._rollLoop ? 360 : 110 + Math.random() * 150
        const dur = Math.round(Theme.motion.roll * arcSweep / 180)
        angleAnim.stop()
        radiusAnim.stop()
        angleAnim.easing.type = Easing.InOutCubic
        angleAnim.from = orbit.angle
        angleAnim.to = orbit.angle + dir * arcSweep
        angleAnim.duration = dur
        radiusAnim.easing.type = Easing.OutCubic
        radiusAnim.from = orbit.radius
        radiusAnim.to = Theme.size.mascotRollRadius
        radiusAnim.duration = Math.min(dur, Theme.motion.base)
        angleAnim.start()
        radiusAnim.start()
        rollDone.interval = dur + Theme.motion.rollHold
        rollDone.restart()
    }

    function stopRoll() {
        if (!root.rolling)
            return
        rollDone.stop()
        angleAnim.stop()
        radiusAnim.stop()
        root.rolling = false
    }

    function finishRoll() {
        if (!root.rolling)
            return
        root.rolling = false
        if (root._rollLoop) {
            ring.arcAngle += 360
            root._rollLoop = false
        }
        root.trackTo(root.aimX, root.aimY, Theme.motion.base)
    }

    function blinkOnce(doubleOk) {
        if (Theme.motion.reducedMotion || root._blinking)
            return
        root._blinking = true
        root._doubleBlink = doubleOk && Math.random() < 0.3
        root.blink = 1
        blinkClose.restart()
    }

    Timer {
        id: blinkClose
        interval: Theme.motion.blinkHold
        onTriggered: {
            root.blink = 0
            root._blinking = false
            if (root._doubleBlink) {
                root._doubleBlink = false
                doubleBlink.restart()
            }
        }
    }

    Timer {
        id: doubleBlink
        interval: Theme.motion.doubleBlinkGap
        onTriggered: root.blinkOnce(false)
    }

    Timer {
        id: rollDone
        onTriggered: root.finishRoll()
    }

    Process {
        id: cursorProbe
        command: ["sh", "-c", "command -v hyprctl"]
        onExited: function (exitCode, exitStatus) {
            root.cursorTracking = exitCode === 0
        }
    }

    Component.onCompleted: if (!Compositor.isNiri) cursorProbe.running = true

    HoverHandler {
        id: localHover
        onPointChanged: {
            if (!localHover.hovered)
                return
            const p = localHover.point.position
            root.aimLocal(p.x, p.y)
        }
        onHoveredChanged: {
            if (!localHover.hovered)
                return
            const p = localHover.point.position
            root.aimLocal(p.x, p.y)
        }
    }

    Process {
        id: cursorQuery
        command: ["hyprctl", "-j", "cursorpos"]
        stdout: StdioCollector {
            onStreamFinished: {
                let p
                try {
                    p = JSON.parse(text)
                } catch (e) {
                    if (++root.cursorFailures > 3)
                        root.cursorTracking = false
                    return
                }
                root.cursorFailures = 0
                if (p.x === root.lastCursorX && p.y === root.lastCursorY)
                    return
                root.lastCursorX = p.x
                root.lastCursorY = p.y
                root.lastMovement = Date.now()
                if (root.sleeping)
                    root.sleeping = false
                root.aimGaze((p.x - root.eyeX) / Theme.size.gazeSpanX,
                             (p.y - root.eyeY) / Theme.size.gazeSpanY)
            }
        }
        onExited: function (exitCode, exitStatus) {
            if (exitCode !== 0 && ++root.cursorFailures > 3)
                root.cursorTracking = false
        }
    }

    Timer {
        id: poll
        interval: root.sleeping ? Theme.motion.pollIdle : Theme.motion.pollActive
        repeat: true
        running: root.cursorTracking
        onTriggered: {
            if (!cursorQuery.running)
                cursorQuery.running = true
        }
    }

    Timer {
        interval: Theme.motion.idleGaze
        repeat: true
        running: !Theme.motion.reducedMotion && !root.sleeping && !root.rolling
        onTriggered: {
            if (Date.now() - root.lastMovement > Theme.motion.wanderAfter)
                root.aimGaze(Math.random() * 2 - 1, Math.random() * 1.5 - 0.75)
        }
    }

    Timer {
        interval: Theme.motion.play
        repeat: true
        running: !Theme.motion.reducedMotion && !root.sleeping
        onTriggered: {
            if (!root.rolling && Date.now() - root.lastMovement > Theme.motion.wanderAfter && Math.random() < 0.5)
                root.startRoll()
        }
    }

    Timer {
        interval: Theme.motion.sleepCheck
        repeat: true
        running: true
        onTriggered: {
            const idle = Date.now() - root.lastMovement
            if (!root.sleeping && idle > Theme.motion.sleepAfter)
                root.sleeping = true
            else if (root.sleeping && idle < Theme.motion.sleepAfter)
                root.sleeping = false
        }
    }

    Timer {
        interval: Theme.motion.blink
        repeat: true
        running: !Theme.motion.reducedMotion && !root.sleeping
        onTriggered: root.blinkOnce(true)
    }

    Item {
        id: ring
        property real arcAngle: 0
        x: root.cx - root.ringRadius
        y: root.cy - root.ringRadius
        width: root.ringRadius * 2
        height: root.ringRadius * 2
        rotation: ring.arcAngle
        opacity: 1 - Theme.size.mascotSleepOpacity * root.sleep

        Behavior on rotation {
            enabled: !Theme.motion.reducedMotion
            NumberAnimation { duration: Theme.motion.slow; easing.type: Easing.InOutCubic }
        }

        Timer {
            interval: Theme.motion.arcTurn
            repeat: true
            running: !Theme.motion.reducedMotion && !root.sleeping
            onTriggered: {
                const steps = [90, 180, 270]
                ring.arcAngle += steps[Math.floor(Math.random() * steps.length)]
            }
        }

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer

            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme.color.textPrimary
                strokeWidth: Theme.size.mascotArcWidth
                capStyle: ShapePath.RoundCap
                startX: root.ringRadius + root.ringRadius * Math.cos((180 + root.gapAngle / 2) * Math.PI / 180)
                startY: root.ringRadius + root.ringRadius * Math.sin((180 + root.gapAngle / 2) * Math.PI / 180)

                PathAngleArc {
                    centerX: root.ringRadius
                    centerY: root.ringRadius
                    radiusX: root.ringRadius
                    radiusY: root.ringRadius
                    startAngle: 180 + root.gapAngle / 2
                    sweepAngle: root.sweep
                }
            }

            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme.color.textPrimary
                strokeWidth: Theme.size.mascotArcWidth
                capStyle: ShapePath.RoundCap
                startX: root.ringRadius + root.ringRadius * Math.cos((root.gapAngle / 2) * Math.PI / 180)
                startY: root.ringRadius + root.ringRadius * Math.sin((root.gapAngle / 2) * Math.PI / 180)

                PathAngleArc {
                    centerX: root.ringRadius
                    centerY: root.ringRadius
                    radiusX: root.ringRadius
                    radiusY: root.ringRadius
                    startAngle: root.gapAngle / 2
                    sweepAngle: root.sweep
                }
            }
        }
    }

    Item {
        id: orbit
        x: root.cx
        y: root.cy
        width: 0
        height: 0
        property real angle: 0
        property real radius: 0
        rotation: orbit.angle

        NumberAnimation {
            id: angleAnim
            target: orbit
            property: "angle"
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            id: radiusAnim
            target: orbit
            property: "radius"
            easing.type: Easing.InOutCubic
        }

        Rectangle {
            id: sphere
            x: orbit.radius - width / 2
            y: -height / 2
            width: root.eyeWidth
            height: root.eyeHeight
            radius: height / 2
            rotation: -orbit.angle
            color: Theme.color.accent
        }
    }
}

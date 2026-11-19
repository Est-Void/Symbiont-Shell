pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property string mode: "dark"
    readonly property bool isDark: root.mode === "dark"

    readonly property QtObject dark: QtObject {
        readonly property color bgBase: "#000000"
        readonly property color bgRaised: "#0A0A0A"
        readonly property color surface1: "#141414"
        readonly property color surface2: "#1C1C1C"
        readonly property color surface3: "#262626"
        readonly property color surfaceInverse: "#F2F2F2"
        readonly property color textPrimary: "#FFFFFF"
        readonly property color textSecondary: "#A6A6A6"
        readonly property color textTertiary: "#6B6B6B"
        readonly property color textInverse: "#0A0A0A"
        readonly property color borderSubtle: "#14FFFFFF"
        readonly property color borderDefault: "#24FFFFFF"
        readonly property color borderStrong: "#3DFFFFFF"
        readonly property color accent: "#D71921"
        readonly property color accentHover: "#E8353B"
        readonly property color accentPressed: "#A81218"
        readonly property color accentText: "#FFFFFF"
        readonly property color accentMuted: "#26D71921"
        readonly property color scrim: "#B3000000"
        readonly property color transparent: "#00000000"
    }

    readonly property QtObject light: QtObject {
        readonly property color bgBase: "#F2F2F2"
        readonly property color bgRaised: "#FAFAFA"
        readonly property color surface1: "#FFFFFF"
        readonly property color surface2: "#E9E9E9"
        readonly property color surface3: "#DEDEDE"
        readonly property color surfaceInverse: "#0A0A0A"
        readonly property color textPrimary: "#0A0A0A"
        readonly property color textSecondary: "#5A5A5A"
        readonly property color textTertiary: "#8C8C8C"
        readonly property color textInverse: "#F5F5F5"
        readonly property color borderSubtle: "#14000000"
        readonly property color borderDefault: "#24000000"
        readonly property color borderStrong: "#3D000000"
        readonly property color accent: "#D71921"
        readonly property color accentHover: "#E8353B"
        readonly property color accentPressed: "#A81218"
        readonly property color accentText: "#FFFFFF"
        readonly property color accentMuted: "#26D71921"
        readonly property color scrim: "#B3000000"
        readonly property color transparent: "#00000000"
    }

    readonly property QtObject color: root.isDark ? root.dark : root.light

    readonly property QtObject font: QtObject {
        readonly property list<string> ui: ["Inter", "sans-serif"]
        readonly property list<string> display: ["Archivo", "Inter", "sans-serif"]
        readonly property list<string> mono: ["Space Mono", "IBM Plex Mono", "monospace"]
        readonly property list<string> dot: ["Doto", "Handjet", "monospace"]
    }

    readonly property QtObject type: QtObject {
        readonly property QtObject displayHero: QtObject {
            readonly property int size: 96
            readonly property int weight: 400
            readonly property real lineHeight: 1.00
            readonly property real tracking: 3.84
        }
        readonly property QtObject displayXl: QtObject {
            readonly property int size: 48
            readonly property int weight: 700
            readonly property real lineHeight: 1.05
            readonly property real tracking: -0.96
        }
        readonly property QtObject displayLg: QtObject {
            readonly property int size: 32
            readonly property int weight: 700
            readonly property real lineHeight: 1.10
            readonly property real tracking: -0.32
        }
        readonly property QtObject title: QtObject {
            readonly property int size: 24
            readonly property int weight: 600
            readonly property real lineHeight: 1.20
            readonly property real tracking: -0.24
        }
        readonly property QtObject heading: QtObject {
            readonly property int size: 20
            readonly property int weight: 600
            readonly property real lineHeight: 1.25
            readonly property real tracking: 0
        }
        readonly property QtObject body: QtObject {
            readonly property int size: 16
            readonly property int weight: 400
            readonly property real lineHeight: 1.50
            readonly property real tracking: 0
        }
        readonly property QtObject bodySm: QtObject {
            readonly property int size: 14
            readonly property int weight: 400
            readonly property real lineHeight: 1.45
            readonly property real tracking: 0
        }
        readonly property QtObject label: QtObject {
            readonly property int size: 12
            readonly property int weight: 400
            readonly property real lineHeight: 1.20
            readonly property real tracking: 0.96
        }
        readonly property QtObject labelSm: QtObject {
            readonly property int size: 10
            readonly property int weight: 400
            readonly property real lineHeight: 1.20
            readonly property real tracking: 1.20
        }
        readonly property QtObject monoValue: QtObject {
            readonly property int size: 13
            readonly property int weight: 400
            readonly property real lineHeight: 1.40
            readonly property real tracking: 0.26
        }
        readonly property QtObject numericDot: QtObject {
            readonly property int size: 32
            readonly property int weight: 400
            readonly property real lineHeight: 1.00
            readonly property real tracking: 1.28
        }
        readonly property QtObject numericMono: QtObject {
            readonly property int size: 24
            readonly property int weight: 400
            readonly property real lineHeight: 1.00
            readonly property real tracking: 0.96
        }
    }

    readonly property QtObject radius: QtObject {
        readonly property int xs: 8
        readonly property int sm: 12
        readonly property int md: 16
        readonly property int lg: 24
        readonly property int xl: 32
        readonly property int xxl: 40
        readonly property int pill: 9999
    }

    readonly property QtObject space: QtObject {
        readonly property int xxs: 2
        readonly property int xs: 4
        readonly property int sm: 8
        readonly property int snug: 12
        readonly property int md: 16
        readonly property int lg: 24
        readonly property int xl: 32
        readonly property int xxl: 48
        readonly property int xxxl: 64
        readonly property int huge: 96
    }

    readonly property QtObject motion: QtObject {
        readonly property int instant: 80
        readonly property int fast: 140
        readonly property int base: 200
        readonly property int slow: 320
        readonly property int arcTurn: 8000
        readonly property int idleGaze: 2400
        readonly property int blink: 3700
        readonly property int blinkMove: 90
        readonly property int blinkHold: 150
        readonly property int doubleBlinkGap: 150
        readonly property int saccade: 110
        readonly property int saccadeHold: 180
        readonly property int roll: 900
        readonly property int rollHold: 120
        readonly property int play: 4000
        readonly property int wanderAfter: 4500
        readonly property int sleepAfter: 16000
        readonly property int sleepCheck: 700
        readonly property int pollActive: 90
        readonly property int pollIdle: 240
        property bool reducedMotion: false
    }

    readonly property QtObject size: QtObject {
        readonly property real hairline: 1
        readonly property real topBarHeight: 38
        readonly property real dropWidth: 50
        readonly property real dropHeight: 36
        readonly property real dropShoulder: 14
        readonly property real dropBodyRadius: 18
        readonly property real dropTopRadius: 7
        readonly property real barWidth: 64
        readonly property real barExpandedWidth: 168
        readonly property real barPlaceholderWidth: 128
        readonly property real barTopRadius: 7
        readonly property real barBottomRadius: 14
        readonly property real menuWidth: 240
        readonly property real menuHeight: 160
        readonly property real menuTopRadius: 7
        readonly property real menuBottomRadius: 14
        readonly property real focusRingWidth: 2
        readonly property real focusRingOffset: 2
        readonly property real mascotRingRadius: 12
        readonly property real mascotArcWidth: 2
        readonly property real mascotGapAngle: 40
        readonly property real mascotSphereRatio: 0.55
        readonly property real mascotGazeRange: 2
        readonly property real mascotBlinkHeight: 3
        readonly property real mascotSquash: 0.16
        readonly property real mascotSleepLid: 0.62
        readonly property real mascotSleepGap: 0.75
        readonly property real mascotSleepOpacity: 0.55
        readonly property real gazeSaccadeThreshold: 0.12
        readonly property real mascotRollRadius: 8.5
        readonly property real gazeSpanX: 300
        readonly property real gazeSpanY: 240
    }
}

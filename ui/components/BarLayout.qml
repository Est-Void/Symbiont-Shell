import QtQuick
import qs.ui
import qs.ui.components

// The mascot is the anchor of the bar. Modules before it extend the droplet
// to the left, modules after it extend it to the right. With no modules on a
// side that side keeps the original droplet edge.
Item {
    id: root

    property var screen: null
    property var host: null
    property var leftModules: []
    property var rightModules: []

    property bool expanded: false
    property bool contentActive: true
    property bool volumeActive: false
    property bool mascotHidden: false

    property real mascotBox: Theme.size.dropWidth
    readonly property real gap: Theme.size.mascotModuleGap
    readonly property real edgePad: Theme.space.snug

    readonly property real leftWidth: leftZone.implicitWidth
    readonly property real rightWidth: rightZone.implicitWidth
    readonly property real mascotTargetX:
        root.leftWidth > 0 ? root.edgePad + root.leftWidth + root.gap : 0
    property real mascotX: root.expanded ? root.mascotTargetX : 0

    readonly property real contentWidth:
        (root.leftWidth > 0 ? root.edgePad + root.leftWidth + root.gap : 0)
        + root.mascotBox
        + (root.rightWidth > 0 ? root.gap + root.rightWidth + root.edgePad : 0)

    readonly property bool modulesVisible:
        root.contentActive
        && (root.expanded || root.width > root.mascotBox + 0.5)

    implicitWidth: root.expanded ? root.contentWidth : root.mascotBox
    implicitHeight: Theme.size.dropHeight

    Behavior on mascotX {
        NumberAnimation {
            duration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.slow
            easing.type: Easing.InOutCubic
        }
    }

    BarZone {
        id: leftZone
        x: root.mascotX - (root.leftWidth > 0 ? root.gap + root.leftWidth : 0)
        y: 0
        width: implicitWidth
        height: root.height
        modules: root.leftModules
        host: root.host
        visible: root.modulesVisible && root.leftWidth > 0
    }

    BarZone {
        id: rightZone
        x: root.mascotX + root.mascotBox + (root.rightWidth > 0 ? root.gap : 0)
        y: 0
        width: implicitWidth
        height: root.height
        modules: root.rightModules
        host: root.host
        visible: root.modulesVisible && root.rightWidth > 0
    }

    Mascot {
        id: mascot
        x: root.mascotX
        y: 0
        width: root.mascotBox
        height: root.height
        screen: root.screen
        volumeActive: root.volumeActive
        transformOrigin: Item.Center
        opacity: root.mascotHidden ? 0 : 1
        scale: root.mascotHidden ? 0.5 : 1
        visible: opacity > 0.01

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motion.slow
                easing.type: Easing.InOutCubic
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.motion.slow
                easing.type: Easing.InOutCubic
            }
        }
    }

    readonly property var mascotItem: mascot
    readonly property real mascotCenterX: mascot.x + mascot.width / 2
    readonly property real mascotCenterY: mascot.y + mascot.height / 2
}

import QtQuick
import qs.ui
import qs.ui.components

// The mascot is the anchor of the bar. It always sits at the center of the
// backdrop, so when the backdrop stretches open the mascot never moves: the
// bar grows uniformly around it. Modules sit attached to the mascot (revealed
// by the sweeping edges) and glide out to the bar edges once the backdrop is
// wider than the content needs. With no modules on a side that side keeps the
// original droplet edge.
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

    // Expanded backdrop width the host grows into; used to time the glide
    // from "attached to the mascot" to "pinned to the bar edges".
    property real fullWidth: 0

    property real mascotBox: Theme.size.dropWidth
    readonly property real gap: BarConfig.moduleGap
    readonly property real edgePad: BarConfig.edgePadding

    readonly property real leftWidth: leftZone.implicitWidth
    readonly property real rightWidth: rightZone.implicitWidth

    readonly property real mascotX: (root.width - root.mascotBox) / 2

    readonly property real contentWidth:
        (root.leftWidth > 0 ? root.edgePad + root.leftWidth + root.gap : 0)
        + root.mascotBox
        + (root.rightWidth > 0 ? root.gap + root.rightWidth + root.edgePad : 0)

    readonly property real expandT: root.fullWidth - root.contentWidth > 0.5
        ? Math.max(0, Math.min(1,
            (root.width - root.contentWidth) / (root.fullWidth - root.contentWidth)))
        : 0

    readonly property real leftAttachedX:
        root.mascotX - (root.leftWidth > 0 ? root.gap + root.leftWidth : 0)
    readonly property real rightAttachedX:
        root.mascotX + root.mascotBox + (root.rightWidth > 0 ? root.gap : 0)

    // Glide distance each zone travels between the attached-to-mascot layout
    // (at contentWidth) and the pinned-to-edges layout (at fullWidth). The
    // offset is interpolated, not the position, so zones never wobble.
    readonly property real leftGlide:
        (root.fullWidth - root.mascotBox) / 2
        - (root.leftWidth > 0 ? root.gap + root.leftWidth : 0) - root.edgePad
    readonly property real rightGlide:
        root.fullWidth - root.edgePad - root.rightWidth
        - ((root.fullWidth - root.mascotBox) / 2 + root.mascotBox
           + (root.rightWidth > 0 ? root.gap : 0))

    readonly property bool modulesVisible:
        root.contentActive
        && (root.expanded || root.width > root.mascotBox + 0.5)

    implicitWidth: root.expanded ? root.contentWidth : root.mascotBox
    implicitHeight: Theme.size.dropHeight

    BarZone {
        id: leftZone
        x: root.leftAttachedX - root.leftGlide * root.expandT
        y: 0
        width: implicitWidth
        height: root.height
        modules: root.leftModules
        host: root.host
        visible: root.modulesVisible && root.leftWidth > 0
    }

    BarZone {
        id: rightZone
        x: root.rightAttachedX + root.rightGlide * root.expandT
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

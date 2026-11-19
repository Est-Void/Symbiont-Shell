import QtQuick
import qs.ui
import qs.ui.components

Item {
    id: root

    property string mascotPosition: "center"
    property bool charging: false

    readonly property real pad: Theme.space.md
    readonly property real clockW: clock.implicitWidth
    readonly property real dotSize: Theme.size.chargeDot

    implicitWidth: root.pad + root.clockW
                   + (root.charging ? Theme.space.sm + root.dotSize : 0)
    implicitHeight: Theme.size.dropHeight

    Clock {
        id: clock
        x: root.pad
        y: 0
        width: clock.implicitWidth
        height: root.implicitHeight
        active: root.visible
    }

    Rectangle {
        x: root.pad + root.clockW + Theme.space.sm
        width: root.dotSize
        height: root.dotSize
        radius: width / 2
        color: Theme.color.accent
        border.width: Theme.size.hairline
        border.color: Theme.color.borderStrong
        visible: root.charging
        anchors.verticalCenter: parent.verticalCenter
        Accessible.role: Accessible.Graphic
        Accessible.name: "Charging"
    }
}

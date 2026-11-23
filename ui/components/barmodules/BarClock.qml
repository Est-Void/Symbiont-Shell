import QtQuick
import qs.ui
import qs.ui.components

Item {
    id: root

    property var host: null

    implicitWidth: clock.implicitWidth
    implicitHeight: Theme.size.dropHeight

    Clock {
        id: clock
        x: 0
        y: (root.height - clock.implicitHeight) / 2
        width: clock.implicitWidth
        height: clock.implicitHeight
        active: root.visible
    }

    Accessible.role: Accessible.StaticText
    Accessible.name: clock.clockText
}

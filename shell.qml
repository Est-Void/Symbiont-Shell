import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.ui
import qs.ui.components

PanelWindow {
    id: shell

    anchors {
        top: true
        left: true
        right: true
    }

    implicitHeight: Theme.size.menuHeight + Theme.space.xs

    WlrLayershell.namespace: "symbiont"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    color: "transparent"

    mask: Region {
        x: backdrop.x
        y: backdrop.y
        width: backdrop.width
        height: backdrop.height
    }

    TopBackdrop {
        id: backdrop
        screen: shell.screen
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
        }
    }

}

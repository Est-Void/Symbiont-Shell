import QtQuick
import qs.ui
import qs.ui.components

Item {
    id: root

    property bool showSeconds: false
    property bool active: true
    property date now: new Date()

    readonly property string clockText: Qt.formatDateTime(root.now, root.showSeconds ? "HH:mm:ss" : "HH:mm")
    readonly property real dotHeight: Math.min(Theme.type.numericDot.size, Theme.size.dropHeight - Theme.space.md)

    implicitWidth: dotText.implicitWidth
    implicitHeight: dotText.implicitHeight

    DotText {
        id: dotText
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        value: root.clockText
        size: root.dotHeight
        gapRatio: 0.1
        color: Theme.color.textPrimary
    }

    onActiveChanged: if (root.active) root.now = new Date()

    Timer {
        interval: 1000
        running: root.active
        repeat: true
        onTriggered: root.now = new Date()
    }
}
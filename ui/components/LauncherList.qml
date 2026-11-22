import QtQuick
import QtQuick.Controls
import qs.ui
import qs.ui.components

Item {
    id: root

    property var apps: []
    property string query: ""
    property int currentIndex: 0
    readonly property int count: root.apps.length

    signal activated(var app)

    // 7x7 dotted circle (§7.2) for the empty state.
    readonly property var ringPattern: [
        "0011100",
        "0110110",
        "1100011",
        "1000001",
        "1100011",
        "0110110",
        "0011100"
    ]

    function move(delta) {
        if (root.count === 0)
            return
        root.currentIndex = Math.max(0, Math.min(root.count - 1, root.currentIndex + delta))
        list.positionViewAtIndex(root.currentIndex, ListView.Contain)
    }

    function reset() {
        root.currentIndex = 0
        list.positionViewAtBeginning()
    }

    function activateCurrent() {
        if (root.currentIndex < 0 || root.currentIndex >= root.count)
            return
        root.activated(root.apps[root.currentIndex])
    }

    Behavior on height {
        NumberAnimation {
            duration: Theme.motion.reducedMotion ? Theme.motion.instant : Theme.motion.base
            easing.type: Easing.OutCubic
        }
    }

    ListView {
        id: list
        anchors.fill: parent
        anchors.rightMargin: Theme.size.scrollbarHoverWidth + Theme.space.xs
        clip: true
        model: root.apps
        spacing: Theme.size.launcherRowGap
        boundsBehavior: Flickable.StopAtBounds

        ScrollBar.vertical: ScrollBar {
            id: vbar
            policy: ScrollBar.AsNeeded
            width: vbar.hovered
                ? Theme.size.scrollbarHoverWidth : Theme.size.scrollbarWidth
            contentItem: Rectangle {
                implicitWidth: vbar.width
                radius: Theme.radius.pill
                color: Theme.color.borderStrong
            }
            background: null

            Behavior on width {
                NumberAnimation {
                    duration: Theme.motion.reducedMotion
                        ? Theme.motion.instant : Theme.motion.base
                    easing.type: Easing.OutCubic
                }
            }
        }

        delegate: LauncherAppRow {
            app: modelData
            number: index + 1
            width: list.width
            current: index === root.currentIndex
            showDivider: index < root.count - 1
            onActivated: root.activated(root.apps[index])
        }
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.space.md
        visible: root.count === 0

        DotCluster {
            anchors.horizontalCenter: parent.horizontalCenter
            pattern: root.ringPattern
            dotSize: Theme.space.xxs
            pitch: Theme.space.xs
            color: Theme.color.borderStrong
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Theme.space.sm

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "NO RESULTS"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.color.textSecondary
                font.family: Theme.font.mono[0]
                font.pixelSize: Theme.type.label.size
                font.weight: Theme.type.label.weight
                font.letterSpacing: Theme.type.label.tracking
                font.capitalization: Font.AllUppercase
                renderType: Text.NativeRendering
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "QUERY \u2014 \u201C" + root.query + "\u201D"
                visible: root.query.length > 0
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                color: Theme.color.textTertiary
                font.family: Theme.font.mono[0]
                font.pixelSize: Theme.type.labelSm.size
                font.weight: Theme.type.labelSm.weight
                font.letterSpacing: Theme.type.labelSm.tracking
                font.capitalization: Font.AllUppercase
                renderType: Text.NativeRendering
            }
        }
    }
}

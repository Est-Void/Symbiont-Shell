pragma ComponentBehavior: Bound

import QtQuick
import qs.ui
import qs.ui.components

Item {
    id: root

    property string currentSection: "SYSTEM"
    readonly property real headerHeight: Theme.size.settingsHeaderHeight

    Rectangle {
        x: 0
        y: root.headerHeight - Theme.size.hairline
        width: parent.width
        height: Theme.size.hairline
        color: Theme.color.borderSubtle
    }

    Item {
        id: rail
        x: 0
        y: root.headerHeight
        width: Theme.size.settingsRailWidth
        height: root.height - root.headerHeight
        readonly property real corner: Theme.size.settingsBottomRadius

        Rectangle {
            anchors.fill: parent
            radius: rail.corner
            color: Theme.color.surface2
        }

        Rectangle {
            x: 0
            y: 0
            width: rail.corner
            height: rail.corner
            color: Theme.color.surface2
        }

        Rectangle {
            x: rail.width - rail.corner
            y: 0
            width: rail.corner
            height: rail.corner
            color: Theme.color.surface2
        }

        Rectangle {
            x: rail.width - rail.corner
            y: rail.height - rail.corner
            width: rail.corner
            height: rail.corner
            color: Theme.color.surface2
        }

        Rectangle {
            anchors.right: parent.right
            width: Theme.size.hairline
            height: parent.height
            color: Theme.color.borderSubtle
        }

        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: Theme.space.lg
            spacing: Theme.space.sm

            Text {
                text: "SETTINGS"
                color: Theme.color.textTertiary
                font.family: Theme.font.mono[0]
                font.pixelSize: Theme.type.labelSm.size
                font.letterSpacing: Theme.type.labelSm.tracking
                font.capitalization: Font.AllUppercase
                renderType: Text.NativeRendering
            }

            SectionSelector {
                width: parent.width
                label: "SYSTEM"
                selected: root.currentSection === "SYSTEM"
                onClicked: root.currentSection = "SYSTEM"
            }
        }
    }

    Item {
        x: Theme.size.settingsRailWidth
        y: root.headerHeight
        width: parent.width - Theme.size.settingsRailWidth
        height: root.height - root.headerHeight

        SystemSection {
            active: root.opacity > 0.01
            anchors.fill: parent
            anchors.margins: Theme.space.xl
        }
    }
}

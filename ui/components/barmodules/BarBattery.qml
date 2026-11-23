import QtQuick
import qs.ui
import qs.ui.components

Item {
    id: root

    property var host: null

    readonly property int percent:
        root.host && root.host.barBatteryPercent >= 0
            ? root.host.barBatteryPercent : -1
    readonly property bool charging:
        root.host ? root.host.barBatteryCharging === true : false

    implicitWidth: row.implicitWidth
    implicitHeight: Theme.size.dropHeight

    Row {
        id: row
        y: (root.height - height) / 2
        spacing: Theme.space.xs

        DotText {
            anchors.verticalCenter: parent.verticalCenter
            value: root.percent >= 0 ? root.percent + "%" : "--"
            size: Theme.type.numericMono.size
            gapRatio: 0.1
            color: Theme.color.textPrimary
        }

        Rectangle {
            width: Theme.size.chargeDot
            height: width
            radius: width / 2
            color: Theme.color.accent
            border.width: Theme.size.hairline
            border.color: Theme.color.borderStrong
            visible: root.charging
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    Accessible.role: Accessible.StaticText
    Accessible.name: root.percent >= 0
        ? "Battery " + root.percent + "%" + (root.charging ? ", charging" : "")
        : "Battery unavailable"
}

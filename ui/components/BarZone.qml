pragma ComponentBehavior: Bound

import QtQuick
import qs.ui

Item {
    id: root

    property var modules: []
    property var host: null
    property real spacing: BarConfig.moduleGap
    property real moduleHeight: Theme.size.dropHeight

    implicitWidth: row.implicitWidth
    implicitHeight: root.moduleHeight

    Row {
        id: row
        y: (root.height - height) / 2
        spacing: root.spacing

        Repeater {
            model: root.modules

            delegate: Loader {
                required property string modelData

                property var host: root.host

                width: item ? item.implicitWidth : 0
                height: item ? item.implicitHeight : 0
                source: BarConfig.sourceFor(modelData)

                onLoaded: if (item)
                    item.host = host

                onHostChanged: if (item)
                    item.host = host
            }
        }
    }
}

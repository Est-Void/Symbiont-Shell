pragma ComponentBehavior: Bound

import QtQuick
import qs.ui

Item {
    id: root

    property string label: ""
    property string value: ""

    implicitHeight: Theme.space.xl

    Text {
        id: labelText
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.space.xxxl + Theme.space.xl
        text: root.label
        color: Theme.color.textSecondary
        font.family: Theme.font.mono[0]
        font.pixelSize: Theme.type.label.size
        font.weight: Theme.type.label.weight
        font.letterSpacing: Theme.type.label.tracking
        font.capitalization: Font.AllUppercase
        renderType: Text.NativeRendering
    }

    Text {
        anchors.left: labelText.right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        text: root.value
        color: Theme.color.textPrimary
        font.family: Theme.font.ui[0]
        font.pixelSize: Theme.type.bodySm.size
        font.weight: Theme.type.bodySm.weight
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: Theme.size.hairline
        color: Theme.color.borderSubtle
    }
}

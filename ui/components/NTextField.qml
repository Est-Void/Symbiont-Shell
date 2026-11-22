import QtQuick
import qs.ui
import qs.ui.components

Item {
    id: root

    property alias text: input.text
    property string placeholder: ""
    property int horizontalPadding: Theme.space.md
    property bool leadingDots: false
    readonly property bool hasText: input.text.length > 0
    readonly property bool focused: input.activeFocus
    readonly property real textLeftInset: root.horizontalPadding
        + (root.leadingDots ? dotGlyph.width + Theme.space.sm : 0)

    signal accepted()
    signal navigationRequested(int delta)

    implicitWidth: Theme.size.launcherWidth
    implicitHeight: Theme.size.inputHeight
    height: implicitHeight
    activeFocusOnTab: true

    function focusInput() {
        input.forceActiveFocus()
    }

    function clear() {
        input.text = ""
        input.forceActiveFocus()
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: -Theme.size.focusRingOffset
        radius: height / 2
        color: Theme.color.transparent
        border.width: Theme.size.focusRingWidth
        border.color: Theme.color.accent
        visible: root.focused
    }

    Rectangle {
        id: background
        anchors.fill: parent
        radius: height / 2
        color: Theme.color.surface2
        border.width: Theme.size.hairline
        border.color: Theme.color.borderDefault
    }

    DotCluster {
        id: dotGlyph
        x: Theme.space.md
        anchors.verticalCenter: parent.verticalCenter
        pattern: ["11", "11", "11"]
        dotSize: Theme.space.xxs
        pitch: Theme.space.xs
        color: Theme.color.textTertiary
        visible: root.leadingDots
    }

    TextInput {
        id: input

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.textLeftInset
        anchors.rightMargin: root.horizontalPadding
                      + (root.hasText ? Theme.size.inputClear + Theme.space.sm : 0)
        anchors.verticalCenter: parent.verticalCenter
        height: Theme.type.body.size
        verticalAlignment: TextInput.AlignVCenter
        clip: true
        selectByMouse: true
        selectionColor: Theme.color.accentMuted
        selectedTextColor: Theme.color.textPrimary
        color: Theme.color.textPrimary
        font.family: Theme.font.ui[0]
        font.pixelSize: Theme.type.body.size
        font.weight: Theme.type.body.weight
        cursorDelegate: Rectangle {
            width: 2
            color: Theme.color.textPrimary
        }

        Accessible.role: Accessible.EditableText
        Accessible.name: root.placeholder

        onAccepted: root.accepted()

        Keys.onUpPressed: function (event) {
            root.navigationRequested(-1)
            event.accepted = true
        }

        Keys.onDownPressed: function (event) {
            root.navigationRequested(1)
            event.accepted = true
        }
    }

    Text {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: root.textLeftInset
        anchors.rightMargin: root.horizontalPadding
        anchors.verticalCenter: parent.verticalCenter
        text: root.placeholder
        visible: input.text.length === 0
        elide: Text.ElideRight
        color: Theme.color.textTertiary
        font.family: Theme.font.mono[0]
        font.pixelSize: Theme.type.label.size
        font.weight: Theme.type.label.weight
        font.letterSpacing: Theme.type.label.tracking
        font.capitalization: Font.AllUppercase
        renderType: Text.NativeRendering
    }

    Item {
        id: clearButton

        width: Theme.size.inputClear
        height: Theme.size.inputClear
        anchors.right: parent.right
        anchors.rightMargin: Theme.space.sm
        anchors.verticalCenter: parent.verticalCenter
        visible: root.hasText

        Accessible.role: Accessible.Button
        Accessible.name: "Clear search"

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: clearMouse.containsMouse ? Theme.color.surface3
                 : Theme.color.transparent
        }

        Item {
            width: Theme.space.md
            height: Theme.space.md
            anchors.centerIn: parent

            Rectangle {
                width: 12
                height: Theme.size.hairline
                radius: Theme.radius.pill
                color: Theme.color.textSecondary
                anchors.centerIn: parent
                rotation: 45
            }

            Rectangle {
                width: 12
                height: Theme.size.hairline
                radius: Theme.radius.pill
                color: Theme.color.textSecondary
                anchors.centerIn: parent
                rotation: -45
            }
        }

        MouseArea {
            id: clearMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.clear()
        }
    }
}

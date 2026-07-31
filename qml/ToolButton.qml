import QtQuick 2.0
import QtQuick.Controls 1.2

Button {
    id: control
    property string tooltip: ""

    Rectangle {
        id: tipBox
        visible: control.hovered && control.tooltip.length > 0 && control.enabled
        z: 100
        x: 0
        y: control.height + 2
        width: tipText.width + 8
        height: tipText.height + 4
        color: "#ffffe1"
        border.color: "#888888"
        opacity: 0.95
        Text {
            id: tipText
            anchors.centerIn: parent
            text: control.tooltip
            font.pointSize: 9
        }
    }
}

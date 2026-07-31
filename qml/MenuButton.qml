import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.1

Button {
    id: menuButton

    style: ButtonStyle {
        background: Rectangle {
            color: menuButton.pressed ? "#c0c0c0" : "transparent"
            border.color: "transparent"
        }
    }

    onClicked: menu.popup()
}

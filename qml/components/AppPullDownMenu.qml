import QtQuick 2.0
import Sailfish.Silica 1.0

/** Меню приложения, для старых версий */
PullDownMenu {
    signal refreshButtonClicked()
    signal openPdnButtonClicked()

    MenuItem {
        text: qsTr("New Game")
        onClicked: refreshButtonClicked()
    }

    //MenuItem {
    //    text: qsTr("menu.history")
    //    onClicked: openPdnButtonClicked()
    //}
}

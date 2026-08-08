import QtQuick 2.0
import Sailfish.Silica 1.0

/** Меню приложения, для старых версий */
PullDownMenu {
    signal refreshButtonClicked()
    signal openPdnButtonClicked()

    MenuItem {
        text: qsTrId("menu.refresh")
        onClicked: refreshButtonClicked()
    }

    //MenuItem {
    //    text: qsTrId("menu.history")
    //    onClicked: openPdnButtonClicked()
    //}
}

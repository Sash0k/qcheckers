import QtQuick 2.0
import Sailfish.Silica 1.0
import Aurora.Controls 1.0

/** Верхняя панель, Аврора 5.0+ */
AppBar {
    id: appBar

    property alias title: appBar.headerText
    property alias subTitle: appBar.subHeaderText

    signal refreshButtonClicked()
    //signal openPdnButtonClicked()

    onSubTitleChanged: {
        var current = appBar.subHeaderText
    }

    AppBarSpacer {}

    AppBarButton {
        icon.source: "image://theme/icon-splus-more"
        onClicked: menu.open()
    }

    PopupMenu {
        id: menu
        PopupMenuItem { text: qsTr("New Game"); onClicked: refreshButtonClicked() }
        //PopupMenuItem { text: qsTr("menu.history"); onClicked: openPdnButtonClicked() }
    }
}

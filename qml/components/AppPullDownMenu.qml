import QtQuick 2.0
import Sailfish.Silica 1.0

/** Меню приложения, для старых версий */
PullDownMenu {
    signal refreshButtonClicked()
    signal openHistoryButtonClicked()

    MenuItem {
        text: qsTr("New Game")
        onClicked: refreshButtonClicked()
    }

    MenuItem {
        text: qsTr("Show History")
        onClicked: openHistoryButtonClicked()
    }
}

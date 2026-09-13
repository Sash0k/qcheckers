import QtQuick 2.0
import Sailfish.Silica 1.0

/** Меню экрана истории, для старых версий */
PullDownMenu {
    signal sharehButtonClicked()

    MenuItem {
        text: qsTr("Share")
        onClicked:sharehButtonClicked()
    }
}

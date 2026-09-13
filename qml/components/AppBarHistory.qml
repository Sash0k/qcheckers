import QtQuick 2.0
import Aurora.Controls 1.0

/** Верхняя панель истории, Аврора 5.0+ */
AppBar {
    id: appBar

    property alias title: appBar.headerText
    signal sharehButtonClicked()

    AppBarSpacer {}

    AppBarButton {
        icon.source: "image://theme/icon-splus-share"
        onClicked: sharehButtonClicked()
    }
}


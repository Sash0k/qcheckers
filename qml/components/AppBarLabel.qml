import QtQuick 2.0
import Sailfish.Silica 1.0

/** Верхняя панель, для старых версий */
Column {
    property alias title: title.text
    property alias subTitle: subTitle.text

    // сигналы фиктивные. Оставлены для совместимости с AppBarMenu пятой Авроры
    signal refreshButtonClicked()
    //signal openPdnButtonClicked()

    /** Путь к файлу */
    onSubTitleChanged: {
        var current = subTitle.text
    }

    Label {
        id: title
        font.pixelSize: Theme.fontSizeMedium
        font.bold: true
        leftPadding: Theme.paddingLarge
        rightPadding: Theme.paddingLarge
    }

    Label {
        id: subTitle
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeExtraSmall
        leftPadding: Theme.paddingLarge
        rightPadding: Theme.paddingLarge
    }
}

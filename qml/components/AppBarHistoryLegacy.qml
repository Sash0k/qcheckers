import QtQuick 2.0
import Sailfish.Silica 1.0

/** Верхняя панель истории, для старых версий */
Label {
    property alias title: title.text
    // сигналы фиктивные. Оставлены для совместимости с AppBarMenu пятой Авроры
    signal sharehButtonClicked()

    id: title
    font.pixelSize: Theme.fontSizeMedium
    font.bold: true
    padding: Theme.paddingLarge
}

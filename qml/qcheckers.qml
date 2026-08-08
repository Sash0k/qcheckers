import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import qcheckers 0.9

ApplicationWindow {
    id: applicationWindow
    objectName: "applicationWindow"

    /* Настройки приложения */
    Settings { id: appSettings }

    readonly property bool showNotation: appSettings.notation
    readonly property int theme: appSettings.theme

    initialPage: Qt.resolvedUrl("pages/MainPage.qml")
    cover: Qt.resolvedUrl("cover/DefaultCoverPage.qml")
    allowedOrientations: defaultAllowedOrientations
}

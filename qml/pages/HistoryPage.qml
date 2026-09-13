import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Share 1.0
import Aurora.Controls 1.0
import "../components"

Page {
    objectName: "historyPage"
    allowedOrientations: Orientation.All

    readonly property bool isLegacyVersion: AURORA_OS_VERSION < 5
    /** История ходов для отображения */
    property var historyModel

    /** Ходы группируются попарно и нумеруются */
    function prepareHistory(historyModel) {
        var result = ""
        for (var i = 1; i < historyModel.length; i+=2) {
            const pair = historyModel[i + 1] !== undefined ? historyModel[i].move + " " + historyModel[i + 1].move : historyModel[i].move;
            const count = result.split(/\n/).length;
            result = result + count + ". " + pair + "\n";
        }
        return result
    }

    ShareAction { id: shareAction; mimeType: "text/plain" }

    function share() {
        if (history.text) {
            var content = {
                "name": "QCheckers PDN",
                "data": history.text
            }
            shareAction.resources = [content]
            shareAction.trigger()
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        pullDownMenu: appPullDownMenu

        /** Меню "Поделиться" для старых версий */
        AppPullDownMenuHistory {
            id: appPullDownMenu
            visible: isLegacyVersion
            onSharehButtonClicked: share()
        }

        /** Верхняя панель */
        Loader {
            id: appBar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            source: "../components/" + (isLegacyVersion ? "AppBarHistoryLegacy.qml" : "AppBarHistory.qml")
            onLoaded: {
                item.title = qsTr("History")
                item.sharehButtonClicked.connect(share)
            }
            Component.onDestruction: {
                if (item) {
                    item.sharehButtonClicked.disconnect(share)
                }
            }
        }

        SilicaFlickable {
            id: historyContainer
            anchors.top: appBar.bottom
            width: parent.width
            height: parent.height - appBar.height
            contentHeight: history.height
            pullDownMenu: appPullDownMenu
            clip: true

            /** Прокручиваемый лог */
            TextArea {
                id: history
                width: historyContainer.width
                autoScrollEnabled: true
                labelVisible: false
                readOnly: true
                wrapMode: TextEdit.Wrap
                font.pixelSize: Theme.fontSizeLarge
                font.family: "monospace"
                text: prepareHistory(historyModel)
            }

            VerticalScrollDecorator {}
        }
    }
}

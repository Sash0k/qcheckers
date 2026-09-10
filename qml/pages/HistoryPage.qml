import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Share 1.0
import Aurora.Controls 1.0

Page {
    objectName: "historyPage"
    allowedOrientations: Orientation.All

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

    /** Верхняя панель */
    AppBar {
        id: appBar
        headerText: qsTr("History")

        AppBarSpacer {}

        AppBarButton {
            icon.source: "image://theme/icon-splus-share"
            ShareAction { id: shareAction; mimeType: "text/plain" }
            onClicked: {
                var content = {
                    "name": "QCheckers PDN",
                    "data": history.text
                }
                shareAction.resources = [content]
                shareAction.trigger()
            }
        }
    }

    /** Прокручиваемый лог */
    SilicaFlickable {
        id: historyContainer
        anchors.top: appBar.bottom
        width: parent.width
        height: parent.height - appBar.height
        contentHeight: history.height
        clip: true

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

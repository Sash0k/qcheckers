import QtQuick 2.0
import Sailfish.Silica 1.0
import ".."

Page {
    objectName: "gamePage"
    allowedOrientations: Orientation.All

    /* Общие свойства приложения */
    readonly property bool isLegacyVersion: AURORA_OS_VERSION < 5

    property int mode: 25     // 21 = English draughts, 25 = Russian draughts
    property int opponent: 0  // COMPUTER = 0, HUMAN = 1
    property int level: 2     // BEGINNER = 2, NOVICE = 4, AVERAGE = 6, GOOD = 7, EXPERT = 8, MASTER = 9

    Component.onCompleted: { newGame() }

    /** Верхняя панель */
    Loader {
        id: appBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        source: "../components/" + (isLegacyVersion ? "AppBarLabel.qml" : "AppBarMenu.qml")
        onLoaded: {
            item.refreshButtonClicked.connect(newGame)
            item.openHistoryButtonClicked.connect(showHistory)
        }
        Component.onDestruction: {
            if (item) {
                item.refreshButtonClicked.disconnect(newGame)
                item.openHistoryButtonClicked.disconnect(showHistory)
            }
        }
    }

    Board {
        anchors.top: appBar.bottom
        width: parent.width
        height: parent.height - appBar.height
        showNotation: appSettings.notation
        notationAbove: false
    }

    Connections {
        target: game
        onLogMessage: {
            // вывод сообщений о неправильном ходе, обязательной рубке и т.д.
            appBar.item.subTitle = text
        }
    }

    Connections {
        target: game.history
        onCurrentPlayerChanged: {
            appBar.item.subTitle = ""
            appBar.item.title = qsTr("Move:") + " " + game.history.currentPlayer
        }
    }

    /** Старт новой игры */
    function newGame() {
        var isWhite = appSettings.isWhite;
        var player1 = isWhite ? qsTr("White") : qsTr("Black");
        var player2 = isWhite ? qsTr("Black") : qsTr("White");
        game.newGame(mode, false, player1, isWhite, opponent, player2, level);
    }

    /** Показать историю игры */
    function showHistory() {
        var history = game.history.moves
        pageStack.push(Qt.resolvedUrl("HistoryPage.qml"), { "historyModel": history })
    }
}

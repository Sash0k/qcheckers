import QtQuick 2.6
import Sailfish.Silica 1.0

ApplicationWindow {
    id: window
    initialPage: Component {
        Board {
            anchors.fill: parent
            anchors.centerIn: parent
            showNotation: window.showNotation
            notationAbove: window.notationAbove
        }
    }
    cover: Qt.resolvedUrl
    allowedOrientations: defaultAllowedOrientations

    // ---- user interface state (mirrors the old settings) ----
    property bool showToolbar: false
    property bool showHistory: false
    property bool showLog: false
    property bool showNotation: false
    property bool notationAbove: true
    property bool confirmAbort: false
    property bool clearLog: true
    property string currentTheme: "Default"
    property var themeList: []
    property string lastFilename: ""
    property bool quitAllowed: true

    function urlToPath(url) {
        var s = url.toString();
        s = s.replace(/^file:\/\//, "");
        return decodeURIComponent(s);
    }

    function appendLog(type, text) {
        logPanel.appendLog(type, text);
    }

    function confirmAndDo(what) {
        if (window.confirmAbort && !game.aborted) {
            keepConfirm.callback = what;
            keepConfirm.visible = true;
        } else {
            what();
        }
    }

    function doNewGame() {
        confirmAndDo(function() { newGameDialog.openDlg(); });
    }

    function doOpen() {
        confirmAndDo(function() { openDialog.visible = true; });
    }

    function doNextRound() {
        confirmAndDo(function() { game.nextRound(); });
    }

    function doSave() {
        saveDialog.visible = true;
    }

    function doQuit() {
        confirmAndDo(function() {
            quitAllowed = true;
            window.close();
        });
    }

    function applyTheme(path) {
        window.currentTheme = path;
        game.setTheme(path);
    }

    Connections {
        target: game
        function onLogMessage(type, text) { window.appendLog(type, text); }
        function onClearLogRequested() { logPanel.clearLog(); }
    }

//    onClosing: {
//        if (quitAllowed) {
//            game.storeWindowGeometry(window.x, window.y, window.width, window.height);
//            game.setLastFilename(window.lastFilename);
//            game.storeSettings();
//            return;
//        }
//        close.accepted = false;
//        confirmAndDo(function() {
//            quitAllowed = true;
//            window.close();
//        });
//    }

    Component.onCompleted: {
        var g = game.windowGeometry();
        if (g.length === 4) {
            window.x = g[0];
            window.y = g[1];
            window.width = g[2];
            window.height = g[3];
        }
        window.lastFilename = game.lastFilename();
        window.themeList = game.themes();
        window.currentTheme = game.themePath;
        window.confirmAbort = game.keepDialog;
        window.clearLog = game.clearLog;
    }

    // -----------------------------------------------------------------
    //  Dialogs
    // -----------------------------------------------------------------
//    FileDialog {
//        id: openDialog
//        title: qsTr("Open Game")
//        nameFilters: [ "PDN Files (*.pdn)", "All Files (*)" ]
//        selectExisting: true
//        onAccepted: {
//            var path = urlToPath(fileUrl);
//            if (game.openGame(path)) {
//                window.lastFilename = path;
//            } else {
//                warnDialog.text = qsTr("Could not open: ") + path;
//                warnDialog.visible = true;
//            }
//        }
//    }

//    FileDialog {
//        id: saveDialog
//        title: qsTr("Save Game")
//        nameFilters: [ "PDN Files (*.pdn)", "All Files (*)" ]
//        selectExisting: false
//        onAccepted: {
//            var path = urlToPath(fileUrl);
//            if (path.indexOf(".pdn") !== path.length - 4) {
//                path += ".pdn";
//            }
//            if (game.saveGame(path)) {
//                window.lastFilename = path;
//            } else {
//                warnDialog.text = qsTr("Could not save: ") + path;
//                warnDialog.visible = true;
//            }
//        }
//    }


//    NewGameDialog {
//        id: newGameDialog
//        onStartRequested: {
//            game.newGame(newGameDialog.rules, newGameDialog.freePlacement,
//                newGameDialog.name, newGameDialog.isWhite,
//                newGameDialog.opponent, newGameDialog.opponentName,
//                newGameDialog.skill);
//            game.saveNewGameSettings(newGameDialog.rules, newGameDialog.isWhite,
//                newGameDialog.name, newGameDialog.opponent,
//                newGameDialog.opponentName, newGameDialog.skill);
//        }
//    }

//    InfoDialog {
//        id: infoDialog
//    }
}

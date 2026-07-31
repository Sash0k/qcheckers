import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1
import QtQuick.Dialogs 1.1
import QtQml.Models 2.14

ApplicationWindow {
    id: window
    visible: true
    width: 960
    height: 680
    title: qsTr("QCheckers")

    // ---- user interface state (mirrors the old settings) ----
    property bool showToolbar: true
    property bool showHistory: true
    property bool showLog: true
    property bool showNotation: true
    property bool notationAbove: true
    property bool confirmAbort: true
    property bool clearLog: true
    property string currentTheme: "Default"
    property var themeList: []
    property string lastFilename: ""
    property bool quitAllowed: false

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

    onClosing: {
        if (quitAllowed) {
            game.storeWindowGeometry(window.x, window.y, window.width, window.height);
            game.setLastFilename(window.lastFilename);
            game.storeSettings();
            return;
        }
        close.accepted = false;
        confirmAndDo(function() {
            quitAllowed = true;
            window.close();
        });
    }

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
    MessageDialog {
        id: keepConfirm
        title: qsTr("Abort Game?") + " - QCheckers"
        text: qsTr("Current game will be lost if you continue.")
        informativeText: qsTr("Do you really want to discard it?")
        icon: StandardIcon.Question
        standardButtons: StandardButton.Yes | StandardButton.No
        property var callback: null
        onYes: {
            var cb = callback;
            callback = null;
            if (cb) cb();
        }
        onNo: { callback = null; }
    }

    MessageDialog {
        id: warnDialog
        title: qsTr("Error") + " - QCheckers"
        icon: StandardIcon.Warning
        standardButtons: StandardButton.Ok
        property var cb: null
        onAccepted: { if (cb) { var f = cb; cb = null; f(); } }
    }

    FileDialog {
        id: openDialog
        title: qsTr("Open Game")
        nameFilters: [ "PDN Files (*.pdn)", "All Files (*)" ]
        selectExisting: true
        onAccepted: {
            var path = urlToPath(fileUrl);
            if (game.openGame(path)) {
                window.lastFilename = path;
            } else {
                warnDialog.text = qsTr("Could not open: ") + path;
                warnDialog.visible = true;
            }
        }
    }

    FileDialog {
        id: saveDialog
        title: qsTr("Save Game")
        nameFilters: [ "PDN Files (*.pdn)", "All Files (*)" ]
        selectExisting: false
        onAccepted: {
            var path = urlToPath(fileUrl);
            if (path.indexOf(".pdn") !== path.length - 4) {
                path += ".pdn";
            }
            if (game.saveGame(path)) {
                window.lastFilename = path;
            } else {
                warnDialog.text = qsTr("Could not save: ") + path;
                warnDialog.visible = true;
            }
        }
    }

    FontDialog {
        id: fontDialog
        title: qsTr("Notation Font")
        onAccepted: {
            game.setNotationFont(font);
            window.showNotation = true;
        }
    }

    NewGameDialog {
        id: newGameDialog
        onStartRequested: {
            game.newGame(newGameDialog.rules, newGameDialog.freePlacement,
                newGameDialog.name, newGameDialog.isWhite,
                newGameDialog.opponent, newGameDialog.opponentName,
                newGameDialog.skill);
            game.saveNewGameSettings(newGameDialog.rules, newGameDialog.isWhite,
                newGameDialog.name, newGameDialog.opponent,
                newGameDialog.opponentName, newGameDialog.skill);
        }
    }

    InfoDialog {
        id: infoDialog
    }

    // -----------------------------------------------------------------
    //  Menu bar
    // -----------------------------------------------------------------
    Rectangle {
        id: menuBar
        height: 30
        color: "#e8e8e8"
        border.color: "#c0c0c0"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        z: 10

        Row {
            anchors.fill: parent
            anchors.leftMargin: 4
            spacing: 2

            MenuButton {
                text: qsTr("&Game")
                menu: Menu {
                    MenuItem { text: qsTr("&New..."); shortcut: "Ctrl+N"; onTriggered: window.doNewGame() }
                    MenuItem { text: qsTr("&Open..."); shortcut: "Ctrl+O"; onTriggered: window.doOpen() }
                    MenuItem { text: qsTr("&Save..."); shortcut: "Ctrl+S"; onTriggered: window.doSave() }
                    MenuSeparator { }
                    MenuItem { text: qsTr("&Next Round"); onTriggered: window.doNextRound() }
                    MenuItem { text: qsTr("&Stop"); enabled: game.working; onTriggered: game.stopGame() }
                    MenuSeparator { }
                    MenuItem { text: qsTr("&Quit"); shortcut: "Ctrl+Q"; onTriggered: window.doQuit() }
                }
            }

            MenuButton {
                text: qsTr("&View")
                menu: Menu {
                    MenuItem {
                        text: qsTr("&Toolbar")
                        checkable: true
                        checked: window.showToolbar
                        onTriggered: window.showToolbar = !window.showToolbar
                    }
                    MenuSeparator { }
                    MenuItem {
                        text: qsTr("&Show Notation")
                        checkable: true
                        checked: window.showNotation
                        onTriggered: {
                            window.showNotation = !window.showNotation;
                            game.setNotation(window.showNotation, window.notationAbove);
                        }
                    }
                    MenuItem {
                        text: qsTr("Show notation &above men")
                        checkable: true
                        checked: window.notationAbove
                        onTriggered: {
                            window.notationAbove = !window.notationAbove;
                            game.setNotation(window.showNotation, window.notationAbove);
                        }
                    }
                    MenuSeparator { }
                    MenuItem {
                        text: qsTr("History")
                        checkable: true
                        checked: window.showHistory
                        onTriggered: window.showHistory = !window.showHistory
                    }
                    MenuItem {
                        text: qsTr("Log")
                        checkable: true
                        checked: window.showLog
                        onTriggered: window.showLog = !window.showLog
                    }
                    MenuSeparator { }
                    Menu {
                        id: themesMenu
                        title: qsTr("&Themes")
                        Instantiator {
                            model: window.themeList
                            MenuItem {
                                text: modelData.name
                                checkable: true
                                checked: window.currentTheme === modelData.path
                                onTriggered: window.applyTheme(modelData.path)
                            }
                            onObjectAdded: themesMenu.insertItem(index, object)
                            onObjectRemoved: themesMenu.removeItem(object)
                        }
                    }
                }
            }

            MenuButton {
                text: qsTr("&Settings")
                menu: Menu {
                    MenuItem {
                        text: qsTr("&Confirm aborting current game")
                        checkable: true
                        checked: window.confirmAbort
                        onTriggered: {
                            window.confirmAbort = !window.confirmAbort;
                            game.setKeepDialog(window.confirmAbort);
                        }
                    }
                    MenuItem {
                        text: qsTr("Clear &log on new round")
                        checkable: true
                        checked: window.clearLog
                        onTriggered: {
                            window.clearLog = !window.clearLog;
                            game.setClearLog(window.clearLog);
                        }
                    }
                    MenuSeparator { }
                    MenuItem {
                        text: qsTr("&Notation font...")
                        onTriggered: fontDialog.visible = true
                    }
                }
            }

            MenuButton {
                text: qsTr("&Help")
                menu: Menu {
                    MenuItem {
                        text: qsTr("&Rules of Play")
                        onTriggered: {
                            infoDialog.titleText = qsTr("Rules of Play");
                            infoDialog.bodyText =
                                qsTr("<p>In the beginning of game you have 12 checkers (men). " +
                                    "The men move forward only. The men can capture:" +
                                    "<ul>" +
                                    "<li>by jumping forward only (english rules);" +
                                    "<li>by jumping forward or backward (russian rules)." +
                                    "</ul>" +
                                    "<p>A man which reaches the far side of the board becomes a king. " +
                                    "The kings move forward or backward:" +
                                    "<ul>" +
                                    "<li>to one square only (english rules);" +
                                    "<li>to any number of squares (russian rules)." +
                                    "</ul>" +
                                    "<p>The kings capture by jumping forward or backward. " +
                                    "Whenever a player is able to make a capture he must do so.");
                            infoDialog.visible = true;
                        }
                    }
                    MenuItem {
                        text: qsTr("&About") + " QCheckers"
                        onTriggered: {
                            infoDialog.titleText = qsTr("About");
                            infoDialog.bodyText =
                                qsTr("QCheckers, a board game.<br>Version ") + "0.9.0<br><br>"
                                + qsTr("(c) 2002-2003, Andi Peredri (andi@ukr.net)<br>" +
                                    "(c) 2004-2007, Artur Wiebe (wibix@gmx.de)<br><br>" +
                                    "This program is distributed under the terms " +
                                    "of the GNU General Public License Version 2.");
                            infoDialog.visible = true;
                        }
                    }
                    MenuItem {
                        text: qsTr("About &Qt")
                        onTriggered: {
                            infoDialog.titleText = qsTr("About Qt");
                            infoDialog.bodyText = qsTr("Qt %1").arg(qtVersionString);
                            infoDialog.visible = true;
                        }
                    }
                }
            }
        }
    }

    // -----------------------------------------------------------------
    //  Toolbar
    // -----------------------------------------------------------------
    Rectangle {
        id: toolBar
        height: 38
        visible: window.showToolbar
        anchors.top: menuBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: "#f4f4f4"
        border.color: "#d0d0d0"
        z: 10

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 4
            anchors.rightMargin: 4
            spacing: 2
            ToolButton {
                iconSource: "qrc:/icons/logo.svg"
                text: qsTr("New")
                tooltip: qsTr("New Game")
                enabled: !game.working
                onClicked: window.doNewGame()
            }
            ToolButton {
                iconSource: "qrc:/icons/fileopen.svg"
                text: qsTr("Open")
                tooltip: qsTr("Open Game")
                enabled: !game.working
                onClicked: window.doOpen()
            }
            ToolButton {
                iconSource: "qrc:/icons/filesave.svg"
                text: qsTr("Save")
                tooltip: qsTr("Save Game")
                enabled: !game.working
                onClicked: window.doSave()
            }
            Rectangle {
                width: 1
                Layout.fillHeight: true
                Layout.topMargin: 7
                Layout.bottomMargin: 7
                color: "#d0d0d0"
            }
            ToolButton {
                iconSource: "qrc:/icons/next.svg"
                text: qsTr("Next Round")
                tooltip: qsTr("Next Round")
                enabled: !game.working
                onClicked: window.doNextRound()
            }
            ToolButton {
                iconSource: "qrc:/icons/stop.svg"
                text: qsTr("Stop")
                tooltip: qsTr("Stop")
                enabled: game.working
                onClicked: game.stopGame()
            }
            Item { Layout.fillWidth: true; Layout.fillHeight: true }

            // working indicator
            Item {
                id: workingSpinner
                width: 20
                height: 20
                visible: game.working
                Image {
                    anchors.fill: parent
                    source: "qrc:/icons/logo.svg"
                    NumberAnimation on rotation {
                        running: workingSpinner.visible
                        from: 0; to: 360
                        duration: 900
                        loops: Animation.Infinite
                    }
                }
            }
            Label {
                text: game.history.currentPlayer
                font.bold: true
            }
        }
    }

    // -----------------------------------------------------------------
    //  Central: board + docks
    // -----------------------------------------------------------------
    SplitView {
        id: mainSplit
        orientation: Qt.Horizontal
        anchors.top: toolBar.visible ? toolBar.bottom : menuBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: logSplit.top

        Board {
            id: board
            Layout.fillWidth: true
            Layout.fillHeight: true
            showNotation: window.showNotation
            notationAbove: window.notationAbove
        }

        HistoryPanel {
            id: historyPanel
            visible: window.showHistory
            Layout.preferredWidth: 260
        }
    }

    SplitView {
        id: logSplit
        orientation: Qt.Vertical
        height: 140
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        LogPanel {
            id: logPanel
            visible: window.showLog
            Layout.fillHeight: true
        }
    }

    statusBar: StatusBar {
        RowLayout {
            anchors.fill: parent
            Label { text: game.gameTypeName }
            Item { Layout.fillWidth: true }
            Label {
                text: game.working ? qsTr("Thinking...") : ""
                font.italic: true
            }
        }
    }
}

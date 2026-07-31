import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

Item {
    id: historyPanel

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        ComboBox {
            id: gameCombo
            Layout.fillWidth: true
            model: game.history.games
            currentIndex: game.history.currentGame
            onActivated: game.history.selectGame(index)
        }

        ListView {
            id: tagList
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(90, contentHeight)
            clip: true
            model: game.history.tags
            delegate: Text {
                width: tagList.width
                elide: Text.ElideRight
                text: modelData.name + ": " + modelData.value
                font.pointSize: 9
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: "#c0c0c0"
        }

        ListView {
            id: moveList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: game.history.moves
            currentIndex: game.history.currentMoveIndex
            onCurrentIndexChanged: {
                if (currentIndex !== game.history.currentMoveIndex)
                    game.history.selectMove(currentIndex);
            }
            delegate: Rectangle {
                width: moveList.width
                height: 22
                color: moveList.currentIndex === index ? "#cfe3ff" : "transparent"
                MouseArea {
                    anchors.fill: parent
                    onClicked: moveList.currentIndex = index
                }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 4
                    spacing: 4
                    Label {
                        text: modelData.number
                        width: 34
                        color: "#888888"
                    }
                    Label {
                        text: modelData.move
                        font.bold: true
                    }
                    Label {
                        text: modelData.comment
                        color: "#888888"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            ToolButton {
                text: qsTr("|<")
                tooltip: qsTr("First move")
                onClicked: game.history.selectMove(0)
            }
            ToolButton {
                text: qsTr("<")
                tooltip: qsTr("Undo")
                onClicked: game.history.undo()
            }
            ToolButton {
                text: qsTr(">")
                tooltip: qsTr("Redo")
                onClicked: game.history.redo()
            }
            ToolButton {
                text: qsTr(">|")
                tooltip: qsTr("Last move")
                onClicked: game.history.selectMove(game.history.moves.length - 1)
            }
            Item { Layout.fillWidth: true }
            ToolButton {
                text: qsTr("Play")
                tooltip: qsTr("Continue game")
                onClicked: game.history.continueGame()
            }
        }
    }

    Connections {
        target: game.history
        function onCurrentMoveChanged() {
            moveList.currentIndex = game.history.currentMoveIndex;
            moveList.positionViewAtIndex(game.history.currentMoveIndex, ListView.Center);
        }
    }
}

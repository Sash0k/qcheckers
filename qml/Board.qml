import QtQuick 2.0

Item {
    id: boardRoot

    property bool showNotation: true
    property bool notationAbove: true

    property int cellSize: Math.floor(Math.min(width, height) / 8)

    property int lastFrom: -1
    property int lastTo: -1

    Connections {
        target: game
        function onMoveAnimate(from, to) {
            boardRoot.lastFrom = from;
            boardRoot.lastTo = to;
            flashTimer.restart();
        }
    }

    Timer {
        id: flashTimer
        interval: 1200
        onTriggered: {
            boardRoot.lastFrom = -1;
            boardRoot.lastTo = -1;
        }
    }

    // maps a board cell (0..63, row-major) to a game field (0..31),
    // or -1 if the cell is a light (non-playable) square.
    function fieldIndex(idx) {
        var r = Math.floor(idx / 8);
        var c = idx % 8;
        if ((r + c) % 2 === 0)
            return -1;
        if (r % 2 === 0)
            return Math.floor(r / 2) * 8 + Math.floor((c - 1) / 2);
        return 4 + Math.floor((r - 1) / 2) * 8 + Math.floor(c / 2);
    }

    function pieceSource(field) {
        if (field < 0)
            return "";
        var item = game.board[field];
        var white = game.bottomIsWhite;
        if (item === 1) return white ? game.theme.manWhite : game.theme.manBlack;
        if (item === 5) return white ? game.theme.manBlack : game.theme.manWhite;
        if (item === 2) return white ? game.theme.kingWhite : game.theme.kingBlack;
        if (item === 4) return white ? game.theme.kingBlack : game.theme.kingWhite;
        return "";
    }

    Item {
        width: boardRoot.cellSize * 8
        height: boardRoot.cellSize * 8
        anchors.centerIn: parent

        Repeater {
        model: 64

            Item {
                id: tile
                width: boardRoot.cellSize
                height: boardRoot.cellSize
                x: (index % 8) * width
                y: Math.floor(index / 8) * height

                property int field: boardRoot.fieldIndex(index)
                property bool dark: field >= 0

                Image {
                    anchors.fill: parent
                    source: tile.dark ? game.theme.tile2 : game.theme.tile1
                }

                Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    source: tile.dark ? boardRoot.pieceSource(tile.field) : ""
                    fillMode: Image.PreserveAspectFit
                }

                // notation label
                Rectangle {
                    id: notationBg
                    visible: boardRoot.showNotation && tile.dark
                    z: boardRoot.notationAbove ? 3 : 0
                    width: notationLabel.width + 2
                    height: notationLabel.height
                    anchors.top: parent.top
                    anchors.left: parent.left
                    color: game.theme.notationBackgroundColor
                    Text {
                        id: notationLabel
                        text: tile.dark ? game.labels[tile.field] : ""
                        color: game.theme.notationFontColor
                        font.pixelSize: Math.max(8, boardRoot.cellSize / 5)
                    }
                }

                // selection / last-move highlight
                Image {
                    anchors.fill: parent
                    source: tile.field >= 0 && (tile.field === game.selectedField
                            || tile.field === boardRoot.lastFrom
                            || tile.field === boardRoot.lastTo)
                            ? game.theme.frame : ""
                    opacity: tile.field === game.selectedField ? 1.0 : 0.55
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: tile.dark
                    onClicked: game.clickField(tile.field)
                }
            }
        }
    }
}

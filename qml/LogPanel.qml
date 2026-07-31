import QtQuick 2.0
import QtQuick.Controls 1.2

Rectangle {
    id: logPanel

    function appendLog(type, text) {
        logModel.append({ "type": type, "text": text });
        moveList.positionViewAtEnd();
    }

    function clearLog() {
        logModel.clear();
    }

    function colorFor(type) {
        switch (type) {
        case 1: return "#cc0000";   // Error
        case 2: return "#cc8800";   // Warning
        case 3: return "#888888";   // System
        case 4: return "#000000";   // User
        case 5: return "#0044cc";   // Opponent
        }
        return "#000000";
    }

    ListModel {
        id: logModel
    }

    ListView {
        id: moveList
        anchors.fill: parent
        anchors.margins: 4
        clip: true
        model: logModel
        delegate: Text {
            width: moveList.width - 6
            text: model.text
            color: logPanel.colorFor(model.type)
            wrapMode: Text.WordWrap
        }
    }
}

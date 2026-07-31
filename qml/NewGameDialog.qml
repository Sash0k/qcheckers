import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

Item {
    id: newGameDialog
    visible: false
    anchors.fill: parent

    property int rules: 21
    property bool freePlacement: false
    property string name: ""
    property bool isWhite: false
    property int opponent: 0
    property string opponentName: ""
    property int skill: 2

    signal startRequested

    function openDlg() {
        newGameDialog.rules = game.newGameRules();
        newGameDialog.name = game.player1Name();
        newGameDialog.isWhite = game.player1White();
        newGameDialog.opponent = game.player2Opponent();
        newGameDialog.opponentName = game.player2Name();
        newGameDialog.skill = game.player2Skill();
        rulesCombo.currentIndex = rulesIndex(newGameDialog.rules);
        oppCombo.currentIndex = newGameDialog.opponent;
        skillCombo.currentIndex = skillIndex(newGameDialog.skill);
        visible = true;
    }

    function rulesIndex(r) { return r === 25 ? 1 : 0; }
    function skillIndex(s) {
        for (var i = 0; i < skillCombo.model.length; ++i)
            if (skillCombo.model[i].value === s) return i;
        return 0;
    }

    Rectangle {
        anchors.fill: parent
        color: "#80000000"
        MouseArea { anchors.fill: parent }

        Rectangle {
            width: 460
            height: 330
            anchors.centerIn: parent
            color: "#f0f0f0"
            border.color: "#888888"
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Label {
                    text: qsTr("New Game") + " - QCheckers"
                    font.bold: true
                    font.pixelSize: 16
                }

                Rectangle { height: 1; Layout.fillWidth: true; color: "#888888" }

                GridLayout {
                    columns: 2
                    columnSpacing: 8
                    rowSpacing: 6
                    Layout.fillWidth: true

                    Label { text: qsTr("Name") }
                    TextField {
                        id: nameField
                        Layout.fillWidth: true
                        text: newGameDialog.name
                        onTextChanged: newGameDialog.name = text
                    }

                    Label { text: qsTr("Opponent name") }
                    TextField {
                        id: oppNameField
                        Layout.fillWidth: true
                        text: newGameDialog.opponentName
                        onTextChanged: newGameDialog.opponentName = text
                    }

                    Label { text: qsTr("Rules") }
                    ComboBox {
                        id: rulesCombo
                        Layout.fillWidth: true
                        model: [
                            { value: 21, text: qsTr("English draughts") },
                            { value: 25, text: qsTr("Russian draughts") }
                        ]
                        onActivated: newGameDialog.rules = rulesCombo.model[index].value
                    }

                    Label { text: qsTr("Opponent") }
                    ComboBox {
                        id: oppCombo
                        Layout.fillWidth: true
                        model: [
                            { value: 0, text: qsTr("Computer") },
                            { value: 1, text: qsTr("Human") }
                        ]
                        onActivated: newGameDialog.opponent = oppCombo.model[index].value
                    }

                    Label { text: qsTr("Skill") }
                    ComboBox {
                        id: skillCombo
                        Layout.fillWidth: true
                        model: [
                            { value: 2, text: qsTr("Beginner") },
                            { value: 4, text: qsTr("Novice") },
                            { value: 6, text: qsTr("Average") },
                            { value: 7, text: qsTr("Good") },
                            { value: 8, text: qsTr("Expert") },
                            { value: 9, text: qsTr("Master") }
                        ]
                        onActivated: newGameDialog.skill = skillCombo.model[index].value
                    }

                    CheckBox {
                        id: whiteCheck
                        text: qsTr("I play White")
                        checked: newGameDialog.isWhite
                        onCheckedChanged: newGameDialog.isWhite = checked
                    }
                }

                CheckBox {
                    id: freeCheck
                    text: qsTr("Free Men Placement")
                    checked: newGameDialog.freePlacement
                    onCheckedChanged: newGameDialog.freePlacement = checked
                }

                Rectangle { height: 1; Layout.fillWidth: true; color: "#888888" }

                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }
                    Button {
                        text: qsTr("&Start")
                        onClicked: {
                            newGameDialog.visible = false;
                            newGameDialog.startRequested();
                        }
                    }
                    Button {
                        text: qsTr("&Cancel")
                        onClicked: newGameDialog.visible = false
                    }
                }
            }
        }
    }
}

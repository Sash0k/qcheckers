import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.1

Item {
    id: infoDialog
    visible: false
    anchors.fill: parent

    property string titleText: ""
    property string bodyText: ""

    Rectangle {
        anchors.fill: parent
        color: "#80000000"
        MouseArea { anchors.fill: parent }

        Rectangle {
            width: 480
            height: 300
            anchors.centerIn: parent
            color: "#f0f0f0"
            border.color: "#888888"
            radius: 6

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Label {
                    text: infoDialog.titleText
                    font.bold: true
                    font.pixelSize: 16
                }

                Rectangle { height: 1; Layout.fillWidth: true; color: "#888888" }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentWidth: width
                    contentHeight: body.height
                    clip: true
                    Text {
                        id: body
                        width: parent.width
                        text: infoDialog.bodyText
                        textFormat: Text.RichText
                        wrapMode: Text.WordWrap
                    }
                }

                Button {
                    text: qsTr("OK")
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: infoDialog.visible = false
                }
            }
        }
    }
}

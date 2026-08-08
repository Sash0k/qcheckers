import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    objectName: "mainPage"
    allowedOrientations: Orientation.All

    Column {
        width: parent.width
        anchors.centerIn: parent
        spacing: Theme.paddingLarge

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/icons/logo.svg"
            sourceSize.width: Theme.iconSizeLarge
            sourceSize.height: Theme.iconSizeLarge
        }

        ButtonLayout {
            preferredWidth: Theme.buttonWidthLarge

            Button {
                text: qsTrId("main:play")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("LevelPage.qml"))
                }
            }
            Button {
                text: qsTrId("main:multiplayer")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GamePage.qml"), { "opponent": 1 })
                }
            }
            Button {
                text: qsTrId("main:settings")
                onClicked: {
                }
            }
        }
    }
}

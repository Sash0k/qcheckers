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
                text: qsTrId("level:beginner")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GamePage.qml"), { "level": 2 })
                }
            }
            Button {
                text: qsTrId("level:novice")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GamePage.qml"), { "level": 4 })
                }
            }
            Button {
                text: qsTrId("level:average")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GamePage.qml"), { "level": 6 })
                }
            }
            Button {
                text: qsTrId("level:good")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GamePage.qml"), { "level": 7 })
                }
            }
            Button {
                text: qsTrId("level:expert")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GamePage.qml"), { "level": 8 })
                }
            }
            Button {
                text: qsTrId("level:master")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GamePage.qml"), { "level": 9 })
                }
            }
        }
    }
}

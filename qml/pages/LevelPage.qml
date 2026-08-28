import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    objectName: "levelPage"
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
                text: qsTr("Beginner")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GamePage.qml"), { "level": 2 })
                }
            }
            Button {
                text: qsTr("Novice")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GamePage.qml"), { "level": 4 })
                }
            }
            Button {
                text: qsTr("Average")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GamePage.qml"), { "level": 6 })
                }
            }
            Button {
                text: qsTr("Good")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GamePage.qml"), { "level": 7 })
                }
            }
            Button {
                text: qsTr("Expert")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GamePage.qml"), { "level": 8 })
                }
            }
            Button {
                text: qsTr("Master")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("GamePage.qml"), { "level": 9 })
                }
            }
        }
    }
}

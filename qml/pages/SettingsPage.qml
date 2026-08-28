import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    objectName: "settingsPage"
    allowedOrientations: Orientation.All

    SilicaFlickable {
        objectName: "flickable"
        anchors.fill: parent
        contentHeight: layout.height + Theme.paddingLarge

        Column {
            id: layout
            objectName: "layout"
            width: parent.width

            PageHeader {
                objectName: "pageHeader"
                title: qsTr("Settings")
            }

            ComboBox {
                label: qsTr("Show notation")
                currentIndex: appSettings.notation
                menu: ContextMenu {
                    MenuItem { onClicked: appSettings.notation = 0; text: qsTr("No") }
                    MenuItem { onClicked: appSettings.notation = 1; text: qsTr("Yes") }
                }
            }

            ComboBox {
                label: qsTr("Theme")
                currentIndex: appSettings.theme
                menu: ContextMenu {
                    Repeater {
                        model: themes
                        MenuItem {
                            text: modelData.name
                            onClicked: {
                                game.setTheme(modelData.path)
                                appSettings.theme = index
                            }
                        }
                    }
                }
            }

            PageHeader {
                objectName: "pageHeader"
                title: qsTr("About")
            }

            Label {
                objectName: "descriptionText"
                anchors { left: parent.left; right: parent.right; margins: Theme.horizontalPageMargin }
                font.pixelSize: Theme.fontSizeSmall
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                text: qsTr("QCheckers") + " v-" + VERSION + " " + qsTr("for Aurora OS") + " " + AURORA_OS_VERSION + "<br><a href=\"https://portnov.github.io/qcheckers\">https://portnov.github.io/qcheckers</a>"
            }
       }
    }
}

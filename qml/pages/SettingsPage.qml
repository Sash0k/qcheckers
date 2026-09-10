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
                label: qsTr("Your side")
                currentIndex: appSettings.isWhite
                menu: ContextMenu {
                    MenuItem { onClicked: appSettings.isWhite = 0; text: qsTr("Black") }
                    MenuItem { onClicked: appSettings.isWhite = 1; text: qsTr("White") }
                }
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

            Column {
                width: parent.width
                spacing: 15

                Label {
                    objectName: "descriptionName"
                    anchors { horizontalCenter: parent.horizontalCenter; margins: Theme.horizontalPageMargin }
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                    text: qsTr("Russian draughts") + " (" + qsTr("version") + " " + VERSION + ")"
                }

                Label {
                    objectName: "descriptionText"
                    anchors { horizontalCenter: parent.horizontalCenter; margins: Theme.horizontalPageMargin }
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                    text: qsTr("QCheckers for Aurora OS") + " " + AURORA_OS_VERSION + ". GPLv2."
                }

                Label {
                    objectName: "descriptionNote"
                    anchors { horizontalCenter: parent.horizontalCenter; margins: Theme.horizontalPageMargin }
                    font.pixelSize: Theme.fontSizeMedium
                    wrapMode: Text.WordWrap
                    text: qsTr("Made with AI.")
                }

                LinkedLabel {
                    anchors { horizontalCenter: parent.horizontalCenter; margins: Theme.horizontalPageMargin }
                    font.pixelSize: Theme.fontSizeMedium
                    textFormat: Text.RichText
                    wrapMode: Text.WordWrap
                    defaultLinkActions: true
                    text: "<a href=\"https://portnov.github.io/qcheckers\">https://portnov.github.io</a>"
                }
            }
       }
    }
}

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
                title: qsTrId("settings")
            }

            ComboBox {
                label: qsTrId("settings.notation")
                currentIndex: appSettings.notation
                menu: ContextMenu {
                    MenuItem { onClicked: appSettings.notation = 0; text: qsTrId("no") }
                    MenuItem { onClicked: appSettings.notation = 1; text: qsTrId("yes") }
                }
            }

            ComboBox {
                label: qsTrId("settings.theme")
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
                title: qsTrId("menu.about")
            }

            Label {
                objectName: "descriptionText"
                anchors { left: parent.left; right: parent.right; margins: Theme.horizontalPageMargin }
                font.pixelSize: Theme.fontSizeSmall
                textFormat: Text.RichText
                wrapMode: Text.WordWrap
                text: qsTrId("appName") + " v-" + VERSION + " " + qsTrId("osversion") + " " + AURORA_OS_VERSION + "<br><br>" + qsTrId("about.description") + "<br>"
            }

           ButtonLayout {

               Button {
                   preferredWidth: Theme.buttonWidthMedium
                   text: qsTrId("about.sources")
                   onClicked: { Qt.openUrlExternally("https:/portnov.github.io/qcheckers") }
               }
           }
       }
    }
}

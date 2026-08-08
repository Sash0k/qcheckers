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
                title: qsTrId("menu.settings")
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
                    MenuItem { onClicked: appSettings.theme = 0; text: "SVG Classic" }
                    /*
                    MenuItem { onClicked: appSettings.theme = 1; text: "3D Mark II" }
                    MenuItem { onClicked: appSettings.theme = 2; text: "Simple 3D" }
                    MenuItem { onClicked: appSettings.theme = 3; text: "Printed Chart" }
                    MenuItem { onClicked: appSettings.theme = 4; text: "English" }
                    MenuItem { onClicked: appSettings.theme = 5; text: "Marble" }
                    MenuItem { onClicked: appSettings.theme = 6; text: "Green marble" }
                    MenuItem { onClicked: appSettings.theme = 7; text: "Simple SVG" }
                    MenuItem { onClicked: appSettings.theme = 8; text: "Wood 3D" }
                    */
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

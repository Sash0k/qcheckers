import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    objectName: "defaultCover"

    CoverPlaceholder {
        objectName: "placeholder"
        text: qsTrId("QCheckers")
        icon {
            source: "qrc:/icons/logo.svg"
            sourceSize { width: icon.width; height: icon.height }
        }
        forceFit: true
    }
}

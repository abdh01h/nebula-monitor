import QtQuick
import org.kde.kirigami as Kirigami

Rectangle {
    id: bar

    property real value: 0
    property color fillColor
    property color trackColor

    implicitHeight: Math.max(4, Math.round(Kirigami.Units.gridUnit / 4))
    radius: height / 2
    color: bar.trackColor

    Rectangle {
        width: bar.width * Math.max(0, Math.min(1, bar.value / 100))
        height: bar.height
        radius: bar.radius
        color: bar.fillColor

        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }
}

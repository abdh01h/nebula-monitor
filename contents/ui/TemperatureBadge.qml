import QtQuick
import org.kde.kirigami as Kirigami

import "format.js" as Format

Rectangle {
    id: badge

    property var colors
    property real fontScale: 1
    property real temperature: NaN

    readonly property bool available: isFinite(temperature) && temperature > 0

    readonly property color accentColor: {
        switch (Format.temperatureLevel(temperature)) {
        case 2:
            return colors.tempHot;
        case 1:
            return colors.tempWarm;
        case 0:
            return colors.tempSafe;
        default:
            return colors.muted;
        }
    }

    visible: available
    implicitWidth: temperatureLabel.implicitWidth + Math.round(Kirigami.Units.smallSpacing * 2.5)
    implicitHeight: temperatureLabel.implicitHeight + Math.round(Kirigami.Units.smallSpacing * 1.5)
    radius: height / 2
    color: Qt.alpha(badge.accentColor, 0.16)

    ScaledLabel {
        id: temperatureLabel
        anchors.centerIn: parent
        text: Format.temperature(badge.temperature)
        color: badge.accentColor
        bold: true
        fontScale: badge.fontScale * 1.1
    }
}

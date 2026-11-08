import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "format.js" as Format

Rectangle {
    id: card

    property var colors
    property real fontScale: 1
    property int contentPadding: 14
    property real used: NaN
    property real total: NaN
    property real percent: NaN

    radius: Math.round(Kirigami.Units.gridUnit / 3)
    color: card.colors.surface

    implicitWidth: content.implicitWidth + contentPadding * 2
    implicitHeight: content.implicitHeight + contentPadding * 2

    ColumnLayout {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: card.contentPadding
        width: parent.width - card.contentPadding * 2
        height: implicitHeight
        spacing: Math.round(Kirigami.Units.smallSpacing / 2)

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            ScaledLabel {
                text: i18n("SWAP")
                bold: true
                fontScale: card.fontScale
                color: card.colors.text
                Layout.fillWidth: true
            }

            ScaledLabel {
                text: Format.percent(card.percent)
                bold: true
                fontScale: card.fontScale
                color: card.colors.text
            }
        }

        ScaledLabel {
            text: Format.memory(card.used) + " / " + Format.memory(card.total)
            small: true
            fontScale: card.fontScale
            color: card.colors.muted
        }

        UsageBar {
            Layout.fillWidth: true
            value: card.percent
            trackColor: card.colors.track
            fillColor: {
                switch (Format.usageLevel(card.percent)) {
                case 2:
                    return card.colors.negative;
                case 1:
                    return card.colors.neutral;
                default:
                    return card.colors.accent;
                }
            }
        }
    }
}

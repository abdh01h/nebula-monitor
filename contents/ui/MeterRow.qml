import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "format.js" as Format

// One metric card: name and live values, extra detail, history chart below.
Rectangle {
    id: card

    property var colors
    property real fontScale: 1
    property real tempFontScale: 1
    property int contentPadding: 14

    property string label
    property string detail

    // Usage in percent, 0 - 100.
    property real usage: 0

    // Temperature in degrees Celsius, NaN when the sensor is unavailable.
    property real temperature: NaN

    property var history: []

    radius: Math.round(Kirigami.Units.gridUnit / 3)
    color: card.colors.surface
    clip: true

    implicitWidth: content.implicitWidth + contentPadding * 2
    implicitHeight: content.implicitHeight + contentPadding * 2

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: card.contentPadding
        spacing: Math.round(Kirigami.Units.smallSpacing / 2)

        RowLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            ScaledLabel {
                text: card.label
                bold: true
                fontScale: card.fontScale
                color: card.colors.text
                Layout.alignment: Qt.AlignVCenter
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: 1
            }

            TemperatureBadge {
                colors: card.colors
                fontScale: card.fontScale * card.tempFontScale
                temperature: card.temperature
                Layout.alignment: Qt.AlignVCenter
                Layout.rightMargin: Math.round(Kirigami.Units.smallSpacing * 2)
            }

            ScaledLabel {
                text: Format.percent(card.usage)
                bold: true
                fontScale: card.fontScale * 1.6
                color: card.colors.text
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: Math.round(Kirigami.Units.gridUnit * 2.2 * card.fontScale)
                Layout.alignment: Qt.AlignVCenter
            }
        }

        ScaledLabel {
            Layout.fillWidth: true
            text: card.detail
            visible: text.length > 0
            small: true
            fontScale: card.fontScale
            color: card.colors.muted
            elide: Text.ElideRight
        }

        Sparkline {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: Math.round(Kirigami.Units.gridUnit * 1.7 * card.fontScale)
            Layout.minimumHeight: Math.round(Kirigami.Units.gridUnit * 0.8)
            values: card.history
            lineColor: card.colors.accent
            gridColor: card.colors.border
        }
    }
}

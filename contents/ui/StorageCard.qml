import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "format.js" as Format

Rectangle {
    id: card

    // Array of { name, total, used, temperature, health } objects.
    property var disks: []
    property var colors
    property real fontScale: 1
    property real tempFontScale: 1
    property int contentPadding: 14

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

        ScaledLabel {
            text: i18n("STORAGE")
            bold: true
            fontScale: card.fontScale
            color: card.colors.text
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: card.colors.border
        }

        Repeater {
            model: card.disks

            delegate: ColumnLayout {
                id: disk
                Layout.fillWidth: true
                spacing: Math.round(Kirigami.Units.smallSpacing / 2)

                readonly property real percent: modelData.total > 0 ? modelData.used / modelData.total * 100 : 0
                readonly property string healthText: modelData.health || "\u2014"
                readonly property color healthColor: {
                    switch (modelData.health) {
                    case "OK":
                        return card.colors.positive;
                    case "Warning":
                    case "Fail":
                        return card.colors.negative;
                    default:
                        return card.colors.muted;
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    ScaledLabel {
                        text: Format.diskName(modelData.name)
                        bold: true
                        fontScale: card.fontScale
                        color: card.colors.text
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    TemperatureBadge {
                        colors: card.colors
                        fontScale: card.fontScale * card.tempFontScale
                        temperature: modelData.temperature
                        Layout.alignment: Qt.AlignVCenter
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    ScaledLabel {
                        text: Format.memory(modelData.used) + " / " + Format.memory(modelData.total)
                        small: true
                        fontScale: card.fontScale
                        color: card.colors.muted
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    ScaledLabel {
                        text: disk.healthText
                        small: true
                        fontScale: card.fontScale
                        color: disk.healthColor
                    }

                    ScaledLabel {
                        text: Format.percent(disk.percent)
                        small: true
                        fontScale: card.fontScale
                        color: card.colors.text
                        Layout.preferredWidth: Math.round(Kirigami.Units.gridUnit * 1.8 * card.fontScale)
                        horizontalAlignment: Text.AlignRight
                    }
                }

                UsageBar {
                    Layout.fillWidth: true
                    value: disk.percent
                    trackColor: card.colors.track
                    fillColor: {
                        switch (Format.usageLevel(disk.percent)) {
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
    }
}

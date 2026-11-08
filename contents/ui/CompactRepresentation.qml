import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "format.js" as Format

ColumnLayout {
    id: compact

    property var colors
    property real fontScale: 1
    property real tempFontScale: 1

    property real cpuUsage
    property real cpuTemperature
    property real gpuUsage
    property real gpuTemperature
    property real memoryPercent

    spacing: 0

    component Line: RowLayout {
        id: line

        property string label
        property real usage
        property real temperature
        property var colors
        property real fontScale
        property real tempFontScale

        readonly property color temperatureColor: {
            switch (Format.temperatureLevel(line.temperature)) {
            case 2:
                return line.colors.tempHot;
            case 1:
                return line.colors.tempWarm;
            default:
                return line.colors.tempSafe;
            }
        }

        spacing: Kirigami.Units.smallSpacing

        ScaledLabel {
            text: line.label
            small: true
            fontScale: line.fontScale
            color: line.colors.text
            Layout.fillWidth: true
        }
        ScaledLabel {
            text: Format.percent(line.usage)
            small: true
            bold: true
            fontScale: line.fontScale
            color: line.colors.text
        }
        ScaledLabel {
            text: Format.temperature(line.temperature)
            visible: isFinite(line.temperature) && line.temperature > 0
            small: true
            fontScale: line.fontScale * line.tempFontScale
            color: line.temperatureColor
        }
    }

    Line {
        label: i18n("CPU")
        usage: compact.cpuUsage
        temperature: compact.cpuTemperature
        colors: compact.colors
        fontScale: compact.fontScale
        tempFontScale: compact.tempFontScale
    }
    Line {
        label: i18n("GPU")
        usage: compact.gpuUsage
        temperature: compact.gpuTemperature
        colors: compact.colors
        fontScale: compact.fontScale
        tempFontScale: compact.tempFontScale
    }
    Line {
        label: i18n("RAM")
        usage: compact.memoryPercent
        temperature: NaN
        colors: compact.colors
        fontScale: compact.fontScale
        tempFontScale: compact.tempFontScale
    }
}

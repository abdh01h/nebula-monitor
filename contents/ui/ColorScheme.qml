import QtQuick
import org.kde.kirigami as Kirigami

// Colour scheme of the widget. Either follows the Plasma colour scheme or uses
// a built-in dark one, and is shared by all cards.
//
// This is an Item (not a QtObject) on purpose: Kirigami.Theme resolves the
// active colour scheme from the item hierarchy, so a non-visual QtObject would
// always fall back to the default light palette.
Item {
    id: palette
    visible: false
    width: 0
    height: 0

    property bool followSystemTheme: true

    readonly property color background: followSystemTheme ? Kirigami.Theme.backgroundColor : "#101319"
    readonly property color surface: followSystemTheme ? Qt.alpha(Kirigami.Theme.textColor, 0.07) : Qt.alpha("#ffffff", 0.06)
    readonly property color text: followSystemTheme ? Kirigami.Theme.textColor : "#eef1f6"
    readonly property color muted: followSystemTheme ? Kirigami.Theme.disabledTextColor : Qt.alpha("#eef1f6", 0.55)
    readonly property color accent: followSystemTheme ? Kirigami.Theme.highlightColor : "#2fb8a6"
    readonly property color positive: followSystemTheme ? Kirigami.Theme.positiveTextColor : "#54c98a"
    readonly property color neutral: followSystemTheme ? Kirigami.Theme.neutralTextColor : "#e5a13c"
    readonly property color negative: followSystemTheme ? Kirigami.Theme.negativeTextColor : "#e36969"
    readonly property color border: followSystemTheme ? Qt.alpha(Kirigami.Theme.textColor, 0.08) : Qt.alpha("#ffffff", 0.09)
    readonly property color track: followSystemTheme ? Qt.alpha(Kirigami.Theme.textColor, 0.16) : Qt.alpha("#ffffff", 0.14)

    // Temperature levels: green = safe, yellow = warm, red = danger.
    readonly property bool darkBackground: {
        const c = background;
        return (0.299 * c.r + 0.587 * c.g + 0.114 * c.b) < 0.5;
    }
    readonly property color tempSafe: darkBackground ? "#4ccf74" : "#1e8a44"
    readonly property color tempWarm: darkBackground ? "#f0c24b" : "#a36f00"
    readonly property color tempHot: darkBackground ? "#ef5b5b" : "#c62828"
}

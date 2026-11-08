import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.Label {
    id: label

    // Multiplier for the font size chosen in the widget configuration.
    property real fontScale: 1

    // Use the smaller theme font instead of the default one.
    property bool small: false
    property bool bold: false

    readonly property font baseFont: small ? Kirigami.Theme.smallFont : Kirigami.Theme.defaultFont

    font.family: baseFont.family
    font.pointSize: Math.max(1, Math.round(baseFont.pointSize * fontScale))
    font.weight: bold ? Font.Bold : baseFont.weight
    font.italic: baseFont.italic
}

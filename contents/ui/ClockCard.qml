import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

// Centred clock: large time with the date underneath.
Rectangle {
    id: card

    property var colors
    property real fontScale: 1
    property int contentPadding: 14
    property string timeFormat: "h:mm AP"
    property string dateFormat: "dd/MM/yyyy"
    property var currentTime: new Date()

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
            Layout.fillWidth: true
            text: Qt.formatTime(card.currentTime, card.timeFormat)
            bold: true
            fontScale: card.fontScale * 2.2
            color: card.colors.text
            horizontalAlignment: Text.AlignHCenter
        }

        ScaledLabel {
            Layout.fillWidth: true
            text: Qt.formatDate(card.currentTime, card.dateFormat)
            bold: true
            fontScale: card.fontScale * 1.2
            color: card.colors.text
            horizontalAlignment: Text.AlignHCenter
        }
    }
}

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

import "format.js" as Format

Rectangle {
    id: card

    property var colors
    property real fontScale: 1
    property int contentPadding: 14

    property var info: ({})
    // Map of row key -> bool, e.g. { os: true, apex: false }.
    property var visibility: ({})

    readonly property bool vpnActive: info.vpn !== undefined && info.vpn !== ""
    readonly property string linkLabel: info.linktype === "ethernet" ? i18n("Ethernet") : i18n("Wi-Fi")

    readonly property var rows: {
        const result = [];
        const visible = visibility || {};
        const data = info || {};

        function add(key, label, value, color, extra) {
            if (visible[key] === false) {
                return;
            }
            if (value === undefined || value === null || value === "") {
                return;
            }
            const row = {
                key: key,
                label: label,
                value: value,
                color: color || card.colors.text,
                indent: false
            };
            if (extra) {
                for (const property in extra) {
                    row[property] = extra[property];
                }
            }
            result.push(row);
        }

        add("os", i18n("OS"), data.os);
        add("host", i18n("Host"), data.host);
        add("kernel", i18n("Kernel"), data.kernel);
        if (data.uptime !== undefined) {
            add("uptime", i18n("Uptime"), Format.uptime(Number(data.uptime)));
        }
        add("packages", i18n("Packages"), data.packages);
        add("snap", i18n("Snap"), data.snap_packages);
        add("flatpak", i18n("Flatpak"), data.flatpak_packages);
        add("desktop", i18n("Desktop"), data.desktop);
        add("arch", i18n("Architecture"), data.arch);
        add("model", i18n("Model"), data.model);
        add("session", i18n("Session"), data.session);
        add("link", card.linkLabel, data.link);
        add("ip", i18n("IP"), data.ip);
        add("vpn", i18n("VPN"), card.vpnActive ? data.vpn : i18n("Off"),
            card.vpnActive ? card.colors.positive : card.colors.muted);
        if (data.updates !== undefined && data.updates !== "") {
            const pending = Number(data.updates);
            add("updates", i18n("Updates"),
                pending > 0 ? i18n("%1 available", pending) : i18n("Up to date"),
                pending > 0 ? card.colors.neutral : card.colors.positive);
        }
        return result;
    }

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
            text: i18n("SYSTEM")
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
            model: card.rows

            delegate: RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                ScaledLabel {
                    text: modelData.label
                    small: true
                    fontScale: card.fontScale
                    color: card.colors.muted
                    Layout.preferredWidth: Math.round(Kirigami.Units.gridUnit * 4.2 * card.fontScale)
                    elide: Text.ElideRight
                }

                ScaledLabel {
                    text: modelData.value
                    small: true
                    fontScale: card.fontScale
                    color: modelData.color
                    horizontalAlignment: Text.AlignRight
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }
        }
    }
}

#!/usr/bin/env python3
"""Generates the two configuration pages from contents/config/main.xml.

Both pages are committed, but they must declare the config keys they control
(Plasma passes every key to the page when it opens). Run this script after
changing main.xml so the aliases and the cfg_*Default constants stay in sync:

    python3 generate-config-pages.py
"""

import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parent
XML = ROOT / "contents/config/main.xml"
UI = ROOT / "contents/ui/config"

NS = {"k": "http://www.kde.org/standards/kcfg/1.0"}
QML_TYPE = {"Bool": "bool", "Int": "int", "Double": "real", "String": "string"}
QML_VALUE = {
    "Bool": lambda v: "true" if v == "true" else "false",
    "Int": lambda v: str(int(v)),
    "Double": lambda v: str(float(v)),
    "String": lambda v: '"%s"' % v,
}

APPEARANCE = {
    "fontScale": ("fontScaleSlider", "value"),
    "customWidth": ("customWidthCheck", "checked"),
    "width": ("widthSpin", "value"),
    "horizontal": ("horizontalCheck", "checked"),
    "padding": ("paddingSpin", "value"),
    "backgroundOpacity": ("opacitySlider", "value"),
    "showBorder": ("showBorderCheck", "checked"),
    "followSystemTheme": ("followThemeCheck", "checked"),
    "timeFormat": ("timeFormatCombo", "currentValue"),
    "dateFormat": ("dateFormatCombo", "currentValue"),
    "tempFontScale": ("tempFontScaleSlider", "value"),
}

CARDS = [
    ("showClock", "Clock"),
    ("showSystem", "System information"),
    ("showCpu", "CPU"),
    ("showGpu", "GPU"),
    ("showRam", "RAM"),
    ("showSwap", "Swap"),
    ("showStorage", "Storage"),
]

ROWS = [
    ("infoOs", "Operating system"),
    ("infoHost", "Host"),
    ("infoKernel", "Kernel"),
    ("infoUptime", "Uptime"),
    ("infoPackages", "Installed packages"),
    ("infoDesktop", "Desktop session"),
    ("infoLink", "Wi-Fi / Ethernet"),
    ("infoIp", "IP address"),
    ("infoVpn", "VPN"),
    ("infoArch", "Architecture"),
    ("infoModel", "Hardware model"),
    ("infoSession", "Session type"),
    ("infoSnap", "Snap packages"),
    ("infoFlatpak", "Flatpak packages"),
    ("infoUpdates", "Pending system updates"),
]

SECTIONS = {key: (key + "Check", "checked") for key, _ in CARDS + ROWS}


def entries():
    tree = ET.parse(XML)
    group = tree.getroot().find("k:group", NS)
    for entry in group.findall("k:entry", NS):
        default = entry.find("k:default", NS)
        yield (
            entry.get("name"),
            entry.get("type"),
            default.text if default is not None else "",
        )


def declarations(controlled):
    lines = [
        "    // This page only declares the keys it controls, so saving it never",
        "    // overwrites settings that belong to another page.",
    ]
    for name in controlled:
        target, prop = controlled[name]
        lines.append("    property alias cfg_%s: %s.%s" % (name, target, prop))
    lines.append("")
    lines.append('    // Constants used by the "Defaults" button.')
    for name, kind, default in entries():
        lines.append(
            "    property %s cfg_%sDefault: %s"
            % (QML_TYPE[kind], name, QML_VALUE[kind](default))
        )
    return "\n".join(lines)


def checkbox(identifier, label):
    return (
        '        QQC2.CheckBox {\n'
        '            id: %s\n'
        '            text: i18n("%s")\n'
        "            onToggled: page.markChanged()\n"
        "        }\n" % (identifier, label)
    )


APPEARANCE_PAGE = """import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    signal configurationChanged

%(decl)s

    function markChanged() {
        page.configurationChanged();
    }

    Kirigami.FormLayout {
        RowLayout {
            Kirigami.FormData.label: i18n("Font size:")

            QQC2.Slider {
                id: fontScaleSlider
                Layout.preferredWidth: Kirigami.Units.gridUnit * 14
                from: 0.8
                to: 1.8
                stepSize: 0.05
                onMoved: page.markChanged()
            }

            QQC2.Label {
                text: Math.round(fontScaleSlider.value * 100) + "%%"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 2
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Temperature size:")

            QQC2.Slider {
                id: tempFontScaleSlider
                Layout.preferredWidth: Kirigami.Units.gridUnit * 14
                from: 0.6
                to: 2.0
                stepSize: 0.05
                onMoved: page.markChanged()
            }

            QQC2.Label {
                text: Math.round(tempFontScaleSlider.value * 100) + "%%"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 2
            }
        }

        QQC2.CheckBox {
            id: horizontalCheck
            text: i18n("Horizontal layout (one row)")
            onToggled: page.markChanged()
        }

        QQC2.CheckBox {
            id: customWidthCheck
            text: i18n("Custom width")
            onToggled: page.markChanged()
        }

        QQC2.SpinBox {
            id: widthSpin
            Kirigami.FormData.label: i18n("Width:")
            enabled: customWidthCheck.checked
            from: 200
            to: 1200
            stepSize: 10
            editable: true
            onValueModified: page.markChanged()
        }

        QQC2.SpinBox {
            id: paddingSpin
            Kirigami.FormData.label: i18n("Padding:")
            from: 0
            to: 30
            editable: true
            onValueModified: page.markChanged()
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Background opacity:")

            QQC2.Slider {
                id: opacitySlider
                Layout.preferredWidth: Kirigami.Units.gridUnit * 14
                from: 0
                to: 100
                stepSize: 1
                onMoved: page.markChanged()
            }

            QQC2.Label {
                text: opacitySlider.value + "%%"
                Layout.preferredWidth: Kirigami.Units.gridUnit * 2
            }
        }

        QQC2.CheckBox {
            id: showBorderCheck
            text: i18n("Show border")
            onToggled: page.markChanged()
        }

        QQC2.CheckBox {
            id: followThemeCheck
            text: i18n("Follow system colour scheme")
            onToggled: page.markChanged()
        }

        QQC2.ComboBox {
            id: timeFormatCombo
            Kirigami.FormData.label: i18n("Time format:")
            textRole: "text"
            valueRole: "value"
            model: [
                { text: i18n("12-hour (1:30 PM)"), value: "h:mm AP" },
                { text: i18n("24-hour (13:30)"), value: "HH:mm" }
            ]
            onActivated: page.markChanged()
        }

        QQC2.ComboBox {
            id: dateFormatCombo
            Kirigami.FormData.label: i18n("Date format:")
            textRole: "text"
            valueRole: "value"
            model: [
                { text: i18n("DD/MM/YYYY"), value: "dd/MM/yyyy" },
                { text: i18n("MM/DD/YYYY"), value: "MM/dd/yyyy" },
                { text: i18n("YYYY-MM-DD"), value: "yyyy-MM-dd" }
            ]
            onActivated: page.markChanged()
        }

        QQC2.Label {
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            Layout.maximumWidth: Kirigami.Units.gridUnit * 22
            wrapMode: Text.Wrap
            text: i18n("Opacity 0%% (the default) draws no panel behind the cards and therefore no "
                      + "outline. Raise it for a translucent panel, or enable the border alone.")
        }
    }
}
"""

SECTIONS_PAGE = """import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    signal configurationChanged

%(decl)s

    function markChanged() {
        page.configurationChanged();
    }

    Kirigami.FormLayout {
        QQC2.Label {
            Kirigami.FormData.isSection: true
            text: i18n("Cards")
        }

%(cards)s
        QQC2.Label {
            Kirigami.FormData.isSection: true
            text: i18n("System information rows")
        }

%(rows)s
        QQC2.Label {
            font: Kirigami.Theme.smallFont
            opacity: 0.7
            Layout.maximumWidth: Kirigami.Units.gridUnit * 24
            wrapMode: Text.Wrap
            text: i18n("Rows without data on this machine (for example Flatpak when it is not "
                      + "installed) are hidden automatically. Snap and Flatpak are shown by "
                      + "default when available; updates are hidden by default.")
        }
    }
}
"""


def main():
    (UI / "ConfigGeneral.qml").write_text(
        APPEARANCE_PAGE % {"decl": declarations(APPEARANCE)}
    )
    (UI / "ConfigSections.qml").write_text(
        SECTIONS_PAGE
        % {
            "decl": declarations(SECTIONS),
            "cards": "".join(checkbox(SECTIONS[k][0], l) for k, l in CARDS),
            "rows": "".join(checkbox(SECTIONS[k][0], l) for k, l in ROWS),
        }
    )
    print("Generated", UI / "ConfigGeneral.qml")
    print("Generated", UI / "ConfigSections.qml")


if __name__ == "__main__":
    main()

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: page

    signal configurationChanged

    // This page only declares the keys it controls, so saving it never
    // overwrites settings that belong to another page.
    property alias cfg_fontScale: fontScaleSlider.value
    property alias cfg_customWidth: customWidthCheck.checked
    property alias cfg_width: widthSpin.value
    property alias cfg_horizontal: horizontalCheck.checked
    property alias cfg_padding: paddingSpin.value
    property alias cfg_backgroundOpacity: opacitySlider.value
    property alias cfg_showBorder: showBorderCheck.checked
    property alias cfg_followSystemTheme: followThemeCheck.checked
    property alias cfg_timeFormat: timeFormatCombo.currentValue
    property alias cfg_dateFormat: dateFormatCombo.currentValue
    property alias cfg_tempFontScale: tempFontScaleSlider.value

    // Constants used by the "Defaults" button.
    property real cfg_fontScaleDefault: 1.0
    property bool cfg_customWidthDefault: false
    property int cfg_widthDefault: 300
    property bool cfg_horizontalDefault: false
    property int cfg_paddingDefault: 14
    property int cfg_backgroundOpacityDefault: 0
    property bool cfg_showBorderDefault: false
    property bool cfg_followSystemThemeDefault: true
    property string cfg_timeFormatDefault: "h:mm AP"
    property string cfg_dateFormatDefault: "dd/MM/yyyy"
    property real cfg_tempFontScaleDefault: 0.7
    property bool cfg_showClockDefault: true
    property bool cfg_showSystemDefault: true
    property bool cfg_showCpuDefault: true
    property bool cfg_showGpuDefault: true
    property bool cfg_showRamDefault: true
    property bool cfg_showSwapDefault: true
    property bool cfg_showStorageDefault: true
    property bool cfg_infoOsDefault: true
    property bool cfg_infoHostDefault: true
    property bool cfg_infoKernelDefault: true
    property bool cfg_infoUptimeDefault: true
    property bool cfg_infoPackagesDefault: true
    property bool cfg_infoDesktopDefault: true
    property bool cfg_infoLinkDefault: true
    property bool cfg_infoIpDefault: true
    property bool cfg_infoVpnDefault: true
    property bool cfg_infoArchDefault: false
    property bool cfg_infoModelDefault: false
    property bool cfg_infoSessionDefault: false
    property bool cfg_infoSnapDefault: true
    property bool cfg_infoFlatpakDefault: true
    property bool cfg_infoUpdatesDefault: false

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
                text: Math.round(fontScaleSlider.value * 100) + "%"
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
                text: Math.round(tempFontScaleSlider.value * 100) + "%"
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
                text: opacitySlider.value + "%"
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
            text: i18n("Opacity 0% (the default) draws no panel behind the cards and therefore no "
                      + "outline. Raise it for a translucent panel, or enable the border alone.")
        }
    }
}

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
    property alias cfg_showClock: showClockCheck.checked
    property alias cfg_showSystem: showSystemCheck.checked
    property alias cfg_showCpu: showCpuCheck.checked
    property alias cfg_showGpu: showGpuCheck.checked
    property alias cfg_showRam: showRamCheck.checked
    property alias cfg_showSwap: showSwapCheck.checked
    property alias cfg_showStorage: showStorageCheck.checked
    property alias cfg_infoOs: infoOsCheck.checked
    property alias cfg_infoHost: infoHostCheck.checked
    property alias cfg_infoKernel: infoKernelCheck.checked
    property alias cfg_infoUptime: infoUptimeCheck.checked
    property alias cfg_infoPackages: infoPackagesCheck.checked
    property alias cfg_infoDesktop: infoDesktopCheck.checked
    property alias cfg_infoLink: infoLinkCheck.checked
    property alias cfg_infoIp: infoIpCheck.checked
    property alias cfg_infoVpn: infoVpnCheck.checked
    property alias cfg_infoArch: infoArchCheck.checked
    property alias cfg_infoModel: infoModelCheck.checked
    property alias cfg_infoSession: infoSessionCheck.checked
    property alias cfg_infoSnap: infoSnapCheck.checked
    property alias cfg_infoFlatpak: infoFlatpakCheck.checked
    property alias cfg_infoUpdates: infoUpdatesCheck.checked

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
        QQC2.Label {
            Kirigami.FormData.isSection: true
            text: i18n("Cards")
        }

        QQC2.CheckBox {
            id: showClockCheck
            text: i18n("Clock")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: showSystemCheck
            text: i18n("System information")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: showCpuCheck
            text: i18n("CPU")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: showGpuCheck
            text: i18n("GPU")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: showRamCheck
            text: i18n("RAM")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: showSwapCheck
            text: i18n("Swap")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: showStorageCheck
            text: i18n("Storage")
            onToggled: page.markChanged()
        }

        QQC2.Label {
            Kirigami.FormData.isSection: true
            text: i18n("System information rows")
        }

        QQC2.CheckBox {
            id: infoOsCheck
            text: i18n("Operating system")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoHostCheck
            text: i18n("Host")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoKernelCheck
            text: i18n("Kernel")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoUptimeCheck
            text: i18n("Uptime")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoPackagesCheck
            text: i18n("Installed packages")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoDesktopCheck
            text: i18n("Desktop session")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoLinkCheck
            text: i18n("Wi-Fi / Ethernet")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoIpCheck
            text: i18n("IP address")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoVpnCheck
            text: i18n("VPN")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoArchCheck
            text: i18n("Architecture")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoModelCheck
            text: i18n("Hardware model")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoSessionCheck
            text: i18n("Session type")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoSnapCheck
            text: i18n("Snap packages")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoFlatpakCheck
            text: i18n("Flatpak packages")
            onToggled: page.markChanged()
        }
        QQC2.CheckBox {
            id: infoUpdatesCheck
            text: i18n("Pending system updates")
            onToggled: page.markChanged()
        }

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

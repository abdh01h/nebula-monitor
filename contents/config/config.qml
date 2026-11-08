import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("Appearance")
        icon: "preferences-desktop-color"
        source: "config/ConfigGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Sections")
        icon: "configure"
        source: "config/ConfigSections.qml"
    }
}

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Window
import org.kde.kirigami as Kirigami

import "format.js" as Format

Item {
    id: full
    clip: true

    // ------------------------------------------------------------- appearance

    // Live applet configuration; every key falls back to its default so the
    // component also works standalone (previews, tests).
    property var config: ({})

    // Used to keep equal-width cards on screen; exposed as a property so the
    // layout can be previewed outside Plasma.
    property real screenWidth: Screen.width

    property var colors: builtinColors
    property real fontScale: 1
    property int contentPadding: 14
    property bool horizontal: false
    property bool customWidth: false
    property int configuredWidth: 300
    property int backgroundOpacity: 0
    property bool showBorder: false
    property string timeFormat: "h:mm AP"
    property string dateFormat: "dd/MM/yyyy"

    ColorScheme {
        id: builtinColors
        followSystemTheme: true
    }

    readonly property bool showClock: config.showClock ?? true
    readonly property bool showSystem: config.showSystem ?? true
    readonly property bool showCpu: config.showCpu ?? true
    readonly property bool showGpu: config.showGpu ?? true
    readonly property bool showRam: config.showRam ?? true
    readonly property bool showSwap: config.showSwap ?? true
    readonly property bool showStorage: config.showStorage ?? true

    readonly property real tempFontScale: config.tempFontScale ?? 0.7

    readonly property var infoVisibility: ({
        os: config.infoOs ?? true,
        host: config.infoHost ?? true,
        kernel: config.infoKernel ?? true,
        uptime: config.infoUptime ?? true,
        packages: config.infoPackages ?? true,
        desktop: config.infoDesktop ?? true,
        link: config.infoLink ?? true,
        ip: config.infoIp ?? true,
        vpn: config.infoVpn ?? true,
        arch: config.infoArch ?? false,
        model: config.infoModel ?? false,
        session: config.infoSession ?? false,
        snap: config.infoSnap ?? true,
        flatpak: config.infoFlatpak ?? true,
        updates: config.infoUpdates ?? false
    })

    readonly property int visibleSections: (showClock ? 1 : 0)
        + (showSystem ? 1 : 0)
        + (showCpu ? 1 : 0)
        + (showGpu ? 1 : 0)
        + (showRam ? 1 : 0)
        + (showSwap ? 1 : 0)
        + (showStorage ? 1 : 0)

    readonly property int cpuCores: Number(systemInfo.cores) || 0

    // ----------------------------------------------------------------- sensors

    property real cpuUsage
    property real cpuTemperature
    property real cpuFrequency
    property var cpuHistory: []

    property real gpuUsage
    property real gpuTemperature
    property real gpuUsedVram
    property real gpuTotalVram
    property var gpuHistory: []

    property real memoryPercent
    property real memoryUsed
    property real memoryTotal
    property var memoryHistory: []

    property real swapUsed
    property real swapTotal
    property real swapPercent

    property var systemInfo: ({})
    property var disks: []

    // ------------------------------------------------------------------- clock

    property var now: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: full.now = new Date()
    }

    // -------------------------------------------------------------------- size

    readonly property int outerPadding: contentPadding
    readonly property int spacing: Kirigami.Units.smallSpacing
    readonly property real availableWidth: Math.max(0, width - outerPadding * 2)

    // Width of the visible widget content (the applet area, or the configured
    // width when a custom width is set).
    readonly property real visibleWidth: customWidth
        ? Math.max(120, Math.min(configuredWidth, availableWidth))
        : availableWidth

    // In horizontal mode all cards sit in one row and share the same width:
    // the widest card in the row. If the widget is narrower than the row it
    // scrolls horizontally instead of squeezing the cards.
    // Horizontal mode: the clock gets its own full-width row above the cards
    // and swap is stacked above storage in the last column.
    readonly property bool stackedSwapStorage: horizontal && showSwap && showStorage

    readonly property int rowColumns: {
        if (!horizontal) {
            return 1;
        }
        const cards = visibleSections - (showClock ? 1 : 0) - (stackedSwapStorage ? 1 : 0);
        return Math.max(1, cards);
    }

    readonly property real cardWidth: {
        const count = Math.max(1, rowColumns);
        let widest = Math.round(Kirigami.Units.gridUnit * 10);
        const cards = [systemCard, cpuCard, gpuCard, ramCard, swapCard, storageCard];
        for (const card of cards) {
            if (card && card.visible) {
                widest = Math.max(widest, card.implicitWidth);
            }
        }
        // Equal columns get the widest natural card, capped so the row still
        // fits on the screen.
        const usable = (screenWidth > 0 ? screenWidth : visibleWidth) - Kirigami.Units.gridUnit * 4;
        const fitting = Math.floor((usable - (count - 1) * spacing) / count);
        return Math.max(Kirigami.Units.gridUnit * 8, Math.min(widest, fitting));
    }

    readonly property real rowWidth: horizontal
        ? Math.max(visibleWidth, rowColumns * cardWidth + (rowColumns - 1) * spacing)
        : visibleWidth

    implicitWidth: customWidth
        ? configuredWidth + outerPadding * 2
        : (horizontal ? rowWidth + outerPadding * 2
                      : Kirigami.Units.gridUnit * 11 + outerPadding * 2)
    implicitHeight: layout.implicitHeight + outerPadding * 2

    // Desktop widgets are sized by their containment; these hints let the
    // widget grow to whatever the configured content requires.
    Layout.minimumWidth: customWidth
        ? configuredWidth + outerPadding * 2
        : (horizontal ? implicitWidth : -1)
    Layout.minimumHeight: implicitHeight

    Rectangle {
        id: backdrop
        x: Math.round((full.width - width) / 2)
        y: 0
        width: full.visibleWidth + full.outerPadding * 2
        height: layout.height + full.outerPadding * 2
        radius: Math.round(Kirigami.Units.gridUnit / 2)
        color: Qt.alpha(full.colors.background, full.backgroundOpacity / 100)
        border.width: full.showBorder ? 1 : 0
        border.color: full.colors.border
        visible: full.backgroundOpacity > 0 || full.showBorder
    }

    Flickable {
        id: scroller
        x: backdrop.x + full.outerPadding
        y: full.outerPadding
        width: full.visibleWidth
        height: layout.implicitHeight
        contentWidth: layout.width
        contentHeight: height
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: full.horizontal && contentWidth > width

        QQC2.ScrollBar.horizontal: QQC2.ScrollBar {}

        GridLayout {
            id: layout
            width: full.horizontal ? full.rowWidth : full.visibleWidth
            height: implicitHeight
            columns: full.rowColumns
            rowSpacing: full.spacing
            columnSpacing: full.spacing

            ClockCard {
                id: clockCard
                Layout.columnSpan: full.horizontal ? full.rowColumns : 1
                Layout.alignment: Qt.AlignTop
                visible: full.showClock
                Layout.fillWidth: true
                Layout.minimumWidth: full.horizontal ? full.cardWidth : 0
                Layout.fillHeight: true
                colors: full.colors
                fontScale: full.fontScale
                contentPadding: full.contentPadding
                timeFormat: full.timeFormat
                dateFormat: full.dateFormat
                currentTime: full.now
            }

            SystemInfoCard {
                id: systemCard
                Layout.alignment: Qt.AlignTop
                visible: full.showSystem
                Layout.fillWidth: true
                Layout.minimumWidth: full.horizontal ? full.cardWidth : 0
                Layout.rowSpan: full.stackedSwapStorage ? 2 : 1
                Layout.fillHeight: true
                colors: full.colors
                fontScale: full.fontScale
                contentPadding: full.contentPadding
                info: full.systemInfo
                visibility: full.infoVisibility
            }

            MeterRow {
                id: cpuCard
                Layout.alignment: Qt.AlignTop
                visible: full.showCpu
                Layout.fillWidth: true
                Layout.minimumWidth: full.horizontal ? full.cardWidth : 0
                Layout.rowSpan: full.stackedSwapStorage ? 2 : 1
                Layout.fillHeight: true
                colors: full.colors
                fontScale: full.fontScale
                contentPadding: full.contentPadding
                tempFontScale: full.tempFontScale
                label: i18n("CPU")
                detail: Format.frequency(full.cpuFrequency)
                    + (full.cpuCores > 0
                       ? " · " + i18np("%1 core", "%1 cores", full.cpuCores)
                       : "")
                usage: full.cpuUsage
                temperature: full.cpuTemperature
                history: full.cpuHistory
            }

            MeterRow {
                id: gpuCard
                Layout.alignment: Qt.AlignTop
                visible: full.showGpu
                Layout.fillWidth: true
                Layout.minimumWidth: full.horizontal ? full.cardWidth : 0
                Layout.rowSpan: full.stackedSwapStorage ? 2 : 1
                Layout.fillHeight: true
                colors: full.colors
                fontScale: full.fontScale
                contentPadding: full.contentPadding
                tempFontScale: full.tempFontScale
                label: i18n("GPU")
                detail: Format.memory(full.gpuUsedVram) + " / " + Format.memory(full.gpuTotalVram)
                usage: full.gpuUsage
                temperature: full.gpuTemperature
                history: full.gpuHistory
            }

            MeterRow {
                id: ramCard
                Layout.alignment: Qt.AlignTop
                visible: full.showRam
                Layout.fillWidth: true
                Layout.minimumWidth: full.horizontal ? full.cardWidth : 0
                Layout.rowSpan: full.stackedSwapStorage ? 2 : 1
                Layout.fillHeight: true
                colors: full.colors
                fontScale: full.fontScale
                contentPadding: full.contentPadding
                label: i18n("RAM")
                detail: Format.memory(full.memoryUsed) + " / " + Format.memory(full.memoryTotal)
                usage: full.memoryPercent
                history: full.memoryHistory
            }

            SwapCard {
                id: swapCard
                Layout.alignment: Qt.AlignTop
                visible: full.showSwap
                Layout.fillWidth: true
                Layout.minimumWidth: full.horizontal ? full.cardWidth : 0
                Layout.fillHeight: true
                colors: full.colors
                fontScale: full.fontScale
                contentPadding: full.contentPadding
                used: full.swapUsed
                total: full.swapTotal
                percent: full.swapPercent
            }

            StorageCard {
                id: storageCard
                Layout.alignment: Qt.AlignTop
                visible: full.showStorage
                Layout.fillWidth: true
                Layout.minimumWidth: full.horizontal ? full.cardWidth : 0
                Layout.fillHeight: true
                colors: full.colors
                fontScale: full.fontScale
                contentPadding: full.contentPadding
                tempFontScale: full.tempFontScale
                disks: full.disks
            }
        }
    }
}

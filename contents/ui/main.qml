import QtQuick

import org.kde.ksysguard.sensors as Sensors
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.plasma.plasmoid

import "format.js" as Format

PlasmoidItem {
    id: root

    Plasmoid.title: i18n("Nebula Monitor")
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: Plasmoid.formFactor === PlasmaCore.Types.Planar ? fullRepresentation : null

    ColorScheme {
        id: scheme
        followSystemTheme: Plasmoid.configuration.followSystemTheme
    }

    // ------------------------------------------------------------------ sensors

    Sensors.Sensor {
        id: cpuUsageSensor
        sensorId: "cpu/all/usage"
        updateRateLimit: 1000
        onValueChanged: root.recordSample("cpu", root.cpuUsage)
    }

    Sensors.Sensor {
        id: cpuFrequencySensor
        sensorId: "cpu/all/averageFrequency"
        updateRateLimit: 2000
    }

    Sensors.Sensor {
        id: gpuUsageSensor
        sensorId: "gpu/all/usage"
        updateRateLimit: 1000
        onValueChanged: root.recordSample("gpu", root.gpuUsage)
    }

    Sensors.Sensor {
        id: gpuUsedVramSensor
        sensorId: "gpu/all/usedVram"
        updateRateLimit: 2000
    }

    Sensors.Sensor {
        id: gpuTotalVramSensor
        sensorId: "gpu/all/totalVram"
        updateRateLimit: 60000
    }

    Sensors.Sensor {
        id: memoryUsedSensor
        sensorId: "memory/physical/used"
        updateRateLimit: 2000
        onValueChanged: root.recordSample("memory", root.memoryPercent)
    }

    Sensors.Sensor {
        id: memoryTotalSensor
        sensorId: "memory/physical/total"
        updateRateLimit: 60000
    }

    Sensors.Sensor {
        id: swapUsedSensor
        sensorId: "memory/swap/used"
        updateRateLimit: 5000
    }

    Sensors.Sensor {
        id: swapTotalSensor
        sensorId: "memory/swap/total"
        updateRateLimit: 60000
    }

    // Only the hottest GPU that reports a temperature is shown. ksystemstats
    // does not offer an aggregate GPU temperature sensor, so probe up to four
    // GPUs and ignore the ones that are absent or report 0.
    Sensors.Sensor {
        id: gpuTemperatureSensor1
        sensorId: "gpu/gpu1/temperature"
        updateRateLimit: 2000
    }
    Sensors.Sensor {
        id: gpuTemperatureSensor2
        sensorId: "gpu/gpu2/temperature"
        updateRateLimit: 2000
    }
    Sensors.Sensor {
        id: gpuTemperatureSensor3
        sensorId: "gpu/gpu3/temperature"
        updateRateLimit: 2000
    }
    Sensors.Sensor {
        id: gpuTemperatureSensor4
        sensorId: "gpu/gpu4/temperature"
        updateRateLimit: 2000
    }

    // ksystemstats reports 0 for the CPU temperature on some CPUs (e.g. AMD
    // Zen with only "Tctl"), so read the hwmon chip directly instead.
    property real cpuTemperature: NaN

    // ------------------------------------------------------------------- values

    function sensorNumber(sensor) {
        const value = sensor.value;
        return (typeof value === "number" && isFinite(value)) ? value : NaN;
    }

    function sensorTemperature(sensor) {
        const value = sensorNumber(sensor);
        return value > 0 ? value : NaN;
    }

    readonly property real cpuUsage: sensorNumber(cpuUsageSensor)
    readonly property real cpuFrequency: sensorNumber(cpuFrequencySensor)

    readonly property real gpuUsage: sensorNumber(gpuUsageSensor)
    readonly property real gpuUsedVram: sensorNumber(gpuUsedVramSensor)
    readonly property real gpuTotalVram: sensorNumber(gpuTotalVramSensor)

    readonly property real memoryUsed: sensorNumber(memoryUsedSensor)
    readonly property real memoryTotal: sensorNumber(memoryTotalSensor)
    readonly property real memoryPercent: memoryTotal > 0 ? memoryUsed / memoryTotal * 100 : NaN

    readonly property real swapUsed: sensorNumber(swapUsedSensor)
    readonly property real swapTotal: sensorNumber(swapTotalSensor)
    readonly property real swapPercent: swapTotal > 0 ? swapUsed / swapTotal * 100 : NaN

    readonly property real gpuTemperature: {
        let hottest = NaN;
        const candidates = [
            sensorTemperature(gpuTemperatureSensor1),
            sensorTemperature(gpuTemperatureSensor2),
            sensorTemperature(gpuTemperatureSensor3),
            sensorTemperature(gpuTemperatureSensor4)
        ];
        for (let i = 0; i < candidates.length; ++i) {
            if (!isFinite(candidates[i])) {
                continue;
            }
            if (isNaN(hottest) || candidates[i] > hottest) {
                hottest = candidates[i];
            }
        }
        return hottest;
    }

    // ------------------------------------------------------- history for charts

    readonly property int sampleCount: 60
    property var samples: ({ cpu: [], gpu: [], memory: [] })

    function recordSample(metric, value) {
        if (!isFinite(value)) {
            return;
        }
        const next = {};
        for (const key in samples) {
            next[key] = samples[key];
        }
        const history = next[metric].slice(Math.max(0, next[metric].length - (sampleCount - 1)));
        history.push(Math.max(0, Math.min(100, value)));
        next[metric] = history;
        samples = next;
    }

    // -------------------------------------------------------- system information

    property var systemInfo: ({})
    property var disks: []

    readonly property string systemInfoScript: {
        const url = Qt.resolvedUrl("../tools/sysinfo.sh").toString();
        return decodeURIComponent(url.replace(/^file:\/\//, ""));
    }

    function applySystemInfo(output) {
        const info = {};
        const diskList = [];
        const lines = output.split("\n");
        for (let i = 0; i < lines.length; ++i) {
            const separator = lines[i].indexOf("=");
            if (separator <= 0) {
                continue;
            }
            const key = lines[i].slice(0, separator);
            const value = lines[i].slice(separator + 1);
            if (key === "disk") {
                const fields = value.split(";");
                if (fields.length >= 5) {
                    diskList.push({
                        name: fields[0],
                        total: Number(fields[1]),
                        used: Number(fields[2]),
                        temperature: Number(fields[3]),
                        health: fields[4]
                    });
                }
            } else {
                info[key] = value;
            }
        }
        systemInfo = info;
        disks = diskList;
    }

    Plasma5Support.DataSource {
        id: systemInfoSource
        engine: "executable"
        connectedSources: []

        onNewData: function (sourceName, data) {
            applySystemInfo(String(data["stdout"] || ""));
            Qt.callLater(function () {
                systemInfoSource.disconnectSource(sourceName);
            });
        }
    }

    Timer {
        interval: 20000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (systemInfoSource.connectedSources.length === 0) {
                systemInfoSource.connectSource("bash \"" + root.systemInfoScript + "\"");
            }
        }
    }

    // --------------------------------------------------------- cpu temperature

    readonly property string temperatureScript: {
        const url = Qt.resolvedUrl("../tools/cputemp.sh").toString();
        return decodeURIComponent(url.replace(/^file:\/\//, ""));
    }

    Plasma5Support.DataSource {
        id: temperatureSource
        engine: "executable"
        connectedSources: []

        onNewData: function (sourceName, data) {
            const value = parseFloat(String(data["stdout"] || "").trim());
            root.cpuTemperature = (isFinite(value) && value > 0) ? value : NaN;
            Qt.callLater(function () {
                temperatureSource.disconnectSource(sourceName);
            });
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true

        onTriggered: {
            if (temperatureSource.connectedSources.length === 0) {
                temperatureSource.connectSource("bash \"" + root.temperatureScript + "\"");
            }
        }
    }

    // ----------------------------------------------------------------- tooltip

    toolTipSubText: [
        i18n("CPU: %1 · %2 · %3", Format.percent(cpuUsage),
             Format.temperature(cpuTemperature), Format.frequency(cpuFrequency)),
        i18n("GPU: %1 · %2 · %3", Format.percent(gpuUsage),
             Format.temperature(gpuTemperature),
             Format.memory(gpuUsedVram) + " / " + Format.memory(gpuTotalVram)),
        i18n("RAM: %1 · %2", Format.percent(memoryPercent),
             Format.memory(memoryUsed) + " / " + Format.memory(memoryTotal))
    ].join("\n")

    // ---------------------------------------------------------- representations

    compactRepresentation: CompactRepresentation {
        colors: scheme
        fontScale: Plasmoid.configuration.fontScale
        tempFontScale: Plasmoid.configuration.tempFontScale ?? 0.7
        cpuUsage: root.cpuUsage
        cpuTemperature: root.cpuTemperature
        gpuUsage: root.gpuUsage
        gpuTemperature: root.gpuTemperature
        memoryPercent: root.memoryPercent
    }

    fullRepresentation: FullRepresentation {
        config: Plasmoid.configuration
        colors: scheme
        fontScale: Plasmoid.configuration.fontScale
        contentPadding: Plasmoid.configuration.padding
        horizontal: Plasmoid.configuration.horizontal
        customWidth: Plasmoid.configuration.customWidth
        configuredWidth: Plasmoid.configuration.width
        backgroundOpacity: Plasmoid.configuration.backgroundOpacity
        showBorder: Plasmoid.configuration.showBorder
        timeFormat: Plasmoid.configuration.timeFormat
        dateFormat: Plasmoid.configuration.dateFormat

        cpuUsage: root.cpuUsage
        cpuTemperature: root.cpuTemperature
        cpuFrequency: root.cpuFrequency
        cpuHistory: root.samples.cpu

        gpuUsage: root.gpuUsage
        gpuTemperature: root.gpuTemperature
        gpuUsedVram: root.gpuUsedVram
        gpuTotalVram: root.gpuTotalVram
        gpuHistory: root.samples.gpu

        memoryPercent: root.memoryPercent
        memoryUsed: root.memoryUsed
        memoryTotal: root.memoryTotal
        memoryHistory: root.samples.memory

        swapUsed: root.swapUsed
        swapTotal: root.swapTotal
        swapPercent: root.swapPercent

        systemInfo: root.systemInfo
        disks: root.disks
    }
}

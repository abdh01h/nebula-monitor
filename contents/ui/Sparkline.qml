import QtQuick
import org.kde.kirigami as Kirigami

// Filled sparkline for a series of percentages (0 - maximum).
Canvas {
    id: chart

    property var values: []
    property real maximum: 100
    property color lineColor: Kirigami.Theme.highlightColor
    property color gridColor: Qt.alpha(Kirigami.Theme.textColor, 0.08)

    onValuesChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        if (!chart.lineColor || !chart.gridColor) {
            return;
        }
        const ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);

        const inset = 1.5;
        const usableHeight = Math.max(0, height - inset * 2);

        // Reference lines at 25, 50 and 75 percent.
        ctx.lineWidth = 1;
        ctx.strokeStyle = chart.gridColor;
        for (let step = 1; step < 4; ++step) {
            const y = inset + usableHeight * (1 - step / 4);
            ctx.beginPath();
            ctx.moveTo(0, y);
            ctx.lineTo(width, y);
            ctx.stroke();
        }

        let samples = values || [];
        if (samples.length === 0) {
            return;
        }
        if (samples.length === 1) {
            samples = [samples[0], samples[0]];
        }

        const stepX = width / (samples.length - 1);
        const yFor = function (sample) {
            const value = Math.max(0, Math.min(chart.maximum, sample));
            return inset + usableHeight * (1 - value / chart.maximum);
        };

        ctx.beginPath();
        ctx.moveTo(0, yFor(samples[0]));
        for (let i = 1; i < samples.length; ++i) {
            ctx.lineTo(i * stepX, yFor(samples[i]));
        }
        ctx.lineTo(width, height);
        ctx.lineTo(0, height);
        ctx.closePath();

        let top = height;
        for (let i = 0; i < samples.length; ++i) {
            top = Math.min(top, yFor(samples[i]));
        }
        const gradient = ctx.createLinearGradient(0, top, 0, height);
        gradient.addColorStop(0, Qt.alpha(chart.lineColor, 0.4));
        gradient.addColorStop(1, Qt.alpha(chart.lineColor, 0.04));
        ctx.fillStyle = gradient;
        ctx.fill();

        ctx.beginPath();
        ctx.moveTo(0, yFor(samples[0]));
        for (let i = 1; i < samples.length; ++i) {
            ctx.lineTo(i * stepX, yFor(samples[i]));
        }
        ctx.strokeStyle = chart.lineColor;
        ctx.lineWidth = 2;
        ctx.lineJoin = "round";
        ctx.lineCap = "round";
        ctx.stroke();

        // Highlight where the series currently ends.
        const lastX = width;
        const lastY = yFor(samples[samples.length - 1]);
        ctx.beginPath();
        ctx.arc(lastX - 2, lastY, 4, 0, Math.PI * 2);
        ctx.fillStyle = Qt.alpha(chart.lineColor, 0.25);
        ctx.fill();
        ctx.beginPath();
        ctx.arc(lastX - 2, lastY, 2, 0, Math.PI * 2);
        ctx.fillStyle = chart.lineColor;
        ctx.fill();
    }
}

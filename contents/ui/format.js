.pragma library

function percent(value) {
    return (isFinite(value) && value >= 0) ? Math.round(value) + "%" : "\u2014";
}

function temperature(value) {
    return (isFinite(value) && value > 0) ? Math.round(value) + " °C" : "\u2014";
}

function memory(bytes) {
    if (!isFinite(bytes)) {
        return "\u2014";
    }
    if (bytes <= 0) {
        return "0 B";
    }
    if (bytes >= 9.995e11) {
        return (bytes / 1e12).toFixed(1) + " TB";
    }
    if (bytes >= 1e9) {
        return (bytes / 1e9).toFixed(1) + " GB";
    }
    return Math.max(1, Math.round(bytes / 1e6)) + " MB";
}

// Drive models often carry a redundant "SSD"/"HDD" token; drop it for display.
function diskName(name) {
    if (name === undefined || name === null) {
        return "\u2014";
    }
    return String(name).replace(/\b(SSD|HDD)\b\s*/g, "").trim();
}

function frequency(mhz) {
    if (!isFinite(mhz) || mhz <= 0) {
        return "\u2014";
    }
    if (mhz >= 1000) {
        return (mhz / 1000).toFixed(2) + " GHz";
    }
    return Math.round(mhz) + " MHz";
}

function uptime(seconds) {
    if (!isFinite(seconds) || seconds <= 0) {
        return "\u2014";
    }
    const total = Math.floor(seconds);
    const days = Math.floor(total / 86400);
    const hours = Math.floor((total % 86400) / 3600);
    const minutes = Math.floor((total % 3600) / 60);
    if (days > 0) {
        return days + "d " + hours + "h";
    }
    if (hours > 0) {
        return hours + "h " + minutes + "m";
    }
    return minutes + "m";
}

// 0 = normal, 1 = warm, 2 = hot
function temperatureLevel(value) {
    if (!isFinite(value) || value <= 0) {
        return -1;
    }
    if (value >= 85) {
        return 2;
    }
    return value >= 70 ? 1 : 0;
}

// 0 = comfortable, 1 = high, 2 = full
function usageLevel(value) {
    if (!isFinite(value) || value < 0) {
        return -1;
    }
    if (value >= 90) {
        return 2;
    }
    return value >= 80 ? 1 : 0;
}

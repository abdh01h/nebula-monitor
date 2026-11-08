#!/usr/bin/env bash
# Prints the CPU package temperature in degrees Celsius.
#
# Prefers the hwmon chips used by the CPU drivers (k10temp on AMD, coretemp on
# Intel) and falls back to the ACPI thermal zones. Prints nothing when the
# temperature cannot be determined, which the plasmoid renders as "—".

set -u

# All temp*_input values of a chip are in millidegrees; the hottest one is the
# package temperature.
read_chip() {
    local wanted="$1" hwmon milli
    for hwmon in /sys/class/hwmon/hwmon*; do
        [[ -r "$hwmon/name" && -r "$hwmon" ]] || continue
        [[ "$(<"$hwmon/name")" == "$wanted" ]] || continue
        milli=$(cat "$hwmon"/temp*_input 2>/dev/null | sort -n | tail -n 1)
        if [[ -n "$milli" ]]; then
            printf '%s\n' "$milli"
            return 0
        fi
    done
    return 1
}

read_zone() {
    local wanted="$1" zone milli
    for zone in /sys/class/thermal/thermal_zone*; do
        [[ -r "$zone/type" && -r "$zone/temp" ]] || continue
        [[ "$(<"$zone/type")" == "$wanted" ]] || continue
        milli=$(<"$zone/temp")
        if [[ -n "$milli" ]]; then
            printf '%s\n' "$milli"
            return 0
        fi
    done
    return 1
}

to_celsius() {
    local milli="$1"
    printf '%d.%d\n' "$((milli / 1000))" "$(((milli % 1000) / 100))"
}

for chip in k10temp coretemp zenpower cpu_thermal soc_thermal; do
    if milli=$(read_chip "$chip"); then
        to_celsius "$milli"
        exit 0
    fi
done

for zone in x86_pkg_temp cpu-thermal; do
    if milli=$(read_zone "$zone"); then
        to_celsius "$milli"
        exit 0
    fi
done

exit 0

#!/usr/bin/env bash
# Collects slowly changing system information for the Nebula Monitor plasmoid.
#
# Output format: one "key=value" line per value; "disk=" lines repeat.
# Every value is optional: keys whose data cannot be determined are omitted so
# the widget can hide the corresponding row.

set -u
export LC_ALL=C

emit() { printf '%s\n' "$1=$2"; }

# ------------------------------------------------------------------- system

if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    emit os "${PRETTY_NAME:-Linux}"
else
    emit os "$(uname -s)"
fi

emit host "$(hostname 2>/dev/null || uname -n 2>/dev/null)"

model=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null)
if [[ -z "$model" ]]; then
    model=$(cat /sys/firmware/devicetree/base/model 2>/dev/null | tr -d '\0')
fi
[[ -n "${model:-}" ]] && emit model "$model"

emit kernel "$(uname -r)"
emit arch "$(uname -m)"
emit uptime "$(cut -d. -f1 /proc/uptime 2>/dev/null)"

cores=$(getconf _NPROCESSORS_ONLN 2>/dev/null || nproc 2>/dev/null)
[[ -n "${cores:-}" ]] && emit cores "$cores"

installed_packages() {
    # Check the native database, not just the command: Arch-based systems may
    # have dpkg installed as a dependency while /var/lib/dpkg is absent.
    if command -v pacman >/dev/null 2>&1 && [[ -d /var/lib/pacman ]]; then
        pacman -Q 2>/dev/null | wc -l
    elif command -v dpkg-query >/dev/null 2>&1 && [[ -r /var/lib/dpkg/status ]]; then
        grep -c '^Package:' /var/lib/dpkg/status 2>/dev/null
    elif command -v rpm >/dev/null 2>&1; then
        rpm -qa 2>/dev/null | wc -l
    elif command -v apk >/dev/null 2>&1; then
        apk info 2>/dev/null | wc -l
    fi
}

packages=$(installed_packages)
[[ -n "${packages:-}" ]] && emit packages "$packages"

desktop="${XDG_CURRENT_DESKTOP:-}"
plasma=$(plasmashell --version 2>/dev/null | awk 'NR==1 {print $2}')
if [[ -n "${plasma:-}" ]]; then
    desktop="KDE Plasma $plasma"
fi
[[ -n "$desktop" ]] && emit desktop "$desktop"

[[ -n "${XDG_SESSION_TYPE:-}" ]] && emit session "$XDG_SESSION_TYPE"

# ---------------------------------------------------------- optional packages

if command -v snap >/dev/null 2>&1; then
    snap_count=$(snap list 2>/dev/null | tail -n +2 | wc -l)
    emit snap_packages "$((snap_count))"
fi

if command -v flatpak >/dev/null 2>&1; then
    flatpak_count=$(flatpak list --app --columns=application 2>/dev/null | wc -l)
    emit flatpak_packages "$((flatpak_count))"
fi

# Pending updates are expensive to query, so cache the result for 30 minutes.
pending_updates() {
    if command -v pacman >/dev/null 2>&1 && [[ -d /var/lib/pacman ]]; then
        if command -v checkupdates >/dev/null 2>&1; then
            checkupdates 2>/dev/null | wc -l
        else
            pacman -Qu 2>/dev/null | wc -l
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        apt-get -s -o Debug::NoLocking=1 upgrade 2>/dev/null |
            awk '/^[0-9]+ upgraded/{print $1; exit}'
    elif command -v dnf >/dev/null 2>&1; then
        # Count package lines only. "Obsoleting Packages" and metadata lines
        # start with a word followed by a non-version token; real entries have
        # a version (starting with a digit) after the package name.
        dnf -q check-update 2>/dev/null |
            awk '/^[[:alnum:]][^[:space:]]*[[:space:]]+[0-9]/ {n++} END {print n+0}'
    elif command -v zypper >/dev/null 2>&1; then
        # XML output is stable across openSUSE versions; the plain table has a
        # header/separator whose line count varies with locale and version.
        zypper --xmlout --non-interactive list-updates 2>/dev/null |
            grep -o '<update ' | wc -l
    fi
}

updates_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/nebula-monitor"
updates_cache="$updates_cache_dir/pending-updates"
updates_value=""
if [[ -r "$updates_cache" ]]; then
    read -r updates_stamp updates_value <"$updates_cache"
fi
now=$(date +%s)
if [[ -z "${updates_value:-}" ]] || (( now - ${updates_stamp:-0} >= 1800 )); then
    updates_value=$(pending_updates)
    updates_value=${updates_value//[!0-9]/}
    if [[ -n "$updates_value" ]]; then
        mkdir -p "$updates_cache_dir" 2>/dev/null &&
            printf '%s %s\n' "$now" "$updates_value" >"$updates_cache" 2>/dev/null
    fi
fi
[[ -n "${updates_value:-}" ]] && emit updates "$updates_value"

# ------------------------------------------------------------------ network

wifi=""
wired=""
net_iface=""
if command -v nmcli >/dev/null 2>&1; then
    while IFS=: read -r name type device; do
        case "$type" in
            802-11-wireless)
                wifi="$name"
                net_iface="$device"
                ;;
            802-3-ethernet)
                if [[ -z "$net_iface" ]]; then
                    wired="$name"
                    net_iface="$device"
                fi
                ;;
        esac
    done < <(nmcli -t -f NAME,TYPE,DEVICE connection show --active 2>/dev/null)
fi

if [[ -n "$wifi" ]]; then
    emit linktype wifi
    emit link "$wifi"
elif [[ -n "$wired" ]]; then
    emit linktype ethernet
    emit link "$wired"
fi

if [[ -z "$net_iface" ]] && command -v ip >/dev/null 2>&1; then
    net_iface=$(ip route show default 2>/dev/null | awk 'NR==1 {print $5}')
fi
if [[ -n "$net_iface" ]] && command -v ip >/dev/null 2>&1; then
    address=$(ip -4 -o addr show dev "$net_iface" scope global 2>/dev/null |
        awk 'NR==1 {print $4}' | cut -d/ -f1)
    [[ -n "$address" ]] && emit ip "$address"
fi

vpn=""
if command -v nmcli >/dev/null 2>&1; then
    vpn=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null |
        awk -F: '$2 ~ /^(vpn|wireguard)$/ {print $1; exit}')
fi
if [[ -z "$vpn" ]]; then
    for iface in /sys/class/net/*; do
        case "${iface##*/}" in
            tun*|tap*|wg*|tailscale*|ppp*|nordlynx*)
                vpn="${iface##*/}"
                break
                ;;
        esac
    done
fi
emit vpn "$vpn"

# ------------------------------------------------------------------ storage

declare -A used_bytes=()
declare -A total_bytes=()

while read -r source size used _target; do
    [[ "$source" == /dev/* ]] || continue
    dev=${source#/dev/}
    if [[ "$dev" =~ ^(nvme[0-9]+n[0-9]+)(p[0-9]+)?$ ]]; then
        base=${BASH_REMATCH[1]}
    elif [[ "$dev" =~ ^((sd|vd|hd)[a-z]+)[0-9]*$ ]]; then
        base=${BASH_REMATCH[1]}
    elif [[ "$dev" =~ ^(mmcblk[0-9]+)(p[0-9]+)?$ ]]; then
        base=${BASH_REMATCH[1]}
    else
        base="$dev"
    fi
    used_bytes[$base]=$(( ${used_bytes[$base]:-0} + used ))
    total_bytes[$base]=$(( ${total_bytes[$base]:-0} + size ))
done < <(df -B1 --output=source,size,used,target 2>/dev/null | tail -n +2)

to_celsius() {
    local kelvin="$1"
    if [[ "$kelvin" =~ ^[0-9]+$ ]] && (( kelvin > 273 )); then
        printf '%d' "$(( kelvin - 273 ))"
    fi
}

# SMART data is read through UDisks2, which needs no root for these properties.
smart_data() {
    local base="$1" drive kelvin warnings failing
    command -v udisksctl >/dev/null 2>&1 || { printf ' \n'; return 0; }
    command -v busctl >/dev/null 2>&1 || { printf ' \n'; return 0; }

    drive=$(udisksctl info -b "/dev/$base" 2>/dev/null |
        sed -n 's/^[[:space:]]*Drive:[[:space:]]*//p' | tr -d "'")
    [[ -n "$drive" ]] || { printf ' \n'; return 0; }

    kelvin=$(busctl get-property org.freedesktop.UDisks2 "$drive" \
        org.freedesktop.UDisks2.NVMe.Controller SmartTemperature 2>/dev/null |
        awk '{print $2}')
    if [[ -n "$kelvin" ]]; then
        warnings=$(busctl get-property org.freedesktop.UDisks2 "$drive" \
            org.freedesktop.UDisks2.NVMe.Controller SmartCriticalWarning 2>/dev/null |
            awk '{print $2}')
        if [[ "${warnings:-0}" == "0" ]]; then
            printf '%s OK\n' "$(to_celsius "$kelvin")"
        else
            printf '%s Warning\n' "$(to_celsius "$kelvin")"
        fi
        return 0
    fi

    kelvin=$(busctl get-property org.freedesktop.UDisks2 "$drive" \
        org.freedesktop.UDisks2.Drive.Ata SmartTemperature 2>/dev/null |
        awk '{print $2}')
    if [[ -n "$kelvin" ]]; then
        kelvin=${kelvin%%.*}
        failing=$(busctl get-property org.freedesktop.UDisks2 "$drive" \
            org.freedesktop.UDisks2.Drive.Ata SmartFailing 2>/dev/null |
            awk '{print $2}')
        case "$failing" in
            false) printf '%s OK\n' "$(to_celsius "$kelvin")" ;;
            true) printf '%s Fail\n' "$(to_celsius "$kelvin")" ;;
            *) printf '%s \n' "$(to_celsius "$kelvin")" ;;
        esac
        return 0
    fi

    printf ' \n'
}

command -v lsblk >/dev/null 2>&1 || exit 0
while read -r name model; do
    [[ "$name" =~ ^(nvme[0-9]+n[0-9]+|sd[a-z]+|vd[a-z]+|hd[a-z]+|mmcblk[0-9]+)$ ]] || continue
    total=${total_bytes[$name]:-0}
    (( total > 0 )) || continue
    used=${used_bytes[$name]:-0}
    read -r temperature health < <(smart_data "$name")
    emit disk "${model:-$name};$total;$used;${temperature:-};${health:-}"
done < <(lsblk -dno NAME,MODEL 2>/dev/null)

exit 0

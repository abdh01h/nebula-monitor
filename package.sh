#!/usr/bin/env bash
# Builds nebula-monitor.plasmoid from this directory.
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v zip >/dev/null 2>&1; then
    echo "error: zip is required to build the package." >&2
    exit 1
fi

rm -f nebula-monitor.plasmoid
zip -r -q nebula-monitor.plasmoid metadata.json contents -x '*.qmlc' '*.jsc' '*/.git/*'
echo "Created $(pwd)/nebula-monitor.plasmoid"

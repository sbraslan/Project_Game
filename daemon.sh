#!/bin/sh
set -u

base_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
python_bin="${PYTHON_BIN:-python3}"
interval="${M2_DAEMON_INTERVAL:-10}"

trap 'exit 0' INT TERM HUP

while :; do
    cd "$base_dir" || exit 1
    "$python_bin" "$base_dir/start.py"
    sleep "$interval"
done

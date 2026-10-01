#!/bin/sh
set -eu

base_dir="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
python_bin="${PYTHON_BIN:-python3}"

exec "$python_bin" "$base_dir/find_map.py" "$@"

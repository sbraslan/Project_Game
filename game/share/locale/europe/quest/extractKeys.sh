#!/bin/sh
set -eu

param=""
if [ "${1:-}" = "-c" ]; then
    param="-c"
fi

sed -n 's/\.\./#/g;s/gameforg[.a-z0-9_]\+/\
(&)\
/gp' ./*.quest 2>/dev/null |
    sed -n 's/(\(gameforge[.a-z0-9_]\+\))/\1/p' |
    sort |
    uniq $param |
    sort -n

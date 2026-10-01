#!/bin/sh
set -u

# Metin2 server automation for FreeBSD 14.x amd64.
# Runtime scripts use Python 3; server sources are built from Project_ServerSRC.

v_base="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
v_mt2f="$v_base"
v_bakf="$v_base/baks"
v_dbf="$v_bakf/db"
v_fsf="$v_bakf/fs"
v_foldername="${M2_GAME_DIR:-game}"
v_localename="${M2_LOCALE:-europe}"
v_bin="${PYTHON_BIN:-python3}"
v_jobs="${BUILD_JOBS:-$(sysctl -n hw.ncpu 2>/dev/null || printf '4')}"

printf_color() {
    color="$1"
    shift
    printf '\033[%sm%s\033[0m\n' "$color" "$*"
}
gecho() { printf_color 32 "$@"; }
recho() { printf_color 31 "$@"; }
yecho() { printf_color 33 "$@"; }
cecho() { printf_color 36 "$@"; }

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        recho "Missing command: $1"
        return 1
    fi
}

detect_server_src() {
    if [ -n "${SERVER_SRC:-}" ] && [ -f "$SERVER_SRC/Makefile" ]; then
        printf '%s\n' "$SERVER_SRC"
        return 0
    fi

    for candidate in \
        "$v_base/../Project_ServerSRC" \
        "$HOME/Project_ServerSRC" \
        "/usr/home/Project_ServerSRC" \
        "$v_base/Source/Srcs/Server"
    do
        if [ -f "$candidate/Makefile" ]; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done
    return 1
}

preflight() {
    arch="$(uname -m)"
    if [ "$arch" != "amd64" ]; then
        recho "Unsupported architecture: $arch (amd64 required)"
        return 1
    fi

    require_cmd "$v_bin" || return 1
    require_cmd gmake || return 1

    if ! "$v_bin" -c 'import sys; raise SystemExit(0 if sys.version_info.major == 3 else 1)'; then
        recho "Python 3 is required."
        return 1
    fi

    src="$(detect_server_src 2>/dev/null || true)"
    if [ -n "$src" ]; then
        gecho "Source: $src"
    else
        yecho "Project_ServerSRC not found. Set SERVER_SRC before source builds."
    fi

    gecho "FreeBSD/amd64 automation preflight OK"
}

run_py() {
    require_cmd "$v_bin" || exit 1
    "$v_bin" "$@"
}

run_backup_make() {
    dir="$1"
    target="$2"
    if [ ! -d "$dir" ]; then
        recho "Backup directory not found: $dir"
        return 1
    fi
    make -C "$dir" "$target"
}

build_source() {
    target="$1"
    require_cmd gmake || return 1

    src="$(detect_server_src)" || {
        recho "Project_ServerSRC not found. Set SERVER_SRC=/path/to/Project_ServerSRC"
        return 1
    }

    if [ "$(uname -m)" != "amd64" ]; then
        recho "Source build blocked: amd64 is required."
        return 1
    fi

    deploy_dir="$v_base/$v_foldername/share/bin"
    mkdir -p "$deploy_dir"

    gecho "Building x64 source: $src"
    gecho "Deploy directory: $deploy_dir"
    gmake -C "$src" -j"$v_jobs" DEPLOYDIR="$deploy_dir" "$target"
}

start_daemon() {
    pidfile="$v_base/.daemon.pid"
    if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
        yecho "Daemon already running (PID $(cat "$pidfile"))"
        return 0
    fi

    cd "$v_mt2f" || return 1
    PYTHON_BIN="$v_bin" nohup sh "$v_base/daemon.sh" >/dev/null 2>&1 &
    echo $! > "$pidfile"
    cd "$v_base" || return 1
    gecho "Daemon started (PID $(cat "$pidfile"))"
}

stop_daemon() {
    pidfile="$v_base/.daemon.pid"
    if [ -f "$pidfile" ]; then
        pid="$(cat "$pidfile")"
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
        fi
        rm -f "$pidfile"
    fi
}

recho ".:. Metin2 AdminPanel x64 .:."
gecho "FreeBSD 14.x amd64 / Python 3 automation"
printf '%s\n' "1. Start (start)
1i. Start Interactive (starti)
1a. Start + Daemon (startall)
2. Stop (stop|close)
2i. Stop Interactive (stopi|closei)
2a. Stop + Daemon (stopall|closeall)
3. Clean runtime logs (clean|clear)
33. Clean logs + backups (cleanall|clearall)
4. Backup mysql/db (bak1|db|db_backup)
5. Backup game/fs (bak2|fs|fs_backup)
666. Generate server structure (gen)
777. Compile quests (quest)
888. Full x64 source build + deploy (src)
889. Fast x64 source build + deploy (srcfast)
890. x64 environment check (check)
999. Search CONFIG ports (search)
0. Quit (quit)"

if [ "$#" -eq 0 ]; then
    read -r phase
else
    phase="$1"
fi

case "$phase" in
1|start)
    cd "$v_mt2f" || exit 1
    run_py "$v_base/start.py"
    ;;
1i|starti)
    cd "$v_mt2f" || exit 1
    run_py "$v_base/start.py" --prompt
    ;;
1a|startall)
    start_daemon
    ;;
2|stop|close)
    cd "$v_mt2f" || exit 1
    run_py "$v_base/stop.py"
    ;;
2i|stopi|closei)
    cd "$v_mt2f" || exit 1
    run_py "$v_base/stop.py" --prompt
    ;;
2a|stopall|closeall)
    stop_daemon
    cd "$v_mt2f" || exit 1
    run_py "$v_base/stop.py"
    ;;
3|clean|clear)
    cd "$v_mt2f" || exit 1
    run_py "$v_base/clear.py"
    ;;
33|cleanall|clearall)
    cd "$v_mt2f" || exit 1
    run_py "$v_base/clear.py"
    run_backup_make "$v_dbf" clean || true
    run_backup_make "$v_fsf" clean || true
    ;;
4|bak1|db|db_backup)
    run_backup_make "$v_dbf" dump
    ;;
5|bak2|fs|fs_backup)
    run_backup_make "$v_fsf" dump
    ;;
666|gen)
    cd "$v_mt2f" || exit 1
    run_py "$v_base/gen.py"
    ;;
777|quest)
    quest_dir="$v_mt2f/$v_foldername/share/locale/$v_localename/quest"
    cd "$quest_dir" || exit 1
    chmod u+x qc 2>/dev/null || true
    run_py "$quest_dir/pre_qc.py" -ac
    ;;
888|src)
    build_source all
    ;;
889|srcfast)
    build_source fast
    ;;
890|check)
    preflight
    ;;
999|search)
    find "$v_base/$v_foldername" -name CONFIG -type f -print -exec grep -E '^(PORT|P2P_PORT|DB_PORT|HOSTNAME|CHANNEL):' {} \;
    ;;
0|quit)
    cecho "Bye"
    ;;
*)
    recho "Unknown option: $phase"
    exit 2
    ;;
esac

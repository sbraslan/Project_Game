#!/usr/bin/env python3
"""Start Metin2 DB/auth/channel processes from start.list."""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
import time
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
START_LIST = BASE_DIR / "start.list"


class M2TYPE:
    SERVER, DB, AUTH, CHANFOLDER, CHANNEL, CORE = range(6)
    NOCHAN = 0


def load_processes() -> list[dict]:
    import json

    with START_LIST.open("r", encoding="utf-8") as handle:
        entries = json.load(handle)

    required = {"serv", "path", "chan", "type", "name"}
    for entry in entries:
        missing = required.difference(entry)
        if missing:
            raise RuntimeError(
                f"Invalid start.list entry, missing {sorted(missing)}: {entry}"
            )
    return entries


def process_pids(name: str) -> list[int]:
    result = subprocess.run(
        ["pgrep", "-f", re.escape(name)],
        check=False,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL,
    )
    pids: list[int] = []
    for token in result.stdout.split():
        try:
            pid = int(token)
        except ValueError:
            continue
        if pid != os.getpid():
            pids.append(pid)
    return pids


def should_run(entry: dict, servers: set[str], channels: set[int]) -> bool:
    if servers and entry["serv"] not in servers:
        return False
    if channels and entry["type"] == M2TYPE.CORE and int(entry["chan"]) not in channels:
        return False
    return True


def start_entry(entry: dict, log_level: int, bind_ip: str) -> bool:
    name = entry["name"]
    if process_pids(name):
        print(f"[skip] {name}: already running")
        return False

    cwd = BASE_DIR / entry["path"]
    executable = cwd / name
    if not cwd.is_dir():
        raise RuntimeError(f"Runtime directory does not exist: {cwd}")
    if not executable.exists():
        raise RuntimeError(
            f"Executable link does not exist: {executable}\n"
            "Build/deploy x64 binaries first with: ./admin_panel.sh 888"
        )

    command = [str(executable)]
    if log_level:
        command += ["-l", str(log_level)]
    if bind_ip:
        command += ["-I", bind_ip]

    subprocess.Popen(
        command,
        cwd=str(cwd),
        stdin=subprocess.DEVNULL,
        close_fds=True,
        start_new_session=True,
    )
    print(f"[start] {name}")
    return True


def prompt_selection(entries: list[dict]) -> tuple[set[str], set[int]]:
    servers = sorted({str(e["serv"]) for e in entries})
    print("Servers available:", " ".join(servers))
    raw_servers = input("Servers to start (empty = all): ").strip()
    selected_servers = set(raw_servers.split()) if raw_servers else set()

    available_channels = sorted(
        {int(e["chan"]) for e in entries if e["type"] == M2TYPE.CORE}
    )
    print("Channels available:", " ".join(map(str, available_channels)))
    raw_channels = input("Channels to start (empty = all): ").strip()
    selected_channels = (
        {int(value) for value in raw_channels.split()} if raw_channels else set()
    )
    return selected_servers, selected_channels


def main() -> int:
    parser = argparse.ArgumentParser(description="Start Metin2 server processes")
    parser.add_argument("-p", "--prompt", action="store_true")
    parser.add_argument("-s", "--selective", action="store_true")
    parser.add_argument("-l", "--level", type=int, default=0, help="Game LOG_LEVEL")
    parser.add_argument("-I", "--IP", dest="bind_ip", default="", help="Bind IP")
    parser.add_argument("--whichserv", default="", help="Space-separated server names")
    parser.add_argument("--whichchan", default="", help="Space-separated channel numbers")
    args = parser.parse_args()

    if sys.platform.startswith("freebsd") and os.uname().machine != "amd64":
        raise RuntimeError(f"amd64 required, got {os.uname().machine}")

    entries = load_processes()
    servers = set(args.whichserv.split()) if args.whichserv else set()
    channels = (
        {int(value) for value in args.whichchan.split()} if args.whichchan else set()
    )

    if args.prompt:
        servers, channels = prompt_selection(entries)

    db_entries = [e for e in entries if e["type"] == M2TYPE.DB]
    core_entries = [e for e in entries if e["type"] in (M2TYPE.AUTH, M2TYPE.CORE)]

    started_db = False
    for entry in db_entries:
        if should_run(entry, servers, channels):
            started_db = start_entry(entry, args.level, args.bind_ip) or started_db

    if started_db:
        time.sleep(3)

    for entry in core_entries:
        if should_run(entry, servers, channels):
            if start_entry(entry, args.level, args.bind_ip):
                time.sleep(2)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

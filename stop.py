#!/usr/bin/env python3
"""Gracefully stop Metin2 auth/channel processes, then the DB process."""

from __future__ import annotations

import argparse
import os
import re
import signal
import subprocess
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
        return json.load(handle)


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


def should_stop(entry: dict, servers: set[str], channels: set[int]) -> bool:
    if servers and entry["serv"] not in servers:
        return False
    if channels and entry["type"] == M2TYPE.CORE and int(entry["chan"]) not in channels:
        return False
    return True


def signal_entry(entry: dict, sig: int) -> None:
    pids = process_pids(entry["name"])
    if not pids:
        print(f"[skip] {entry['name']}: not running")
        return

    for pid in pids:
        try:
            os.kill(pid, sig)
            print(f"[signal {sig}] {entry['name']} -> {pid}")
        except ProcessLookupError:
            pass


def wait_for_exit(entries: list[dict], timeout: int) -> list[dict]:
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        remaining = [entry for entry in entries if process_pids(entry["name"])]
        if not remaining:
            return []
        names = ", ".join(entry["name"] for entry in remaining)
        print(f"[wait] {names}")
        time.sleep(3)
    return [entry for entry in entries if process_pids(entry["name"])]


def prompt_selection(entries: list[dict]) -> tuple[set[str], set[int]]:
    servers = sorted({str(e["serv"]) for e in entries})
    print("Servers available:", " ".join(servers))
    raw_servers = input("Servers to stop (empty = all): ").strip()
    selected_servers = set(raw_servers.split()) if raw_servers else set()

    available_channels = sorted(
        {int(e["chan"]) for e in entries if e["type"] == M2TYPE.CORE}
    )
    print("Channels available:", " ".join(map(str, available_channels)))
    raw_channels = input("Channels to stop (empty = all): ").strip()
    selected_channels = (
        {int(value) for value in raw_channels.split()} if raw_channels else set()
    )
    return selected_servers, selected_channels


def main() -> int:
    parser = argparse.ArgumentParser(description="Stop Metin2 server processes")
    parser.add_argument("-p", "--prompt", action="store_true")
    parser.add_argument("-s", "--selective", action="store_true")
    parser.add_argument(
        "-l",
        "--level",
        type=int,
        default=1,
        choices=range(1, 10),
        help="POSIX signal number (default: 1)",
    )
    parser.add_argument("--whichserv", default="", help="Space-separated server names")
    parser.add_argument("--whichchan", default="", help="Space-separated channel numbers")
    parser.add_argument("--timeout", type=int, default=300)
    args = parser.parse_args()

    entries = load_processes()
    servers = set(args.whichserv.split()) if args.whichserv else set()
    channels = (
        {int(value) for value in args.whichchan.split()} if args.whichchan else set()
    )
    if args.prompt:
        servers, channels = prompt_selection(entries)

    selected = [e for e in entries if should_stop(e, servers, channels)]
    cores = [e for e in selected if e["type"] in (M2TYPE.AUTH, M2TYPE.CORE)]
    databases = [e for e in selected if e["type"] == M2TYPE.DB]

    for entry in cores:
        signal_entry(entry, args.level)

    remaining = wait_for_exit(cores, max(args.timeout, 0))
    if remaining and args.level != signal.SIGKILL:
        print("[timeout] forcing remaining game/auth processes down with SIGKILL")
        for entry in remaining:
            signal_entry(entry, signal.SIGKILL)
        wait_for_exit(remaining, 10)

    for entry in databases:
        signal_entry(entry, args.level)
    remaining_db = wait_for_exit(databases, min(max(args.timeout, 0), 60))

    if remaining_db and args.level != signal.SIGKILL:
        print("[timeout] forcing remaining DB processes down with SIGKILL")
        for entry in remaining_db:
            signal_entry(entry, signal.SIGKILL)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

#!/usr/bin/env python3
"""Clean Metin2 runtime logs/core dumps without shell rm pipelines."""

from __future__ import annotations

import json
import shutil
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
RUNTIME_PATTERNS = (
    "p2p_packet_info.txt",
    "packet_info.txt",
    "profile.txt",
    "stdout",
    "syslog",
    "syserr",
    "usage.txt",
    "VERSION.txt",
    "DEV_LOG.log",
    "mob_count",
    "*.core",
)


def load_json(path: Path) -> list[dict]:
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def remove_path(path: Path) -> None:
    if path.is_symlink() or path.is_file():
        path.unlink(missing_ok=True)
    elif path.is_dir():
        shutil.rmtree(path)


def clean_directory(path: Path) -> None:
    if not path.is_dir():
        print(f"[skip] missing: {path}")
        return
    for pattern in RUNTIME_PATTERNS:
        for target in path.glob(pattern):
            remove_path(target)


def clean_log_tree(path: Path) -> None:
    if not path.is_dir():
        return
    pts = path / "PTS"
    pts.touch(exist_ok=True)
    pts.write_text("", encoding="utf-8")
    for child_name in ("log", "cores"):
        child = path / child_name
        if not child.is_dir():
            continue
        for target in child.iterdir():
            remove_path(target)


def main() -> int:
    for entry in load_json(BASE_DIR / "clear.list"):
        clean_log_tree(BASE_DIR / entry["path"])

    for entry in load_json(BASE_DIR / "start.list"):
        path = BASE_DIR / entry["path"]
        print(f"[clean] {path}")
        clean_directory(path)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

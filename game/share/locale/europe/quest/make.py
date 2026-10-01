#!/usr/bin/env python3
"""Legacy quest compiler wrapper, updated for Python 3."""

from __future__ import annotations

import shutil
import subprocess
from pathlib import Path

import pre_qc

BASE_DIR = Path(__file__).resolve().parent


def main() -> int:
    object_dir = BASE_DIR / "object"
    pre_dir = BASE_DIR / "pre_qc"

    if object_dir.exists():
        shutil.rmtree(object_dir)
    object_dir.mkdir()

    pre_dir.mkdir(exist_ok=True)

    compiler = BASE_DIR / "qc_x64"
    if not compiler.exists():
        compiler = BASE_DIR / "qc"
    if not compiler.exists():
        raise RuntimeError("Quest compiler not found (qc_x64 or qc)")

    with (BASE_DIR / "quest_list").open("r", encoding="utf-8") as quest_list:
        for raw_line in quest_list:
            line = raw_line.strip()
            if not line or line.startswith("#") or "--" in line:
                continue

            source = BASE_DIR / line
            generated = pre_qc.run(str(source), str(pre_dir), False)
            filename = pre_dir / source.name if generated else source

            result = subprocess.run([str(compiler), str(filename)], cwd=BASE_DIR)
            if result.returncode != 0:
                print(f"Error occurred while compiling {line}")
                return result.returncode

    for path in object_dir.rglob("*"):
        try:
            path.chmod(0o770)
        except OSError:
            pass
    object_dir.chmod(0o770)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

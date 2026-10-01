#!/usr/bin/env python3
"""Print map bounds and optionally resolve world coordinates to a map."""

from __future__ import annotations

import argparse
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent


def load_maps() -> list[tuple[str, int, int, int, int]]:
    rectangles: list[tuple[str, int, int, int, int]] = []

    with (BASE_DIR / "index").open("r", encoding="utf-8") as index:
        for raw_line in index:
            parts = raw_line.split()
            if len(parts) < 2 or parts[0].startswith("#"):
                continue

            map_name = parts[1]
            setting = BASE_DIR / map_name / "Setting.txt"
            if not setting.is_file():
                continue

            x = y = w = h = None
            with setting.open("r", encoding="utf-8", errors="replace") as handle:
                for line in handle:
                    tokens = line.split()
                    if not tokens:
                        continue
                    if tokens[0] == "BasePosition" and len(tokens) >= 3:
                        x, y = (int(item) // 100 for item in tokens[1:3])
                    elif tokens[0] == "MapSize" and len(tokens) >= 3:
                        w, h = (int(item) * 256 for item in tokens[1:3])

            if None not in (x, y, w, h):
                rectangles.append((map_name, x, y, x + w, y + h))

    return rectangles


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("x", type=int, nargs="?")
    parser.add_argument("y", type=int, nargs="?")
    args = parser.parse_args()

    rectangles = load_maps()
    print(f"{'Map':32} {'X':>8} {'Y':>8} {'Width':>8} {'Height':>8}")
    print("-" * 72)
    for name, x1, y1, x2, y2 in rectangles:
        print(f"{name:32} {x1:8d} {y1:8d} {x2-x1:8d} {y2-y1:8d}")

    if args.x is not None and args.y is not None:
        found = [
            name
            for name, x1, y1, x2, y2 in rectangles
            if x1 <= args.x <= x2 and y1 <= args.y <= y2
        ]
        if found:
            print(f"\nCoordinates are in: {', '.join(found)}")
        else:
            print("\nCoordinates are not on any indexed map")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

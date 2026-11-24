#!/usr/bin/env python3
"""List Lakebase release-note entries newer than this skill's metadata.last-verified date.

Usage:
    python scripts/check_release_notes.py                 # compare against SKILL.md last-verified
    python scripts/check_release_notes.py --since 2026-10-01
    python scripts/check_release_notes.py --cloud aws

Needs internet access to docs.databricks.com and learn.microsoft.com. Uses only the standard library.
How it parses: each entry on these pages is a title followed by a date line such as
"November 19, 2026". The script strips HTML tags to plain lines, finds every line that is only
a date, and treats the closest non-empty line above it as the entry title.
If the page layout changes, no entries will be found. The script then prints a warning and
exits with code 2, so the agent knows to read the page by hand.
"""
from __future__ import annotations

import argparse
import datetime as dt
import html
import re
import sys
import urllib.request
from pathlib import Path

PAGES = {
    "aws": "https://docs.databricks.com/aws/en/release-notes/lakebase/",
    "azure": "https://learn.microsoft.com/en-us/azure/databricks/release-notes/lakebase/",
    "gcp": "https://docs.databricks.com/gcp/en/release-notes/lakebase/",
}
MONTHS = ("January|February|March|April|May|June|July|August|September|October|November|December")
DATE_LINE = re.compile(rf"^\s*({MONTHS})\s+(\d{{1,2}}),\s+(\d{{4}})\s*$")
BLOCK_TAGS = re.compile(r"</?(p|div|h[1-6]|li|ul|ol|br|tr|td|th|section|article|header)[^>]*>", re.I)


def last_verified_from_skill() -> dt.date:
    skill_md = Path(__file__).resolve().parent.parent / "SKILL.md"
    match = re.search(r'last-verified:\s*"?(\d{4}-\d{2}-\d{2})"?', skill_md.read_text(encoding="utf-8"))
    if not match:
        sys.exit("Could not find metadata.last-verified in SKILL.md; pass --since YYYY-MM-DD")
    return dt.date.fromisoformat(match.group(1))


def fetch(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": "lakebase-skill-release-check/0.1"})
    with urllib.request.urlopen(req, timeout=60) as resp:
        return resp.read().decode("utf-8", errors="replace")


def to_lines(page: str) -> list[str]:
    page = re.sub(r"(?is)<(script|style|nav|footer).*?</\1>", " ", page)
    page = BLOCK_TAGS.sub("\n", page)
    page = re.sub(r"<[^>]+>", " ", page)
    zero_width = dict.fromkeys(map(ord, "​‌‍﻿"), None)
    lines = [re.sub(r"\s+", " ", html.unescape(line).translate(zero_width)).strip() for line in page.splitlines()]
    return [line for line in lines if line]


def entries(lines: list[str]) -> list[tuple[dt.date, str]]:
    found = []
    for i, line in enumerate(lines):
        m = DATE_LINE.match(line)
        if not m:
            continue
        date = dt.datetime.strptime(f"{m.group(1)} {m.group(2)} {m.group(3)}", "%B %d %Y").date()
        title = lines[i - 1] if i > 0 else "(no title)"
        found.append((date, title))
    return found


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--since", type=dt.date.fromisoformat, help="YYYY-MM-DD (default: SKILL.md last-verified)")
    parser.add_argument("--cloud", choices=sorted(PAGES), action="append", help="limit to one or more clouds")
    args = parser.parse_args()
    if hasattr(sys.stdout, "reconfigure"):  # avoid UnicodeEncodeError on non-UTF-8 consoles
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    since = args.since or last_verified_from_skill()
    clouds = args.cloud or list(PAGES)

    exit_code = 0
    print(f"Lakebase release notes newer than {since.isoformat()}\n")
    for cloud in clouds:
        url = PAGES[cloud]
        try:
            items = entries(to_lines(fetch(url)))
        except Exception as exc:  # network or HTTP error
            print(f"[{cloud}] ERROR fetching {url}: {exc}\n")
            exit_code = 2
            continue
        if not items:
            print(f"[{cloud}] WARNING: no dated entries parsed from {url}; read it manually.\n")
            exit_code = 2
            continue
        newest = max(d for d, _ in items)
        newer = sorted({(d, t) for d, t in items if d > since}, reverse=True)
        print(f"[{cloud}] {url}")
        print(f"  entries parsed: {len(items)}; newest entry: {newest.isoformat()}")
        if newer:
            exit_code = max(exit_code, 1)
            for d, t in newer:
                print(f"  NEW {d.isoformat()}  {t}")
        else:
            print("  no entries newer than last-verified")
        print()
    if exit_code == 1:
        print("New entries found: re-verify the affected reference files before answering.")
    return exit_code


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""Check local links in the pinned upstream pstack source."""

import re
import sys
from pathlib import Path
from urllib.parse import unquote

SOURCE = Path(__file__).resolve().parent.parent / "plugins" / "pstack" / "source"
LINK = re.compile(r"\]\(([^)]+)\)")


def main():
    missing = []
    for document in SOURCE.rglob("*.md"):
        if "node_modules" in document.parts:
            continue
        for target in LINK.findall(document.read_text(encoding="utf-8")):
            path = unquote(target.split("#", 1)[0])
            if not path.startswith(("./", "../")):
                continue
            if not (document.parent / path).exists():
                missing.append(f"{document.relative_to(SOURCE)}: {target}")
    if missing:
        print("Missing local links in upstream source:", file=sys.stderr)
        print("\n".join(missing), file=sys.stderr)
        return 1
    print("Upstream source links are valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

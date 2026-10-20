#!/usr/bin/env python3
"""Validate the Maestri preset map without changing it."""

import json
import re
import subprocess
import sys
from pathlib import Path


SINGLE_ROLES = {
    "feature, refactoring",
    "bug-fix",
    "perf-issue",
    "hillclimb",
    "hardest tasks",
    "judgment and prose",
    "how explorer",
    "how explainer",
    "why investigators",
    "why synthesizer",
    "reflect tooling",
    "reflect judgment, divergent, synthesizer",
    "swarm workers",
}
PANEL_ROLES = {
    "arena runners",
    "arena cross-judge pool",
    "architect runners",
    "interrogate reviewers",
}


def validate(config, available=None):
    errors = []
    if not isinstance(config, dict) or set(config) != {"families", "roles"}:
        return ["config must contain only families and roles objects"]

    families = config["families"]
    roles = config["roles"]
    if not isinstance(families, dict) or not isinstance(roles, dict):
        return ["families and roles must be objects"]

    expected_roles = SINGLE_ROLES | PANEL_ROLES
    missing = expected_roles - set(roles)
    extra = set(roles) - expected_roles
    if missing:
        errors.append("missing roles: " + ", ".join(sorted(missing)))
    if extra:
        errors.append("unknown roles: " + ", ".join(sorted(extra)))

    for preset, family in families.items():
        if not isinstance(preset, str) or not preset.strip():
            errors.append("preset names must be nonempty strings")
        if not isinstance(family, str) or not re.fullmatch(r"[a-z][a-z0-9-]*", family):
            errors.append(f"{preset!r}: family must be a lowercase label")
        if available is not None and preset not in available:
            errors.append(f"{preset!r}: preset is not available in Maestri")

    def check_seat(role, seat):
        if not isinstance(seat, str) or not seat.strip():
            errors.append(f"{role}: seat must be a preset name or inherit-parent")
        elif seat != "inherit-parent" and seat not in families:
            errors.append(f"{role}: {seat!r} has no family entry")

    for role in SINGLE_ROLES & set(roles):
        check_seat(role, roles[role])
    for role in PANEL_ROLES & set(roles):
        seats = roles[role]
        if not isinstance(seats, list) or not seats:
            errors.append(f"{role}: panel must be a nonempty array")
            continue
        if role != "arena cross-judge pool" and len(seats) < 2:
            errors.append(f"{role}: panel must have at least two seats")
        for seat in seats:
            check_seat(role, seat)
        if role == "interrogate reviewers":
            explicit_families = {
                families[seat]
                for seat in seats
                if isinstance(seat, str) and isinstance(families.get(seat), str)
            }
            if "inherit-parent" in seats or len(explicit_families) < 2:
                errors.append(
                    f"{role}: panel requires explicit presets from at least two distinct families"
                )

    return errors


def available_presets():
    result = subprocess.run(
        ["maestri", "preset", "list"], capture_output=True, text=True, check=True
    )
    return set(re.findall(r'^\s*- "([^"]+)"', result.stdout, re.MULTILINE))


def main():
    if len(sys.argv) not in (2, 3) or (len(sys.argv) == 3 and sys.argv[2] != "--live"):
        print("usage: validate_config.py PATH [--live]", file=sys.stderr)
        return 2
    try:
        config = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
        available = available_presets() if len(sys.argv) == 3 else None
    except (OSError, json.JSONDecodeError, subprocess.CalledProcessError) as error:
        print(error, file=sys.stderr)
        return 2
    errors = validate(config, available)
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    print("Maestri pstack configuration is valid")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

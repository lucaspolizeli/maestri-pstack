#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

bash -n "$repo_dir/scripts/install.sh" "$repo_dir/scripts/check.sh"
python3 -m unittest discover -s "$repo_dir/scripts" -p 'test_*.py'
python3 -m py_compile "$repo_dir/scripts/validate_config.py"

skills_dir=$(mktemp -d)
trap 'rm -rf "$skills_dir"' EXIT
MAESTRI_PSTACK_SKILLS_DIR="$skills_dir" "$repo_dir/scripts/install.sh"
test -f "$skills_dir/maestri-pstack/SKILL.md"
test -f "$skills_dir/maestri-pstack/MAESTRI.md"
test ! -d "$skills_dir/maestri-pstack/skills/poteto-mode/scripts/node_modules"
MAESTRI_PSTACK_SKILLS_DIR="$skills_dir" "$repo_dir/scripts/install.sh"
test -f "$skills_dir/maestri-pstack/SKILL.md"
test -d "$skills_dir"/maestri-pstack.backup.*

cd "$repo_dir/plugins/pstack/skills/poteto-mode/scripts"
bun install --frozen-lockfile
bun run test
bun run typecheck

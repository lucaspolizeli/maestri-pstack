#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
bash -n "$repo_dir/scripts/install.sh" "$repo_dir/scripts/check.sh"
python3 -m unittest discover -s "$repo_dir/scripts" -p 'test_*.py'
python3 -m py_compile "$repo_dir/plugins/pstack/scripts/validate_config.py" "$repo_dir/scripts/check_source_links.py"
python3 "$repo_dir/scripts/check_source_links.py"

test_root=$(mktemp -d)
trap 'rm -rf "$test_root"' EXIT
export MAESTRI_PSTACK_SKILLS_DIR="$test_root/skills"
export MAESTRI_PSTACK_DATA_DIR="$test_root/data/maestri-pstack"
"$repo_dir/scripts/install.sh"
test -f "$MAESTRI_PSTACK_SKILLS_DIR/maestri-pstack/SKILL.md"
test -f "$MAESTRI_PSTACK_DATA_DIR/MAESTRI.md"
test -f "$MAESTRI_PSTACK_DATA_DIR/source/skills/poteto-mode/SKILL.md"
test "$(find "$MAESTRI_PSTACK_SKILLS_DIR/maestri-pstack" -name SKILL.md | wc -l | tr -d ' ')" = 1
test ! -d "$MAESTRI_PSTACK_DATA_DIR/source/skills/poteto-mode/scripts/node_modules"
"$repo_dir/scripts/install.sh"
test -d "$test_root/data/maestri-pstack-backups"/*

cd "$repo_dir/plugins/pstack/source/skills/poteto-mode/scripts"
bun install --frozen-lockfile
bun run test --timeout=15000
bun run typecheck

#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_dir/plugins/pstack"
skills_dir=${MAESTRI_PSTACK_SKILLS_DIR:-"$HOME/.agents/skills"}
data_dir=${MAESTRI_PSTACK_DATA_DIR:-"$HOME/.local/share/maestri-pstack"}
entry="$skills_dir/maestri-pstack"
backup_root="$(dirname "$data_dir")/maestri-pstack-backups/$(date -u +%Y%m%dT%H%M%SZ).$$"

command -v rsync >/dev/null || { echo 'rsync is required' >&2; exit 1; }
mkdir -p "$skills_dir" "$(dirname "$data_dir")"
temp_data=$(mktemp -d "$(dirname "$data_dir")/.maestri-pstack-data.XXXXXX")
temp_entry=$(mktemp -d "$skills_dir/.maestri-pstack-entry.XXXXXX")
cleanup() {
  [[ ! -d "$temp_data" ]] || rm -rf "$temp_data"
  [[ ! -d "$temp_entry" ]] || rm -rf "$temp_entry"
}
trap cleanup EXIT
rsync -a --exclude node_modules --exclude .DS_Store "$source_dir/" "$temp_data/"
cat > "$temp_entry/SKILL.md" <<SKILL
---
name: maestri-pstack
description: Run pstack workflows from a Maestri Maestro terminal, with connected agents and model presets.
---

# Maestri pstack

Read and follow [$data_dir/SKILL.md]($data_dir/SKILL.md). Resolve all paths relative to that package directory.
SKILL

if [[ -e "$entry" || -L "$entry" || -e "$data_dir" || -L "$data_dir" ]]; then
  mkdir -p "$backup_root"
  if [[ -e "$entry" || -L "$entry" ]]; then mv "$entry" "$backup_root/skill"; fi
  if [[ -e "$data_dir" || -L "$data_dir" ]]; then mv "$data_dir" "$backup_root/data"; fi
fi
if ! mv "$temp_data" "$data_dir"; then
  [[ ! -e "$backup_root/data" ]] || mv "$backup_root/data" "$data_dir"
  [[ ! -e "$backup_root/skill" ]] || mv "$backup_root/skill" "$entry"
  exit 1
fi
if ! mv "$temp_entry" "$entry"; then
  rm -rf "$data_dir"
  [[ ! -e "$backup_root/data" ]] || mv "$backup_root/data" "$data_dir"
  [[ ! -e "$backup_root/skill" ]] || mv "$backup_root/skill" "$entry"
  exit 1
fi
trap - EXIT
printf 'Installed skill: %s\nPackage data: %s\n' "$entry" "$data_dir"
[[ ! -d "$backup_root" ]] || printf 'Previous copy: %s\n' "$backup_root"

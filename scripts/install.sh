#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
source_dir="$repo_dir/plugins/pstack"
skills_dir=${MAESTRI_PSTACK_SKILLS_DIR:-"$HOME/.agents/skills"}
destination="$skills_dir/maestri-pstack"

command -v rsync >/dev/null || { echo 'rsync is required' >&2; exit 1; }
mkdir -p "$skills_dir"
temporary=$(mktemp -d "$skills_dir/.maestri-pstack.XXXXXX")
backup=''
cleanup() {
  if [[ -d "$temporary" ]]; then
    rm -rf "$temporary"
  fi
}
trap cleanup EXIT

rsync -a --exclude node_modules --exclude .DS_Store "$source_dir/" "$temporary/"

if [[ -e "$destination" || -L "$destination" ]]; then
  backup="$skills_dir/maestri-pstack.backup.$(date -u +%Y%m%dT%H%M%SZ).$$"
  mv "$destination" "$backup"
fi

if ! mv "$temporary" "$destination"; then
  if [[ -n "$backup" ]]; then
    mv "$backup" "$destination"
  fi
  exit 1
fi
trap - EXIT

echo "Installed $destination"
if [[ -n "$backup" ]]; then
  echo "Previous copy: $backup"
fi

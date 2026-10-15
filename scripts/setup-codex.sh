#!/bin/bash
# 'setup-codex.sh' - link the Codex config and authored agent assets from this
# repo into ~/.codex.
#
# Idempotent. Existing symlinks are replaced. Existing real files and
# directories are moved into ~/.codex_old first, so local state is preserved.

set -eu

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
codex=~/.codex
olddir=~/.codex_old

mkdir -p "$codex" "$codex/skills"

link_path() {
  src="$1"
  dest="$2"
  backup="$3"

  if [ ! -e "$src" ]; then
    echo "skipping $dest: $src does not exist"
    return
  fi

  if [ -L "$dest" ]; then
    echo "replacing existing symlink $dest"
    rm "$dest"
  elif [ -e "$dest" ]; then
    mkdir -p "$(dirname "$backup")"
    echo "backing up existing $dest to $backup"
    mv "$dest" "$backup"
  fi

  ln -s "$src" "$dest"
  echo "linked $dest -> $src"
}

link_path "$repo/codexConfig.toml" "$codex/config.toml" "$olddir/config.toml"
link_path "$repo/agents/output-styles" "$codex/output-styles" "$olddir/output-styles"
link_path "$repo/agents/output-styles/writelikeme.md" "$codex/AGENTS.md" "$olddir/AGENTS.md"

# Codex owns ~/.codex/skills/.system. Link authored skills individually so the
# built-in skills and their update mechanism remain intact. The synced Claude
# plugin tree is generated state and stays ignored by the repository.
for src in "$repo"/agents/skills/*; do
  [ -d "$src" ] || continue
  name="$(basename "$src")"
  [ "$name" = synced ] && continue
  link_path "$src" "$codex/skills/$name" "$olddir/skills/$name"
done

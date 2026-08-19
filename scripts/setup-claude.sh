#!/bin/bash
# 'setup-claude.sh' - link the Claude Code config out of this repo into ~/.claude.
#
# Idempotent. An existing symlink at any target is replaced outright; an existing
# real file or directory is moved into ~/.claude_old first, so nothing that was
# only ever local gets destroyed.

set -eu

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
claude=~/.claude
olddir=~/.claude_old

# source-in-repo:target-in-.claude
links=(
  "agents/skills:skills"
  "agents/output-styles:output-styles"
  "claudeSettings.json:settings.json"
)

mkdir -p "$claude"

for entry in "${links[@]}"; do
  src="$repo/${entry%%:*}"
  dest="$claude/${entry##*:}"

  if [ ! -e "$src" ]; then
    echo "skipping ${entry##*:}: $src does not exist"
    continue
  fi

  if [ -L "$dest" ]; then
    echo "replacing existing symlink $dest"
    rm "$dest"
  elif [ -e "$dest" ]; then
    mkdir -p "$olddir"
    echo "backing up existing $dest to $olddir"
    mv "$dest" "$olddir/"
  fi

  ln -s "$src" "$dest"
  echo "linked $dest -> $src"
done

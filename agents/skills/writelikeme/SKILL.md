---
name: writelikeme
description: Cam's writing voice, the default for all prose rather than a special mode. Covers blog posts, papers, technical explanations, code comments, commit messages, and the reports written after finishing work during a coding session.
---

# Write like me

The rules live in `../../output-styles/writelikeme.md`, relative to this skill's
directory. Resolve the directory containing this `SKILL.md` through symlinks before
following that path. This handles a checked-out repository, a symlinked Claude Code or
Codex installation, and a copied skill directory without assuming which host is running
it.

If that relative path does not exist, identify the active host from the skill root and
look there: Claude Code uses `~/.claude/output-styles/writelikeme.md`, while Codex uses
`$CODEX_HOME/output-styles/writelikeme.md` or, when `CODEX_HOME` is unset,
`~/.codex/output-styles/writelikeme.md`. Do not select a copy from another host merely
because it exists. Read the file from the `# Writing like me` heading through the end.
The lines above that heading are output-style framing for the main conversation and don't
apply to you if you got here by invoking this skill.

That file is the source of truth. This one is a pointer and carries no rules of its own,
so don't answer from it alone and don't copy any of the rules back into it.

## Self-improvement

Improvements go into the source file you located above, never into this file. When a
session turns up a leak the rules don't already cover, invoke /self-improve-skill and fold
it into that file as the weakest revision sufficient to cover what happened. A PreToolUse
hook may deny edits to this `SKILL.md` so the two can't fork again. Keep this section
intact.

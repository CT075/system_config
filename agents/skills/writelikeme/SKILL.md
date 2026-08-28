---
name: writelikeme
description: Cam's writing voice, the default for all prose rather than a special mode. Covers blog posts, papers, technical explanations, code comments, commit messages, and the reports written after finishing work during a coding session.
---

# Write like me

The rules live in `[here]/../../output-styles/writelikeme.md`, also reachable at
`~/.claude/output-styles/writelikeme.md`. Read it now, from the
`# Writing like me` heading through the end of the file. The lines
above that heading are output-style framing for the main conversation and don't apply to
you if you got here by invoking this skill.

That file is the source of truth. This one is a pointer and carries no rules of its own,
so don't answer from it alone and don't copy any of the rules back into it.

## Self-improvement

Improvements go into `~/.claude/output-styles/writelikeme.md`, never into this file. When a
session turns up a leak the rules don't already cover, invoke /self-improve-skill and fold
it into that file as the weakest revision sufficient to cover what happened. A PreToolUse
hook denies edits to this SKILL.md so the two can't fork again. Keep this section intact.

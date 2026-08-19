#!/bin/bash
# 'protect-writelikeme-skill.sh' - PreToolUse hook keeping the writing voice in one file.
#
# The voice lives in agents/output-styles/writelikeme.md. The writelikeme skill is a
# pointer at it. Left unguarded, a /self-improve-skill pass edits whichever of the two is
# in front of it and the pointer grows a copy of the rules, which is how they drifted
# before. Deny writes to the skill and say where they belong instead.
#
# Reads the PreToolUse JSON on stdin, exits 0 either way. A denial is carried by the
# hookSpecificOutput payload, not the exit code, because exit 2 blocks without giving the
# model the redirect.

set -eu

reason='The writelikeme SKILL.md is a pointer, not a source. The voice lives in
~/.claude/output-styles/writelikeme.md and every improvement belongs there. Make the edit
in that file instead. If the pointer itself is genuinely what needs changing, say so and
let the user edit it by hand.'

file_path="$(jq -r '.tool_input.file_path // empty')"

case "$file_path" in
  */skills/writelikeme/SKILL.md)
    jq -n --arg reason "$reason" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: $reason
      }
    }'
    ;;
esac

exit 0

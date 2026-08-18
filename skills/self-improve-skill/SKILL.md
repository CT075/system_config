---
name: self-improve-skill
description: End-of-session improvement pass for a skill that was just used — fold the session's feedback and experience back into the skill as the weakest revisions sufficient to cover what happened (Bennett's Razor, arXiv:2301.12987). Use when a skill's self-improvement section fires, or when asked to fold session learnings into a skill.
---

Fold what this session taught back into the target skill so future sessions
start smarter. The standard for every revision comes from "The Optimal Choice
of Hypothesis Is the Weakest, Not the Shortest" (Bennett, arXiv:2301.12987).

## The razor

Of all hypotheses sufficient to explain the evidence, the *weakest* — the
least specific, the one that rules out the fewest future possibilities — is
the most likely to generalise. Weakness is necessary and sufficient for
generalisation; brevity is neither. A short rule can be wildly overreaching
("all things are blue crabs"), and a longer rule can be appropriately weak.
Bennett's Razor: **explanations should be no more specific than necessary.**

This session is the child task; future sessions are the parent. A revision
overfitted to today's particulars won't transfer. A revision stronger than
the evidence supports will misfire on sessions the evidence says nothing
about.

## Procedure

1. **Collect the evidence.** User corrections and explicit feedback, errors
   and misfires, workarounds discovered, wording that confused — and what
   went smoothly, because successes bound how strong a new rule may be.
2. **Draft one candidate revision per lesson.** Each must be *sufficient*:
   had it been in the skill at session start, the failure would not have
   happened (or the win would have been captured).
3. **Weaken each until it is just sufficient.**
   - Strip session particulars (file names, one-off error text, this
     document's quirks) unless the particular *is* the lesson.
   - Would a less specific version still cover the evidence? Then weaken.
   - Does the rule forbid or mandate anything the session gave no evidence
     about? Then it is too strong.
   - Maximise weakness, not shortness: never compress a rule if compressing
     makes it claim more.
4. **Check against what went well.** A rule that would have blocked a
   successful part of the session is too strong.
5. **Deletion is a revision.** An existing rule that misfired this session
   should itself be weakened or removed; skills accrete strength over time
   and this is the counterweight. If the session adds no transferable
   evidence, leave the target unchanged. A forced rule is stronger than the
   evidence supports.
6. **Apply.** Write the revised text in the user's voice. Prefer targeted
   edits justified by evidence over wholesale rewrites; rewrite fully only
   when the skill has drifted incoherent. Keep the skill's self-improvement
   section (its pointer to this skill) intact, along with any skill-specific
   propagation or invariant notes it carries.
7. **No user in the loop** (subagent or hook runs)? The evidence is the work
   itself — new cases, new patterns, new failure classes. Same razor.

## Self-improvement

This skill applies to itself: every time it is used, revise it by its own
procedure. Keep this section intact.

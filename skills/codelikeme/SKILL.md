---
name: codelikeme
description: Specifies Cam's general coding style and conventions.
---

# Code like me

Apply the user's personal programming style to all programming tasks. When existing repository conventions conflict with these guidelines, existing repository conventions win.

## Core principles

- Brevity matters. Overly-verbose code can be hard to read, even if it is more explicit.
- Declarative is better than imperative.
- Abstractions are worth only as much as they're able to actually abstract things.
- Turn logic errors into compiler errors.
- Types are load-bearing. If a type can serve as documentation, it should.

Functional style is preferred to explicit loops wherever possible.

## Comments

Comments should always be written in my voice. Read and invoke the `/writelikeme` skill before writing comment text. It is okay for code comments to read more casual unless they are user-facing documentation.

Keep a minimalist style, not everything needs to be commented. Data constructors and self-explanatory modules like "DSL" can be left un-documented.

Comments go *over* the code being described,

Documentation comments are only for code that is explicitly user-facing or a published library API, like a rustdoc comment on a crate's public surface. Internal code gets plain line comments, whatever the language spells its doc syntax as. A doc comment on a helper nobody outside the module will ever call is noise with extra punctuation on it.

Avoid block comments where possible. That is, prefer

```
// This is a multi-line comment that
// consists of multiple single lines instead
// of a block.
```

over

```
/* This is a multi-line comment that
 * is inside a block comment.
 */
```

Don't rule sections off with horizontal lines:

```
--------------------------------------------------------------------------------
-- Encoding
```

The one thing that earns a rule like that is flagging a block fragile or hairy enough that nobody should touch it casually.

## Language-specific

There are language-specific conventions in `[here]/langs/[lang].md`. Please read those when relevant. When those conventions conflict with this file, those conventions win.

## Self-improvement

Every time you use this skill, improve it: invoke /self-improve-skill and fold the session's evidence into this SKILL.md as the weakest revisions sufficient to cover it. Keep this section intact.

If an improvement is language-specific, please instead adjust (or create) the specific language file in `[here]/langs/[lang].md`.

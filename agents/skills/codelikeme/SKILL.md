---
name: codelikeme
description: Specifies Cam's general coding style and conventions. Invoke with /codelikeme when writing code.
---

# Code like me

Apply the user's personal programming style to all programming tasks. When existing repository conventions conflict with these guidelines, existing repository conventions win.

The checked-in code is the convention, not the formatter config sitting next to
it. Run a formatter's check before its write: on a repo that already fails that
check, formatting the files you touched rewrites lines you never wrote and the
diff stops being reviewable. Match the code around your change by hand instead,
and take the formatter's shape only for the lines you added.

## Core principles

- Brevity matters. Overly-verbose code can be hard to read, even if it is more explicit.
- Declarative is better than imperative.
- Abstractions are worth only as much as they're able to actually abstract things.
- Turn logic errors into compiler errors.
- Types are load-bearing. If a type can serve as documentation, it should.

Functional style is preferred to explicit loops wherever possible.

## Differential tests need inputs that discriminate

A test that runs a computation and compares it against a reference computation
of the same expression proves nothing when the expression is constant. Both
sides agree, on every input, for the wrong reason. Check that the expected
values actually differ across the inputs, and assert it in the test so a later
edit can't quietly flatten them:

```scala
assert(inputs.map(reference).distinct.length == 2)
```

## Comments

Comments should always be written in my voice. Read and invoke the `/writelikeme` skill before writing comment text. It is okay for code comments to read more casual unless they are user-facing documentation.

Keep a minimalist style, not everything needs to be commented. Data constructors and self-explanatory modules like "DSL" can be left un-documented.

Before writing one, ask what it says that the signature, the name, the export list and the code itself don't. Types are load-bearing here too, so a comment that reads the type back is a second copy of it. This one got deleted:

```haskell
-- Check every raw in [specs] and index the ones that survive. Failures are
-- recorded in the Logger.
build :: (Logger Errors.T :> es) => [(Location, Raw.T)] -> Eff es T
```

`Logger Errors.T` already says where failures go, and `Eff es T` already says nothing aborts. Calibrate to a reader who is semi-familiar with the codebase rather than a newcomer. When a comment isn't pulling its weight, the answer is usually to delete it rather than to shorten it.

What earns the space is the connection between this code and the policy it serves:

```haskell
-- Derived from `builtins` to ensure there is no drift.
reservedSymbols :: Set Text
reservedSymbols = Map.keysSet builtins <> assemblyTime
```

The body shows the derivation. The comment supplies what it is for. Stating the policy on its own is background the reader already has, and stating the mechanism on its own is the code read back.

The first line is the whole comment for most readers. Put the load-bearing sentence there and let the mechanism and the caveats follow after a blank `--`:

```haskell
-- [total] bytes of [v], most significant first, in units of [unit] bytes.
--
-- Units always come out most significant first, so an instruction's bytes
-- appear in the order its layout names them. [end] decides only the order
-- within a unit, and only [Little] is wanted today.
render :: Endianness -> Int -> Int -> Integer -> Builder
```

Somebody who stops after the first line knows what `render` does. Somebody chasing a byte-order bug keeps reading. A comment that spends its opening on background makes both of them hunt for the sentence they came for. The same ordering holds within one line: rule first, reason second. "-q and -v are mutually exclusive; the last one wins, because that's what `Cli.flag'` does with -qv" would be worse turned around.

Each comment stands on its own. Readers arrive at one from a grep hit or a stack trace, not from the top of the file, so it can't lean on the comment above it and it can't ask the reader to hold something in mind from earlier. Name what is being described instead of pointing at it:

```haskell
-- A comma separates and does nothing else, so there had better be
-- something on the far side of it.
dangling :: Eff es [a]
```

"Same as the case above, but it errors instead" makes the reader go find that case and still have it in hand on the way back. A cross-reference is fine as an extra, never as the payload: carry the sentence that is needed here, then point at where the rest lives.

A module header may be a label rather than a summary. `-- FS-backed Raws loader` is a finished header.

Name an identifier in backticks. Some of my older code spells a cross-reference `[LikeThis]` instead; that form is vestigial, so leave the ones already written and don't add more.

Where the code is unresolved, say so and point forward. "It's a bit of a hack, but allows us to avoid needing to truly think about the semantics of multi-file assembly" beats a principled reason invented after the fact, and "Revisit if someone ever attempts to do this" beats a joke about how nobody ever does. When there is something concrete to do about it, that is a CR.

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

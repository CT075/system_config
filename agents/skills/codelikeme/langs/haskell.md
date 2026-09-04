# codelikeme haskell conventions

This file contains some additional conventions that the user prefers when writing Haskell code.

## fourmolu

The config is checked in. Run it and let it win. Two of its behaviours are worth knowing *before* writing a comment, because both turn a comment into something the style guide says not to write:

- With `haddock-style: multi-line`, any `-- |` running to more than one line is rewritten as a `{- | ... -}` block. Writing `-- |` is how block comments appear in a tree that doesn't want them. Plain `--` on internal code avoids the whole problem.
- A comment line beginning with `*` is read as a Haddock bullet and gets reflowed, blank lines and all. `*emphasis*` mid-sentence survives; at the start of a line it doesn't.

## List comprehensions

I don't like them in Haskell. Prefer the named combinator, which says which of the four things the comprehension was doing:

| instead of | write |
| --- | --- |
| `[f x \| x <- xs]` | `f <$> xs` |
| `[x \| x <- xs, p x]` | `filter p xs` |
| `[y \| Just y <- xs]` | `mapMaybe id xs` |
| `[e \| Left e <- es]` | `lefts es` (and `rights`) |

`[y | Just y <- [m]]`, generating from a singleton to unwrap it, is `foldMap` or `maybe [] pure`.

A comprehension with a guard and no generator at all, `[x | p]`, is one element conditionally. Write the `if`.

This is the same instinct as preferring functional style to explicit loops, pointed at the right target. Note that Python goes the other way; see `python.md`.

## Guards

I don't like them either. A guard chain ending in `otherwise` is an `if`/`else if` chain wearing function-definition syntax, and nothing pins down which side each condition is stated from, so a run of similar checks drifts.

| guard shape | write |
| --- | --- |
| two branches | `if c then a else b` |
| three or more, every condition a plain `Bool` | `MultiWayIf` |
| any condition that is really a pattern match | `case` on the tuple of conditions |

Three or more plain booleans is a `MultiWayIf`. Same conditions in the same order, moved into expression position:

```haskell
utf8Width c =
  if
    | n < 0x80 -> 1
    | n < 0x800 -> 2
    | n < 0x10000 -> 3
    | otherwise -> 4
  where
    n = ord c
```

When a condition is really a pattern match written as a comparison, put the conditions in a tuple and `case` on that. The comparison gets to be the pattern it wanted to be:

```haskell
case (here == out, folder, takeExtension name) of
  (True, _, _) -> pure []
  (_, True, _) -> walk (rel </> name)
  (_, _, ".txt") -> pure [rel </> name]
  _ -> pure []
```

A test that returns a `Maybe` sits in the tuple the same way, which is how a pattern guard gets absorbed:

```haskell
case (Text.stripPrefix "##" stripped, Text.null stripped, indented) of
  (Just d, _, _) -> Just (Doc (Text.strip d))
  (_, True, _) -> Nothing
  (_, _, True) -> Just (Continues l)
  _ -> Just (Starts l)
```

Every branch should fire on `True`, with any negation moved into the tuple, so the reader isn't checking each row for which way round it goes. And the tuple is free: matching `(True, _, _)` forces only the first component, so a later condition still runs only when the earlier ones fail, and case-of-known-constructor deletes the tuple outright at `-O2`.

What earns a guard is fall-through. When no branch matches, control moves to the next equation or the next case alternative, and neither an `if` nor a `case` on conditions does that:

```haskell
takeGame True (arg : rest)
  | any (sameGame name) knownGames = (Just name, rest)
  where
    name = Text.pack arg
takeGame _ rest = (Nothing, rest)
```

Rewriting that means writing `(Nothing, arg : rest)` by hand in an else branch, which restates the second equation and hides that it's the same answer. Leave those alone.

`MultiWayIf` is not on in GHC2021, so a project leaning on this wants it in `default-extensions`.

## Records

With `NoFieldSelectors` and `OverloadedRecordDot`, `expr.field` needs the expression parenthesised whenever it isn't already atomic. `f x .field` parses as composition, `(f x).field` is the projection. If a projection off a call site is getting ugly, that's usually the signal to name the intermediate instead.

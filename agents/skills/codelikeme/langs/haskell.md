# codelikeme haskell conventions

This file contains some additional conventions that the user prefers when writing Haskell code.

## fourmolu

The config is checked in. Run it and let it win. Two of its behaviours are worth knowing *before* writing a comment, because both turn a comment into something the style guide says not to write:

- With `haddock-style: multi-line`, any `-- |` running to more than one line is rewritten as a `{- | ... -}` block. Writing `-- |` is how block comments appear in a tree that doesn't want them. Plain `--` on internal code avoids the whole problem.
- A comment line beginning with `*` is read as a Haddock bullet and gets reflowed, blank lines and all. `*emphasis*` mid-sentence survives; at the start of a line it doesn't.

## Records

With `NoFieldSelectors` and `OverloadedRecordDot`, `expr.field` needs the expression parenthesised whenever it isn't already atomic. `f x .field` parses as composition, `(f x).field` is the projection. If a projection off a call site is getting ugly, that's usually the signal to name the intermediate instead.

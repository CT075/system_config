# codelikeme lean conventions

This file contains some additional conventions that the user prefers when writing Lean 4 code.

## Dot notation sees the type as written

`x.f` resolves against the head constant of `x`'s type *before* unfolding, and an `abbrev` is a head constant. An `abbrev` for a monad therefore gets its own namespace of operations for free, even when it abbreviates another `abbrev` that abbreviates an inductive. A type that reduces all the way down to some `Freer (OpenU …) α` still finds `EffAt.discharge` for `act.discharge u`, as long as the binder was written at the `EffAt` spelling.

Lean picks the receiver by type rather than by position, so put it wherever the call reads best. `discharge (u : Unwrap L l) (m : EffAt L l es α)` gives `act.discharge (omniUnwrap l)`, which reads as discharging that action against that capability.

## Try the term before the tactic

`exact` and `refine` typecheck at default transparency, so they unfold plain `def`s on their own. A goal stated through a definition often closes with the bare term:

    exact congrArg (Freer.impure o) (funext fun v => ih v)

Reaching for `simp only [thatDef, …]` first tends to half-unfold the goal into whatever surface syntax the definition was written in, `do` blocks and `>>=` and the rest, and then you are fighting that instead of the proof. Unfold with `simp only` once the term genuinely fails to typecheck.

## `rw` loses on hypotheses `simp only` handles

When a rewrite reports it cannot find a pattern that is plainly sitting in the goal, look at how the hypothesis prints. A statement quantified over implicit arguments comes back eta-expanded, and one stated over a structure comes back with its projections unreduced:

    (fun {α} {ls} => u₁) ?h { ls := ls, α := x, v₁ := v₁, v₂ := v₂ }.v₁

`rw` matches that syntactically and loses. `simp only [h]` normalises the lemma and the goal first, so it finds the instance. Leaving the hypothesis universally quantified and handing the whole thing to `simp only` is usually less work than instantiating it by hand.

## Build one module at a time through a breaking change

A refactor that changes a shared definition breaks every file downstream of it. Build in import order with `lake build Pkg.Module` rather than the whole target. It also keeps the error list honest: one real error partway through a file makes Lean emit `declaration uses 'sorry'` for everything after it in that same file, and those are cascade, not findings.

## Write the proof by hand before you write the tactic

A tactic that automates a proof shape is worth building only once you know the
shape closes the goal. Write one instance the way the tactic would produce it and
check it compiles first. `lean_run_code` does this against the real project without
touching a file, so it costs a minute.

The payoff is not just confidence. The hand instance *is* the spec: whatever it
needed — a `cases` here, a membership proof there — is exactly the list of things
the tactic has to do, and anything it did not need is something the tactic can skip.
A design settled this way tends to be much smaller than one reasoned out from the
definitions, because reasoning from the definitions does not tell you which
obligations definitional unfolding was going to discharge for free.

## Metaprograms do not inherit `exact`'s transparency

`exact` and `refine` typecheck at default transparency, but the ambient transparency
inside a tactic's `MetaM` code is `reducible`. So `whnf` and `isDefEq` in a
metaprogram will not see through an ordinary `def`, and the same reduction that a
hand-written `refine` performed silently has to be asked for:

    withTransparency .default do
      let hd ← whnf prog

Related, when assembling a term: if a constructor's implicit arguments all appear in
its conclusion, `MVarId.apply` determines them by unifying against the goal. Building
the application positionally with `mkAppOptM` means naming a dozen implicits in order
and re-breaking every time one is reordered, for nothing.

## What a metaprogram reads is not what the goal holds

`whnf` is a lookup. It hands back a reduced copy and leaves the goal exactly as it was,
so a lemma applied afterwards unifies against the *unreduced* term. That is fine when
only one decomposition matches. When more than one does, unification takes the syntactic
one and you get a real but useless derivation instead of an error: reading `f x >>= k`
out of a `whnf` and then applying the bind lemma can split the goal at whatever `>>=`
was written first, several steps earlier. When the reduced form is the one the lemma
should see, `change` the goal to it before applying.

Editing the context moves things too. `MVarId.changeLocalDecl` reverts the hypothesis
and re-introduces it, so the old `FVarId` is dead and the next tactic handed it reports
an unknown free variable. Look the hypothesis up again afterwards rather than reusing
the id you had.

# codelikeme scala conventions

This file contains some additional conventions that the user prefers when writing Scala 3 code.

## Same-name extensions on one wrapper collide after erasure

Two extension methods with the same name on different instantiations of a
generic wrapper erase to the same JVM signature, and the compiler rejects them as
a double definition. If a wrapper is a concrete class rather than an abstract
type member, `Rep[Boolean] => Rep[Boolean]` and `Rep[Int] => Rep[Int]` are one
signature.

`@targetName` is the fix, and it goes on the *newer* of the two so the already
published name stays what callers see in a stack trace:

```scala
@targetName("boolAnd")
def &(rhs: Rep[Boolean]): Rep[Boolean] = unsafeReflect(StrictAnd, lhs, rhs)
```

It has to be repeated on the abstract declaration and on every implementation of
it. A trait that declares the method plain and an implementation that annotates
it are two different members, and the collision comes back at whichever mixin
site brings both instantiations together, which can be a file away from either
of them.

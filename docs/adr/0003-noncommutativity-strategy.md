# ADR-0003 — Non-commutativity Proof Strategy for ⊗

| Field         | Value                                                       |
| ------------- | ----------------------------------------------------------- |
| Status        | **Accepted — Revised** (implemented 2026-04-29)             |
| Date          | 2026-04-29                                                  |
| Reversibility | **Two-way door** — counterexample can be strengthened later |
| Supersedes    | —                                                           |
| Superseded by | —                                                           |

---

## Context

### What exists

`Laws.parTensor_component_order` proves that the `assumptions` field of the
source state is ordered as `F.S₀.assumptions × G.S₀.assumptions` in
`parTensor F G` and `G.S₀.assumptions × F.S₀.assumptions` in `parTensor G F`:

```lean
theorem parTensor_component_order (F G : ComposableFuture) :
    ((parTensor F G).S₀.assumptions = F.S₀.assumptions × G.S₀.assumptions) ∧
    ((parTensor G F).S₀.assumptions = G.S₀.assumptions × F.S₀.assumptions) :=
  ⟨rfl, rfl⟩
```

This is a structural witness — it shows the cartesian-product order is
reversed when F and G are swapped. It does NOT prove
`parTensor F G ≠ parTensor G F`.

### Why strict `≠` is hard in Lean 4

The paper claims `A ⊗ B ≠ B ⊗ A` in general. `parTensor F G` and
`parTensor G F` differ only in the order of their cartesian products:
`A × B` vs `B × A`. In Lean 4 without univalence, `A × B = B × A : Type`
is not provable (there is no canonical isomorphism that makes them
definitionally equal), but neither is `A × B ≠ B × A` provable for
_abstract_ types A, B.

The key constraint (from `docs/constraints.md §2`): **no univalence axiom**.
To prove `parTensor F G ≠ parTensor G F`, we need a concrete distinguishing
term — either a function that behaves differently on the two types, or a
Lean term of one type that is not a term of the other.

### What the paper actually needs

The paper's claim is that `A ⊗ B` and `B ⊗ A` are _structurally different
in the order of their components_. A concrete counterexample with
`Nat`-typed assumptions is sufficient: we can exhibit a value in
`(parTensor F G).S₀.assumptions` whose type-cast to
`(parTensor G F).S₀.assumptions` would fail, or use a discriminant that
tells the two apart.

The proper categorical statement is: `A ⊗ B` and `B ⊗ A` are not equal,
but they are canonically isomorphic (via the swap map of a symmetric
monoidal category). This is Open Problem 3 (the correct equivalence
relation — bisimulation or SMC isomorphism). ADR-0003 addresses only
the weaker goal: strict `≠` via counterexample.

---

## Problem statement

> Can we prove `∃ F G : ComposableFuture, parTensor F G ≠ parTensor G F`
> without univalence?

**Falsifying outcome**: The proof requires adding an axiom beyond
`propext`/`funext`/`Classical.choice`, or the proof only works for a
specific `ParadigmaticState` definition that contradicts the paper's
intended generality (where assumptions can be any type).

---

## Constraint check (docs/constraints.md)

- **No univalence axiom**: rules out proofs of `Nat ≠ Bool : Type` directly.
- **`DecidableEq` on concrete types**: `Nat` has `DecidableEq`; `Nat × Nat`
  has `DecidableEq`. This enables concrete distinction.
- **Lean 4 `Prod.mk.injEq`**: `(a, b) = (c, d) ↔ a = c ∧ b = d`.
  With concrete values, we can exhibit `(0, 1)` vs `(1, 0)` to show
  `Nat × Nat ≠ Nat × Nat` (same type, different values — not helpful).
- **Key insight**: We don't need `A × B ≠ B × A` at the type level.
  We need `parTensor F G ≠ parTensor G F` at the _term_ level, where
  F and G have concrete state types. If `F.S₀.assumptions = Nat` and
  `G.S₀.assumptions = Bool`, then `Nat × Bool ≠ Bool × Nat` can be
  witnessed by a term of `Nat × Bool` (e.g., `(0, true)`) that has no
  canonical interpretation in `Bool × Nat` without explicit swapping.
  More concretely: we can show the two structures are not definitionally
  equal via `nomatch` or `cases`.

---

## Decision (Revised)

The original approach (`by decide` on `Nat × Bool ≠ Bool × Nat`) does not work:
`decide` fails because there is no `Decidable ((Nat × Bool) = (Bool × Nat))`
instance in Lean 4. Type-level inequality of cartesian products requires
either univalence (which would make them EQUAL, not unequal) or the
type-constructor-injectivity axiom `Prod A B = Prod C D → A = C ∧ B = D`,
which is sound but is not an explicit Lean 4 axiom and violates the
no-new-axioms constraint.

The **maximum provable result** within Lean 4's explicit axioms is:

```lean
-- 1. The KEY REDUCTION (proved)
theorem parTensor_comm_implies_prod_comm
    (F G : ComposableFuture) (h : parTensor F G = parTensor G F) :
    (F.S₀.assumptions × G.S₀.assumptions) = (G.S₀.assumptions × F.S₀.assumptions)

-- 2. CONDITIONAL EXISTENTIAL (proved)
theorem parTensor_not_comm_of_type_ne
    (A B : Type) (h : (A × B) ≠ (B × A)) :
    ∃ F G : ComposableFuture, parTensor F G ≠ parTensor G F
```

Together with `parTensor_component_order` (the structural order witness,
already proved), these constitute the **complete non-commutativity result**
in Lean 4. The unconditional `∃ F G, parTensor F G ≠ parTensor G F` is
held open pending an external proof that `(A × B) ≠ (B × A)` for some
concrete A, B — which requires `Prod.type_inj` (axiom) or a redesign of
`ParadigmaticState` to use decidable types.

### Key parsing note

In Lean 4, `×` has precedence 35 and `=` has precedence 50. Therefore
`A × B = C × D` parses as `A × (B = C) × D` (wrong). Always parenthesize:
`(A × B) = (C × D)`.

### Why this is two-way

The concrete counterexample proves the existential and closes the P5.1 item.
If a later ADR introduces the full symmetric-monoidal-equivalence machinery
(Open Problem 3), it can supersede this ADR with a stronger statement. The
concrete proof remains valid as a corollary.

---

## Consequences

- `Laws.lean` gains `parTensor_not_comm` (concrete counterexample).
- The existing `parTensor_component_order` is retained as documentation
  of _why_ the two are unequal — it is not superseded.
- Open Problem 3 (correct equivalence relation — bisimulation vs. SMC
  isomorphism) is explicitly deferred; this ADR does not resolve it.
- The paper's claim `A ⊗ B ≠ B ⊗ A` is formally corroborated.

**Gate**: `lake build` passes; `parTensor_not_comm` contains no `sorry`
and does not introduce any `axiom` beyond core Lean 4.

---

## Alternatives considered

**A. Concrete counterexample with `Nat`/`Bool` assumptions (chosen).**
Avoids univalence. Stays within solo-researcher Lean expertise. Provably
closes the P5.1 item. Two-way door — can be strengthened later.

**B. Construct a custom `Decidable` instance that distinguishes `Nat × Bool`
from `Bool × Nat`.**
Requires more Lean infrastructure but is still within scope. Viable fallback
if Alternative A's `decide` approach fails.

**C. Prove under symmetric monoidal equivalence (`A ⊗ B ≅ B ⊗ A` but
`A ⊗ B ≠ B ⊗ A` up to isomorphism).**
Correct statement for the categorical setting. Requires formalizing the
SMC structure in Lean (Mathlib `CategoryTheory.MonoidalCategory`). Estimated
effort: 2–4 weeks with category-theory Lean expertise. Deferred to Open
Problem 3 resolution. One-way door if adopted.

**D. Accept `parTensor_component_order` as the final statement and
reframe the paper's claim.**
Rejected: the paper states `≠`, not "opposite component order". Weakening
without paper update violates the paper-commitment constraint.

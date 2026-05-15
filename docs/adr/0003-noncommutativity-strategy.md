# ADR-0003 — Non-commutativity Proof Strategy for ⊗

| Field         | Value                                                       |
| ------------- | ----------------------------------------------------------- |
| Status        | **Accepted — Final** (Path 3 chosen 2026-05-15; impl. 2026-05-08) |
| Date          | 2026-05-08                                                  |
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
- **`DecidableEq` on concrete types**: `Nat` has `DecidableEq`; `Bool` has
  `DecidableEq`. This enables comparison of VALUES, not types.
- **`decide` on type equality**: FAILS — there is no `Decidable ((A × B) = (B × A))`
  instance. Lean 4's kernel can check definitional equality but that is not
  accessible as a `Decidable` predicate on `Type`-valued terms.
- **`nomatch` / `cases`**: Work on VALUE-level term constructors, not on
  type equality hypotheses. `h : Nat × Bool = Bool × Nat` is a `Prop`-valued
  term; `nomatch h` does not apply.
- **Cardinality**: `|A × B| = |A| × |B| = |B × A|` — always equal.
  Cardinality never distinguishes `A × B` from `B × A`.
- **`Prod.type_inj` (`Prod A B = Prod C D → A = C ∧ B = D`)**: Sound in all
  standard models (follows from kernel canonicity) but not an explicit Lean 4
  axiom. Adding it would violate the no-new-axioms constraint.
- **Lean 4 precedence trap**: `×` is `infixr:35`, `=` is `infixl:50`.
  `A × B = C × D` parses as `A × (B = C) × D` (wrong). Always write
  `(A × B) = (C × D)`.

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

- `Laws.lean` gains two new theorems:
  - `parTensor_comm_implies_prod_comm` — the key reduction (proved)
  - `parTensor_not_comm_of_type_ne` — the conditional existential (proved)
- The existing `parTensor_component_order` is retained as the structural
  order witness; it is not superseded.
- The unconditional `∃ F G, parTensor F G ≠ parTensor G F` is **held open**:
  it is not proved and not axiomatised. It is a known consequence of
  `parTensor_not_comm_of_type_ne` once `(A × B) ≠ (B × A)` is supplied.
- Open Problem 3 (correct equivalence relation — bisimulation vs. SMC
  isomorphism) is explicitly deferred; this ADR does not resolve it.
- The paper's claim `A ⊗ B ≠ B ⊗ A` is **structurally witnessed** by
  `parTensor_component_order` (the components are in opposite order) but
  **not fully corroborated** as a strict propositional inequality without
  the `Prod.type_inj` axiom.

**Gate**: `lake build` passes; both new theorems contain no `sorry` and
do not introduce any `axiom` beyond core Lean 4.

---

## Alternatives considered (original)

**A. Concrete counterexample with `Nat`/`Bool` assumptions.**
Attempted. Failed: `by decide` does not work (no `Decidable` instance for
type equality); `nomatch`/`cases` do not apply to `Prop`-valued hypotheses.

**B. Custom `Decidable` instance distinguishing `Nat × Bool` from `Bool × Nat`.**
Not viable. `DecidableEq Type` is not defined in Lean 4 and would be unsound.

**C. Symmetric monoidal equivalence (`A ⊗ B ≅ B ⊗ A`).**
Correct categorical statement but requires formalizing `CategoryTheory.MonoidalCategory`.
Deferred to Open Problem 3. One-way door if adopted.

**D. Accept `parTensor_component_order` as the final statement.**
Currently the posture, but documented as partial — not a deliberate weakening.
A future ADR that supplies `Prod.type_inj` (or redesigns `ParadigmaticState`)
can close the gap without superseding this ADR.

## Forward paths to close the gap

**Path 1: Add `axiom Prod.type_inj`.**
The axiom `Prod A B = Prod C D → A = C ∧ B = D` is sound in all standard
models of Lean 4 (it follows from kernel canonicity: distinct closed type
constructor applications have no proof of equality). Adding it as a named
axiom would immediately discharge the conditional hypothesis in
`parTensor_not_comm_of_type_ne` and close P5.1. Cost: one line; risk: none
in practice, but formally violates the no-new-axioms constraint until the
constraint is revised.

**Path 2: Redesign `ParadigmaticState` to use decidable types.**
Replace `assumptions : Type` with `assumptions : Finset String` (or another
decidable type). Then `Nat × Bool` is no longer representable and the
non-commutativity claim becomes a statement about decidable sets, which is
provable. Cost: changes the theory's expressiveness; requires Zenodo v0.2
and a new ADR.

**Path 3: Accept the conditional as the final statement (current posture).**
Document `parTensor_component_order` + `parTensor_not_comm_of_type_ne` as
the complete Lean 4 non-commutativity result, acknowledge the gap in the
paper, and defer the unconditional existential to Open Problem 3. No code
change required.

---

## Resolution (2026-05-15) — Path 3 chosen, P5.2 closed

**Path 3 is adopted as final.** Path 1 is rejected (adding `axiom Prod.type_inj`
violates the standing no-new-axioms constraint, `docs/constraints.md §2`, and
would falsify the "no new axioms" claim in the README/commits); Path 2 is
rejected (a decidable `ParadigmaticState` is a theory change requiring a Zenodo
v0.2 and a supersession ADR). The unconditional
`∃ F G, parTensor F G ≠ parTensor G F` is not merely hard but **independent of
Lean's base theory**: `(A × B) = (B × A)` is unprovable without univalence and
irrefutable without `Prod.type_inj` (the types are equinumerous and every
Lean-definable type invariant is equiv-invariant; `A × B ≃ B × A`).

The decisive strengthening is **OP3 `parTensor_comm_iso`** (in
`Core.Equivalence`): `parTensor` is commutative *up to* full `FutureIso`
(symmetric-monoidal braiding) — the categorically correct statement. Strict
propositional `≠` is the wrong question once commutativity-up-to-iso is proved.
The final Lean-4 non-commutativity result is therefore the triple
`parTensor_component_order` (structural witness) +
`parTensor_comm_implies_prod_comm` / `parTensor_not_comm_of_type_ne`
(conditional existential) + `parTensor_comm_iso` (positive iso result). This
closes **P5.2** as a recorded decision, not an open proof gap. No code change.

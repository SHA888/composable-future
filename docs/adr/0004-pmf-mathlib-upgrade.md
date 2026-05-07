# ADR-0004 — Upgrade Placeholder PMF to Mathlib PMF

| Field         | Value                                                                       |
| ------------- | --------------------------------------------------------------------------- |
| Status        | **Accepted** (implemented 2026-04-29, commit 5fe6c89)                       |
| Date          | 2026-04-29                                                                  |
| Reversibility | **Two-way door** — placeholder can be restored if Mathlib PMF causes issues |
| Supersedes    | —                                                                           |
| Superseded by | —                                                                           |

---

## Context

### What exists

`lean/ComposableFuture/Core/Probabilistic.lean` defines a placeholder
probability monad:

```lean
-- Open Problem 13: replace with Mathlib PMF
def PMF (α : Type) : Type := α          -- identity functor
def PMF.pure {α} (a : α) : PMF α := a
def PMF.bind {α β} (p : PMF α) (f : α → PMF β) : PMF β := f p
```

Because `PMF α = α`, all three monad laws (`pure_bind`, `bind_pure`,
`bind_assoc`) close by `rfl`. The Kleisli category theorems
(`kleisli_left_id`, `kleisli_right_id`, `kleisli_assoc`) follow from them
and also close trivially.

This means the "Kleisli category for probabilistic extension" claim in the
paper (§6) is currently proved over the identity functor — which has a
Kleisli category that is just the category of functions, not of Markov
kernels. The claim about probability distributions is not yet formally
corroborated.

### What the paper claims

The paper states that `τ : S₀ → Dist S₁` as a Markov kernel extends the
theory to a Kleisli category over the probability monad. The paper cites
the connection to Furter et al. (2025). This requires `PMF` to be a genuine
probability monad, not the identity.

### What Mathlib provides

`Mathlib.Probability.ProbabilityMassFunction.Basic` (available in
`v4.30.0-rc1`) provides:

```lean
-- Mathlib PMF
structure PMF (α : Type*) : Type* where ...
-- PMF.pure : α → PMF α   (Dirac delta)
-- PMF.bind : PMF α → (α → PMF β) → PMF β  (Chapman-Kolmogorov)
-- PMF.pure_bind : PMF.bind (PMF.pure a) f = f a
-- PMF.bind_pure : PMF.bind p PMF.pure = p
-- PMF.bind_assoc : PMF.bind (PMF.bind p f) g = PMF.bind p (fun x => PMF.bind (f x) g)
```

All three monad laws are proved in Mathlib. Substituting Mathlib's PMF for
the placeholder directly discharges the three law placeholders.

### Why this matters for Phase 5

The Phase 5 gate is "zero sorry and all non-open theorems proved". The three
`PMF.pure_bind` / `PMF.bind_pure` / `PMF.bind_assoc` theorems in the current
file close by `rfl` (trivially, because `PMF = identity`). After the upgrade,
they will be discharged by Mathlib's proved lemmas instead — the proofs will
be non-trivial and genuine.

---

## Problem statement

> Does replacing the placeholder `PMF` with Mathlib's `PMF` break any
> existing theorem in `Probabilistic.lean`, and do the Kleisli laws still
> hold?

**Falsifying outcome**: After the upgrade, `kleisli_assoc` or the identity
laws require `sorry`, or the `ProbabilisticTrajectory` type becomes
incompatible with the rest of the theory (universe clash, typeclass mismatch).

---

## Constraint check (docs/constraints.md)

- **Mathlib `v4.30.0-rc1`**: `PMF` is in `Mathlib.Probability.ProbabilityMassFunction.Basic`.
  Confirmed present at the pinned rev.
- **Universe**: Mathlib's `PMF (α : Type*)` uses a universe-polymorphic
  `Type*`. The current placeholder uses `Type` (universe 0). `ParadigmaticState.toType`
  produces `Type 0` outputs, so `ProbabilisticTrajectory α β := α → PMF β`
  may need a universe annotation `PMF.{0}`. This is an implementation detail.
- **`PMF.bind_assoc` signature**: Takes `p : PMF α`, `f : α → PMF β`,
  `g : β → PMF γ` — matches `kleisli_assoc`'s arguments exactly.
- **Team constraint**: This is a straightforward substitution within
  solo-researcher expertise. No collaborator required.

---

## Decision

Replace the placeholder `PMF` definition in `Probabilistic.lean` with
Mathlib's `PMF`. Discharge the three monad law placeholders using Mathlib
lemmas. Verify `kleisli_assoc` and identity laws still hold.

### Theorem signatures (public surface — unchanged)

The public theorem signatures do NOT change:

```lean
-- These signatures stay the same; only the proof bodies change
theorem kleisli_left_id {α β : Type} (τ : ProbabilisticTrajectory α β) (a : α) :
    (probId α >=> τ) a = τ a

theorem kleisli_right_id {α β : Type} (τ : ProbabilisticTrajectory α β) (a : α) :
    (τ >=> probId β) a = τ a

theorem kleisli_assoc {α β γ δ : Type}
    (τ₁ : ProbabilisticTrajectory α β) (τ₂ : ProbabilisticTrajectory β γ)
    (τ₃ : ProbabilisticTrajectory γ δ) (a : α) :
    ((τ₁ >=> τ₂) >=> τ₃) a = (τ₁ >=> (τ₂ >=> τ₃)) a
```

### What changes in the proof bodies

```lean
-- Before (placeholder, closes by rfl):
theorem PMF.bind_assoc ... := rfl

-- After (Mathlib, closes by Mathlib lemma):
theorem PMF.bind_assoc (p : PMF α) (f : α → PMF β) (g : β → PMF γ) :
    PMF.bind (PMF.bind p f) g = PMF.bind p (fun x => PMF.bind (f x) g) :=
  PMF.bind_comm p f g   -- or the Mathlib name in v4.30.0-rc1
```

> **Note to implementer**: verify the exact Mathlib lemma names at
> `v4.30.0-rc1`. The names may be `PMF.bind_bind`, `PMF.bind_assoc`, or
> accessed via the `Monad` typeclass. Use `#check PMF.bind_assoc` after
> `import Mathlib.Probability.ProbabilityMassFunction.Basic` to confirm.

### File change scope

Only `lean/ComposableFuture/Core/Probabilistic.lean` changes:

- Remove `def PMF (α : Type) : Type := α` and the three placeholder
  definitions.
- Add `import Mathlib.Probability.ProbabilityMassFunction.Basic`.
- Update `ProbabilisticTrajectory` to use Mathlib `PMF` — check universe
  polymorphism.
- Update `kleisli_left_id`, `kleisli_right_id`, `kleisli_assoc` proof bodies
  to cite Mathlib lemmas.

**Estimated scope**: 20–30 lines in one file.

---

## Consequences

- `kleisli_assoc` and the identity laws are proved over genuine probability
  distributions, not the identity functor.
- The Phase 3 section of the paper is fully corroborated by Lean.
- `detToProb_id` and `detToProb_comp` (functoriality of the Dirac embedding)
  may need universe annotations but their structure does not change.
- `ProbabilisticFuture.well_formed` remains trivially true (Markov kernel
  type encodes the state types).

**Gate**: `lake build` passes; `#check @PMF` shows the Mathlib type, not the
placeholder; `kleisli_assoc` proof term does not contain `rfl` (verifiable
with `#print kleisli_assoc`).

---

## Alternatives considered

**A. Upgrade to Mathlib PMF (chosen).**
Correct, closes the paper's probabilistic claim, within solo-researcher scope.

**B. Keep the placeholder permanently and add a disclaimer.**
Honest but leaves the paper's §6 claim unverified in Lean. Violates the
zero-sorry Phase 5 gate (the placeholder laws close by `rfl` for the wrong
reason — not because PMF satisfies monad laws, but because it is the
identity).

**C. Formalize a minimal PMF locally (without Mathlib).**
Duplicates Mathlib. Adds maintenance burden. Not justified since Mathlib
is already a dependency.

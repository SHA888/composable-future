import Mathlib.Probability.ProbabilityMassFunction.Monad
import ComposableFuture.Core.Future

/-!
# Probabilistic Extension (v0.2 — Mathlib PMF)

This module extends Composable Future with probabilistic trajectories
using Kleisli categories over Mathlib's `PMF` (Probability Mass Function).
This closes Open Problem 13 and addresses the probabilistic extension in
§6 of the paper, connecting to Furter et al. (2025).

## Change from v0.1

v0.1 used a placeholder `PMF α := α` (the identity functor) whose Kleisli
category is just the category of functions. The monad laws closed trivially
by `rfl`, proving nothing about probability distributions.

v0.2 uses Mathlib's `PMF α` — a genuine discrete probability distribution
over `α` whose probabilities (`ℝ≥0∞` values) sum to 1. The Kleisli
category is now the category of **Markov kernels**, with composition
implementing the Chapman-Kolmogorov equation via `tsum`. The monad laws
are discharged by Mathlib's proved lemmas:

- `PMF.pure_bind`: `(pure a).bind f = f a`         (left identity)
- `PMF.bind_pure`: `p.bind pure = p`               (right identity)
- `PMF.bind_bind`: `(p.bind f).bind g = p.bind (fun a => (f a).bind g)` (assoc)

All three are `@[simp]` in Mathlib; the proofs below are therefore
non-trivial (they hold by genuine probability theory, not by definitional
equality of a placeholder).

## Mathematical Foundation

A probabilistic trajectory is a Markov kernel:
```
τ : α → PMF β
```

Kleisli composition implements the Chapman-Kolmogorov equation:
```
(τ₁ >=> τ₂)(a) = bind (τ₁ a) τ₂
                = Σ_b (τ₁ a)(b) · (τ₂ b)(_)
```

## Connection to Furter et al. (2025)

Furter et al. extend symmetric monoidal categories with uncertainty via
Markov kernels. Our `ProbabilisticTrajectory` is exactly their Markov
kernel morphism; `kleisliBind` is their Kleisli composition; `detToProb`
is the deterministic embedding into the Markov category.
-/

namespace ComposableFuture

-- Mathlib's PMF involves ENNReal arithmetic (tsum), which is noncomputable.
-- Wrap all probabilistic definitions in a noncomputable section.
noncomputable section

-- ============================================================
-- P3.2: Probabilistic Trajectory (Markov Kernel)
-- ============================================================

/-- A probabilistic trajectory (Markov kernel) from type α to type β.

  τ : α → PMF β

Maps each source element to a genuine discrete probability distribution
over target elements. Corresponds to:
- Markov kernels in probability theory
- Stochastic matrices (over countable types) in Markov chain theory
- Probabilistic morphisms in Markov categories (Furter et al. 2025)

Uses Mathlib's `PMF` — probabilities are `ℝ≥0∞` values summing to 1. -/
def ProbabilisticTrajectory (α β : Type) : Type := α → PMF β

/-- Lift a ParadigmaticState to its full element type (product of all components).

Used to index ProbabilisticTrajectory over the complete state, not just
one component. Ensures consistency with F = (S₀, τ, S₁, Φ). -/
def ParadigmaticState.toType (S : ParadigmaticState) : Type :=
  S.assumptions × S.constraints × S.infrastructure

-- ============================================================
-- P3.3: Kleisli Category Construction
-- ============================================================

/-- Identity Markov kernel: Dirac delta at the input element.

  probId α a = δ_a  (probability 1 at a, 0 elsewhere)

This is `PMF.pure` from Mathlib. -/
def probId (α : Type) : ProbabilisticTrajectory α α :=
  fun a => PMF.pure a

/-- Kleisli composition of Markov kernels (Chapman-Kolmogorov equation).

  (τ₁ >=> τ₂)(a) = (τ₁ a).bind τ₂
                  = Σ_{b} (τ₁ a)(b) · τ₂(b)

This is the standard Kleisli composition in the category of Markov kernels.
Uses Mathlib's `PMF.bind` which computes the weighted sum via `tsum`. -/
def kleisliBind {α β γ : Type}
    (τ₁ : ProbabilisticTrajectory α β)
    (τ₂ : ProbabilisticTrajectory β γ) :
    ProbabilisticTrajectory α γ :=
  fun a => (τ₁ a).bind τ₂

-- Note: Lean 4 already defines `>=>` as `Fish.kleisli` for any `Monad`.
-- Since `PMF` has a `Monad` instance, the built-in `>=>` works for
-- `ProbabilisticTrajectory` directly. We expose `kleisliBind` as a
-- named definition for use in theorem statements; it equals `Fish.kleisli`.
-- Do NOT define `infixr:55 " >=> " => kleisliBind` — that would create
-- an ambiguity with the built-in operator.

-- ============================================================
-- P3.4: Probabilistic Future Structure
-- ============================================================

/-- Probabilistic composable future with a Markov kernel trajectory.

The trajectory τ is a genuine Markov kernel over the full element type of
each state (`ParadigmaticState.toType`). -/
structure ProbabilisticFuture where
  S₀ : ParadigmaticState
  S₁ : ParadigmaticState
  τ  : ProbabilisticTrajectory S₀.toType S₁.toType

end -- noncomputable section

/-- The affordance set of a probabilistic future: futures reachable from S₁. -/
def ProbabilisticFuture.Φ (F : ProbabilisticFuture) : Set ComposableFuture :=
  AffordanceSet F.S₁

/-- Well-formedness: trivially true — the Markov kernel type encodes S₀/S₁. -/
def ProbabilisticFuture.well_formed (_F : ProbabilisticFuture) : Prop := True

-- ============================================================
-- P3.5: Kleisli Category Laws
-- ============================================================
-- All three laws are proved using Mathlib's @[simp] lemmas on PMF.
-- These are non-trivial proofs: they hold by genuine probability theory
-- (Dirac delta, Chapman-Kolmogorov), not by definitional equality.

/-- Left identity: `id >=> τ = τ` (pointwise).

Proof: `(probId α >=> τ) a = (PMF.pure a).bind τ = τ a` by `PMF.pure_bind`. -/
theorem kleisli_left_id {α β : Type}
    (τ : ProbabilisticTrajectory α β) (a : α) :
    kleisliBind (probId α) τ a = τ a := by
  simp [kleisliBind, probId, PMF.pure_bind]

/-- Right identity: `τ >=> id = τ` (pointwise).

Proof: `(τ >=> probId β) a = (τ a).bind PMF.pure = τ a` by `PMF.bind_pure`. -/
theorem kleisli_right_id {α β : Type}
    (τ : ProbabilisticTrajectory α β) (a : α) :
    kleisliBind τ (probId β) a = τ a := by
  simp only [kleisliBind]         -- reduces to: (τ a).bind (probId β) = τ a
  exact PMF.bind_pure (τ a)       -- probId β = fun a => PMF.pure a, eta-equal to PMF.pure

/-- Associativity: `(τ₁ >=> τ₂) >=> τ₃ = τ₁ >=> (τ₂ >=> τ₃)` (pointwise).

Proof: Chapman-Kolmogorov associativity via `PMF.bind_bind`. -/
theorem kleisli_assoc {α β γ δ : Type}
    (τ₁ : ProbabilisticTrajectory α β)
    (τ₂ : ProbabilisticTrajectory β γ)
    (τ₃ : ProbabilisticTrajectory γ δ)
    (a : α) :
    kleisliBind (kleisliBind τ₁ τ₂) τ₃ a = kleisliBind τ₁ (kleisliBind τ₂ τ₃) a := by
  unfold kleisliBind               -- expand both sides fully
  simp [PMF.bind_bind]             -- apply Chapman-Kolmogorov associativity

-- ============================================================
-- P3.6: Change-of-Base Construction
-- ============================================================

noncomputable section

/-- Embed a deterministic function into a probabilistic trajectory (Dirac delta).

  detToProb f a = δ_{f(a)}  (probability 1 at f(a), 0 elsewhere)

Every deterministic trajectory is a degenerate Markov kernel — the probabilistic
extension is conservative over the deterministic theory. -/
def detToProb {α β : Type} (f : α → β) : ProbabilisticTrajectory α β :=
  fun a => PMF.pure (f a)

end -- noncomputable section

/-- `detToProb` preserves identity: `detToProb id = probId` (pointwise).

Proof: `PMF.pure (id a) = PMF.pure a` by `id` reduction. -/
theorem detToProb_id (α : Type) (a : α) :
    detToProb (id : α → α) a = probId α a := by
  simp [detToProb, probId]

/-- `detToProb` preserves composition: `detToProb (g ∘ f) = detToProb f >=> detToProb g`
(pointwise).

Proof: `PMF.pure (g (f a)) = (PMF.pure (f a)).bind (PMF.pure ∘ g)` by `PMF.pure_bind`.
This shows the Dirac embedding is a functor from `Type` (functions) into the
Kleisli category of Markov kernels. -/
theorem detToProb_comp {α β γ : Type} (f : α → β) (g : β → γ) (a : α) :
    detToProb (g ∘ f) a = kleisliBind (detToProb f) (detToProb g) a := by
  simp [detToProb, kleisliBind, PMF.pure_bind]

end ComposableFuture

import ComposableFuture.Core.Future

/-!
# Probabilistic Extension

This module extends Composable Future with probabilistic trajectories
using Kleisli categories over a probability monad. This addresses the
probabilistic extension in §6 of the paper and connects to Furter et al. (2025).

## Mathematical Foundation

A probabilistic trajectory is a Markov kernel:
```
τ : α → PMF β
```

where `PMF` (Probability Mass Function) represents a discrete probability
distribution (placeholder for Mathlib's `PMF` type).

Kleisli composition implements the Chapman-Kolmogorov equation:
```
(τ₁ >=> τ₂)(a) = bind (τ₁ a) τ₂
```

## Design Note

`ProbabilisticTrajectory` is parameterized over plain `Type` arguments
(not `ParadigmaticState` values directly) because `PMF` requires a `Type`
argument. `ProbabilisticFuture` uses a product of all three state components
(`assumptions × constraints × infrastructure`) to represent a full state element,
consistent with the 4-tuple definition F = (S₀, τ, S₁, Φ).

## Connection to Furter et al. (2025)

Furter et al. extend symmetric monoidal categories with uncertainty via
Markov kernels. Our probabilistic extension uses the same Kleisli category
structure over the probability monad.

The change-of-base construction (`detToProb`) embeds every deterministic
trajectory as a Dirac delta, showing the probabilistic extension is conservative.
-/

namespace ComposableFuture

-- ============================================================
-- P3.1: Probability Monad — Placeholder (Open Problem 13)
-- ============================================================

/-- Probability Mass Function over a plain type α.

Placeholder for Mathlib's `PMF` from
`Mathlib.Probability.ProbabilityMassFunction.Basic`.

A PMF over α assigns a non-negative weight to each element of α summing to 1.

TODO (Open Problem 13): Replace with `import Mathlib.Probability.ProbabilityMassFunction.Basic`
and use `PMF` directly. The three `theorem ... := by sorry` below will then
be discharged by Mathlib's `PMF.pure_bind`, `PMF.bind_pure`, `PMF.bind_assoc`.
-/
def PMF (α : Type) : Type := sorry -- Open Problem 13: replace with Mathlib PMF

/-- Dirac delta: probability 1 at a, 0 elsewhere. -/
def PMF.pure {α : Type} (a : α) : PMF α := sorry

/-- Monadic bind: (bind p f)(b) = Σ_{a} p(a) · f(a)(b) -/
def PMF.bind {α β : Type} (p : PMF α) (f : α → PMF β) : PMF β := sorry

/-- Left identity monad law: bind (pure a) f = f a

Named to match Mathlib: `PMF.pure_bind`.
TODO: discharge with `PMF.pure_bind` once `PMF` is the Mathlib type.
-/
theorem PMF.pure_bind {α β : Type} (a : α) (f : α → PMF β) :
  PMF.bind (PMF.pure a) f = f a := by sorry

/-- Right identity monad law: bind p pure = p

Named to match Mathlib: `PMF.bind_pure`.
TODO: discharge with `PMF.bind_pure` once `PMF` is the Mathlib type.
-/
theorem PMF.bind_pure {α : Type} (p : PMF α) :
  PMF.bind p PMF.pure = p := by sorry

/-- Associativity monad law: bind (bind p f) g = bind p (fun x => bind (f x) g)

Named to match Mathlib: `PMF.bind_comm` / `PMF.bind_assoc`.
TODO: discharge with `PMF.bind_assoc` once `PMF` is the Mathlib type.
-/
theorem PMF.bind_assoc {α β γ : Type} (p : PMF α) (f : α → PMF β) (g : β → PMF γ) :
  PMF.bind (PMF.bind p f) g = PMF.bind p (fun x => PMF.bind (f x) g) := by sorry

-- ============================================================
-- P3.2: Probabilistic Trajectory (Markov Kernel)
-- ============================================================

/-- A probabilistic trajectory (Markov kernel) from type α to type β.

  τ : α → PMF β

Maps each source element to a distribution over target elements.
Corresponds to:
- Markov kernels in probability theory
- Stochastic matrices in Markov chain theory
- Probabilistic morphisms in Markov categories (Furter et al. 2025)
-/
def ProbabilisticTrajectory (α β : Type) : Type := α → PMF β

/-- Lift a ParadigmaticState to its full element type (product of all components).

Used to index ProbabilisticTrajectory over the complete state, not just
one component. Ensures consistency with the full 4-tuple F = (S₀, τ, S₁, Φ).
-/
def ParadigmaticState.toType (S : ParadigmaticState) : Type :=
  S.assumptions × S.constraints × S.infrastructure

-- ============================================================
-- P3.3: Kleisli Category Construction
-- ============================================================

/-- Identity Markov kernel: Dirac delta at the input element. -/
def probId (α : Type) : ProbabilisticTrajectory α α :=
  fun a => PMF.pure a

/-- Kleisli composition of Markov kernels (Chapman-Kolmogorov).

  (τ₁ >=> τ₂)(a) = bind (τ₁ a) τ₂
-/
def kleisliBind {α β γ : Type}
  (τ₁ : ProbabilisticTrajectory α β)
  (τ₂ : ProbabilisticTrajectory β γ) :
  ProbabilisticTrajectory α γ :=
  fun a => PMF.bind (τ₁ a) τ₂

infixr:55 " >=> " => kleisliBind

-- ============================================================
-- P3.4: Probabilistic Future Structure
-- ============================================================

/-- Probabilistic composable future: 4-tuple (S₀, τ, S₁, Φ) with probabilistic τ.

The trajectory τ is a Markov kernel over the full element type of each state
(`ParadigmaticState.toType`), covering assumptions, constraints, and
infrastructure — consistent with the deterministic `Trajectory` structure.
-/
structure ProbabilisticFuture where
  S₀ : ParadigmaticState
  S₁ : ParadigmaticState
  τ  : ProbabilisticTrajectory S₀.toType S₁.toType
  Φ  : AffordanceSet S₁

/-- Well-formedness for probabilistic futures.

Analogous to `ComposableFuture.well_formed` in Future.lean. Currently trivially
satisfied since well-formedness is encoded in the Markov kernel type.
Phase 4 will strengthen this to require Φ to be well-typed over S₁.
-/
def ProbabilisticFuture.well_formed (_F : ProbabilisticFuture) : Prop := True

-- ============================================================
-- P3.5: Category Laws (Kleisli Category)
-- ============================================================

/-- Left identity: id >=> τ = τ (pointwise) -/
theorem kleisli_left_id {α β : Type}
  (τ : ProbabilisticTrajectory α β) (a : α) :
  (probId α >=> τ) a = τ a := by
  simp only [kleisliBind, probId]
  exact PMF.pure_bind a τ

/-- Right identity: τ >=> id = τ (pointwise) -/
theorem kleisli_right_id {α β : Type}
  (τ : ProbabilisticTrajectory α β) (a : α) :
  (τ >=> probId β) a = τ a := by
  simp only [kleisliBind]
  exact PMF.bind_pure (τ a)

/-- Associativity: (τ₁ >=> τ₂) >=> τ₃ = τ₁ >=> (τ₂ >=> τ₃) (pointwise)

Known result: follows from PMF.bind_assoc (monad associativity).
TODO: no sorry once Open Problem 13 is resolved.
-/
theorem kleisli_assoc {α β γ δ : Type}
  (τ₁ : ProbabilisticTrajectory α β)
  (τ₂ : ProbabilisticTrajectory β γ)
  (τ₃ : ProbabilisticTrajectory γ δ)
  (a : α) :
  ((τ₁ >=> τ₂) >=> τ₃) a = (τ₁ >=> (τ₂ >=> τ₃)) a := by
  simp only [kleisliBind]
  exact PMF.bind_assoc (τ₁ a) τ₂ τ₃

-- ============================================================
-- P3.6: Change-of-Base Construction
-- ============================================================

/-- Embed a deterministic function into a probabilistic trajectory (Dirac delta).

  detToProb f a = δ_{f(a)}

Every deterministic trajectory is a special (degenerate) case of a
probabilistic one — the probabilistic extension is conservative.
-/
def detToProb {α β : Type} (f : α → β) : ProbabilisticTrajectory α β :=
  fun a => PMF.pure (f a)

/-- detToProb preserves identity: detToProb id = probId (pointwise) -/
theorem detToProb_id (α : Type) (a : α) :
  detToProb (id : α → α) a = probId α a := by
  simp only [detToProb, probId, id]

/-- detToProb preserves composition: detToProb (g ∘ f) = detToProb f >=> detToProb g (pointwise) -/
theorem detToProb_comp {α β γ : Type} (f : α → β) (g : β → γ) (a : α) :
  detToProb (g ∘ f) a = (detToProb f >=> detToProb g) a := by
  simp only [detToProb, kleisliBind]
  exact (PMF.pure_bind (f a) (fun b => PMF.pure (g b))).symm

end ComposableFuture

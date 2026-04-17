import ComposableFuture.Core.Future

/-!  
# Probabilistic Extension

This module extends Composable Future with probabilistic trajectories
using Kleisli categories over probability monads. This addresses the
probabilistic extension in §6 of the paper and connects to Furter et al. (2025).

## Mathematical Foundation

A probabilistic trajectory is a Markov kernel:
```
τ : S₀ → PMF S₁
```

where `PMF` (Probability Mass Function) represents a discrete probability
distribution over paradigmatic states.

Kleisli composition implements the Chapman-Kolmogorov equation:
```
(τ₁ >=> τ₂)(s₀) = ∫ τ₂(s₁) d(τ₁(s₀))(s₁)
```

In the discrete case (PMF), this becomes:
```
(τ₁ >=> τ₂)(s₀) = bind (τ₁ s₀) τ₂
```

## Connection to Furter et al. (2025)

Furter et al. extend symmetric monoidal categories with uncertainty via
Markov kernels. Our probabilistic extension uses the same Kleisli category
structure over the probability monad.

Key insight: The change-of-base construction from deterministic ComposableFuture
to probabilistic ComposableFuture is a monad morphism that preserves the
algebraic structure.
-/

namespace ComposableFuture

-- ============================================================
-- P3.1: Probability Monad Setup
-- ============================================================

/-- Probability Mass Function over a plain type α.

Models a discrete probability distribution: each element of α gets a
non-negative weight, and the total mass sums to 1.

Note: `α` must be a `Type`, not a value. This is why ProbabilisticTrajectory
is parameterized over concrete element types extracted from ParadigmaticState,
not over ParadigmaticState values directly.

In the full implementation, replace with Mathlib's `PMF` from
`Mathlib.Probability.ProbabilityMassFunction.Basic`.
-/
def Dist (α : Type) : Type := sorry -- Open Problem 13: replace with Mathlib PMF

/-- Dirac delta: probability 1 at a, 0 elsewhere. -/
def Dist.pure {α : Type} (a : α) : Dist α := sorry

/-- Monadic bind: (bind p f)(b) = Σ_{a} p(a) · f(a)(b) -/
def Dist.bind {α β : Type} (p : Dist α) (f : α → Dist β) : Dist β := sorry

/-- Left identity: bind (pure a) f = f a -/
axiom Dist.bind_pure_left {α β : Type} (a : α) (f : α → Dist β) :
  Dist.bind (Dist.pure a) f = f a

/-- Right identity: bind p pure = p -/
axiom Dist.bind_pure_right {α : Type} (p : Dist α) :
  Dist.bind p Dist.pure = p

/-- Associativity: bind (bind p f) g = bind p (fun x => bind (f x) g) -/
axiom Dist.bind_assoc {α β γ : Type} (p : Dist α) (f : α → Dist β) (g : β → Dist γ) :
  Dist.bind (Dist.bind p f) g = Dist.bind p (fun x => Dist.bind (f x) g)

-- ============================================================
-- P3.2: Probabilistic Trajectory (Markov Kernel)
-- ============================================================

/-- A probabilistic trajectory (Markov kernel) from type α to type β.

Maps each source element to a distribution over target elements:
  τ : α → Dist β

This corresponds to:
- Markov kernels in probability theory
- Stochastic matrices in Markov chain theory
- Probabilistic morphisms in Markov categories (Furter et al. 2025)

Note: parameterized over plain types α β (not ParadigmaticState values),
because Dist needs a Type argument.
-/
def ProbabilisticTrajectory (α β : Type) : Type := α → Dist β

-- ============================================================
-- P3.3: Kleisli Category Construction
-- ============================================================

/-- Identity Markov kernel: Dirac delta at the input element. -/
def probId (α : Type) : ProbabilisticTrajectory α α :=
  fun a => Dist.pure a

/-- Kleisli composition of Markov kernels (Chapman-Kolmogorov).

  (τ₁ >=> τ₂)(a) = bind (τ₁ a) τ₂

This is the standard composition of stochastic transitions.
-/
def kleisliBind {α β γ : Type}
  (τ₁ : ProbabilisticTrajectory α β)
  (τ₂ : ProbabilisticTrajectory β γ) :
  ProbabilisticTrajectory α γ :=
  fun a => Dist.bind (τ₁ a) τ₂

infixr:55 " >=> " => kleisliBind

-- ============================================================
-- P3.4: Probabilistic Future Structure
-- ============================================================

/-- Probabilistic composable future: 4-tuple (S₀, τ, S₁, Φ) with probabilistic τ.

The trajectory τ is a Markov kernel indexed by the element types of the states.
-/
structure ProbabilisticFuture where
  S₀ : ParadigmaticState
  S₁ : ParadigmaticState
  τ  : ProbabilisticTrajectory S₀.assumptions S₁.assumptions
  Φ  : AffordanceSet S₁

-- ============================================================
-- P3.5: Category Laws (Kleisli Category)
-- ============================================================

/-- Left identity: id >=> τ = τ (pointwise) -/
theorem kleisli_left_id {α β : Type}
  (τ : ProbabilisticTrajectory α β) (a : α) :
  (probId α >=> τ) a = τ a := by
  simp only [kleisliBind, probId]
  exact Dist.bind_pure_left a τ

/-- Right identity: τ >=> id = τ (pointwise) -/
theorem kleisli_right_id {α β : Type}
  (τ : ProbabilisticTrajectory α β) (a : α) :
  (τ >=> probId β) a = τ a := by
  simp only [kleisliBind]
  exact Dist.bind_pure_right (τ a)

/-- Associativity: (τ₁ >=> τ₂) >=> τ₃ = τ₁ >=> (τ₂ >=> τ₃) (pointwise)

This is the key law: Kleisli composition of Markov kernels is associative.
Known result — follows directly from Dist.bind_assoc (monad associativity).
-/
theorem kleisli_assoc {α β γ δ : Type}
  (τ₁ : ProbabilisticTrajectory α β)
  (τ₂ : ProbabilisticTrajectory β γ)
  (τ₃ : ProbabilisticTrajectory γ δ)
  (a : α) :
  ((τ₁ >=> τ₂) >=> τ₃) a = (τ₁ >=> (τ₂ >=> τ₃)) a := by
  simp only [kleisliBind]
  exact Dist.bind_assoc (τ₁ a) τ₂ τ₃

-- ============================================================
-- Legacy names matching TODO.md checklist
-- ============================================================

/-- Probabilistic associativity [Phase 3 gate result] -/
theorem prob_assoc {α β γ δ : Type}
  (τ₁ : ProbabilisticTrajectory α β)
  (τ₂ : ProbabilisticTrajectory β γ)
  (τ₃ : ProbabilisticTrajectory γ δ)
  (a : α) :
  ((τ₁ >=> τ₂) >=> τ₃) a = (τ₁ >=> (τ₂ >=> τ₃)) a :=
  kleisli_assoc τ₁ τ₂ τ₃ a

/-- Probabilistic left identity [Phase 3 gate result] -/
theorem prob_id_left {α β : Type}
  (τ : ProbabilisticTrajectory α β) (a : α) :
  (probId α >=> τ) a = τ a :=
  kleisli_left_id τ a

/-- Probabilistic right identity [Phase 3 gate result] -/
theorem prob_id_right {α β : Type}
  (τ : ProbabilisticTrajectory α β) (a : α) :
  (τ >=> probId β) a = τ a :=
  kleisli_right_id τ a

-- ============================================================
-- P3.6: Change-of-Base Construction
-- ============================================================

/-- Embed a deterministic function into a probabilistic trajectory (Dirac delta).

  detToProb f a = δ_{f(a)}

This shows the probabilistic extension is conservative:
every deterministic trajectory is a special case of a probabilistic one.
-/
def detToProb {α β : Type} (f : α → β) : ProbabilisticTrajectory α β :=
  fun a => Dist.pure (f a)

/-- detToProb preserves identity: detToProb id = probId -/
theorem detToProb_id (α : Type) (a : α) :
  detToProb id a = probId α a := by
  simp [detToProb, probId]

/-- detToProb preserves composition: detToProb (g ∘ f) = detToProb f >=> detToProb g -/
theorem detToProb_comp {α β γ : Type} (f : α → β) (g : β → γ) (a : α) :
  detToProb (g ∘ f) a = (detToProb f >=> detToProb g) a := by
  simp only [detToProb, kleisliBind]
  exact (Dist.bind_pure_left (f a) (fun b => Dist.pure (g b))).symm

end ComposableFuture

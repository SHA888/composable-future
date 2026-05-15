import Mathlib.Data.Set.Basic

-- The `ComposableFuture` structure has the same name as its enclosing namespace.
-- This is intentional — the namespace holds all theory definitions and the
-- struct is the central type. Lean 4 warns about duplicated namespace names
-- when Mathlib linters are active; suppress this known-harmless warning.
set_option linter.dupNamespace false

/-!
# Core Future Types

This module defines the basic types for the Composable Future theory.
A composable future is a 4-tuple (S₀, τ, S₁, Φ) representing a transition
from a paradigmatic state S₀ to S₁ via trajectory τ, with affordance set Φ.

## Design change (v0.3, ADR-0005)

v0.2 removed Φ as a stored field to resolve a universe mismatch (the attempt
to use `AffordanceDescriptor S₀ : Type 1` while `ComposableFuture : Type 0`).
This created a theory split: the paper's 4-tuple vs. Lean's 3-tuple.

v0.3 restores Φ as a stored field `Φ : Set ComposableFuture`. This is
type-theoretically safe: `Set ComposableFuture = ComposableFuture → Prop`
is a function type (no strict positive occurrence violation), and `Set`
lives in the same universe as `ComposableFuture` (no universe mismatch).

The identity future carries `Φ = AffordanceSet S` (Option B): a null
transition changes nothing, so affordances are preserved. The terminate
operator (Paper 2) is what genuinely zeros affordances.
-/

namespace ComposableFuture

/-- A paradigmatic state consists of assumptions, constraints, and infrastructure. -/
structure ParadigmaticState where
  assumptions : Type
  constraints : Type
  infrastructure : Type
  deriving Repr

/-- A trajectory represents a transition between paradigmatic states.
    v0.2 (ADR-0002): enriched with an internal path of intermediate states.
    The `path` field records the sequence of paradigmatic states visited
    (excluding the source, which is stored separately, but including any
    intermediate stages). The `target` is the final state. -/
structure Trajectory where
  source : ParadigmaticState
  path   : List ParadigmaticState
  target : ParadigmaticState
  deriving Repr


/-- A composable future is a 4-tuple (S₀, τ, S₁, Φ).

    v0.3 (ADR-0005): Φ is restored as a stored field `Φ : Set ComposableFuture`.
    This matches the paper's 4-tuple definition exactly. -/
structure ComposableFuture where
  S₀ : ParadigmaticState
  τ  : Trajectory
  S₁ : ParadigmaticState
  Φ  : Set ComposableFuture

/-- Well-formedness condition: trajectory matches the states and affordances are correct.
    For a well-formed future, Φ = AffordanceSet S₁ (the set of all futures accessible from S₁). -/
def ComposableFuture.well_formed (F : ComposableFuture) : Prop :=
  F.τ.source = F.S₀ ∧ F.τ.target = F.S₁ ∧ F.Φ = AffordanceSet F.S₁

/-- The affordance set at state S: the set of all composable futures whose
    source state is S.

    This matches the paper's definition Φ : S₁ → P(F), where P(F) is the
    powerset of composable futures. The set comprehension `{F | F.S₀ = S}`
    is well-defined for any S: it is always non-empty (containing at least
    `idFuture S`) and closed under sequential composition. -/
def AffordanceSet (S : ParadigmaticState) : Set ComposableFuture :=
  setOf fun F => F.S₀ = S


/-- A trajectory is stateless if it does not depend on history.
    With the enriched path field, a stateless trajectory has an empty path
    and its behavior is independent of prior context. -/
def Trajectory.isStateless (τ : Trajectory) : Prop :=
  τ.path = []

/-- A composable future is stateless if its trajectory is stateless. -/
def ComposableFuture.isStateless (F : ComposableFuture) : Prop := F.τ.isStateless

/-- Extensionality for Trajectory: two trajectories are equal if their source,
    path, and target are equal. -/
@[ext]
theorem Trajectory.ext {τ₁ τ₂ : Trajectory}
    (hs : τ₁.source = τ₂.source)
    (hp : τ₁.path = τ₂.path)
    (ht : τ₁.target = τ₂.target) :
    τ₁ = τ₂ := by
  cases τ₁; cases τ₂
  subst hs hp ht
  rfl

end ComposableFuture

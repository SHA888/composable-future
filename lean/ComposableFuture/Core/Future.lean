import Mathlib.Data.Set.Basic

-- The `ComposableFuture` structure has the same name as its enclosing namespace.
-- This is intentional — the namespace holds all theory definitions and the
-- struct is the central type. Lean 4 warns about duplicated namespace names
-- when Mathlib linters are active; suppress this known-harmless warning.
set_option linter.dupNamespace false

/-!
# Core Future Types

This module defines the basic types for the Composable Future theory.
A composable future is a 3-tuple (S₀, τ, S₁) representing a transition
from a paradigmatic state S₀ to S₁ via trajectory τ. The affordance set
Φ is derived from S₁ rather than stored as a field, matching the paper's
specification Φ : S₁ → P(F) — the set of futures reachable from S₁.

## Design change (v0.2)

v0.1 stored `Φ : AffordanceSet S₁` as a struct field using the placeholder
`AffordanceSet S := Unit` (Type 0). This caused a universe mismatch when
trying to promote Φ to the richer `AffordanceDescriptor` type (Type 1).

v0.2 removes Φ as a stored field and defines it as a derived set:

  AffordanceSet S := {F : ComposableFuture | F.S₀ = S}
  ComposableFuture.Φ F := AffordanceSet F.S₁

This matches the paper's Φ : S₁ → P(F) exactly, eliminates the universe
mismatch (Set ComposableFuture lives in the same universe as ComposableFuture),
and makes the identity laws unconditional (no Subsingleton guard needed).
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


/-- A composable future is a 3-tuple (S₀, τ, S₁).

    v0.2: Φ is no longer a stored field. It is derived as `AffordanceSet F.S₁`
    (see below), matching the paper's Φ : S₁ → P(F). -/
structure ComposableFuture where
  S₀ : ParadigmaticState
  τ  : Trajectory
  S₁ : ParadigmaticState

/-- Well-formedness condition: trajectory matches the states. -/
def ComposableFuture.well_formed (F : ComposableFuture) : Prop :=
  F.τ.source = F.S₀ ∧ F.τ.target = F.S₁

/-- The affordance set at state S: the set of all composable futures whose
    source state is S.

    This matches the paper's definition Φ : S₁ → P(F), where P(F) is the
    powerset of composable futures. The set comprehension `{F | F.S₀ = S}`
    is well-defined for any S: it is always non-empty (containing at least
    `idFuture S`) and closed under sequential composition. -/
def AffordanceSet (S : ParadigmaticState) : Set ComposableFuture :=
  setOf fun F => F.S₀ = S

/-- The affordance set of a future: futures reachable from its target state. -/
def ComposableFuture.Φ (F : ComposableFuture) : Set ComposableFuture :=
  AffordanceSet F.S₁

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

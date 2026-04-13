/-!
# Core Future Types

This module defines the basic types for the Composable Future theory.
A composable future is a 4-tuple (S₀, τ, S₁, Φ) representing a transition
from a paradigmatic state S₀ to S₁ via trajectory τ, with affordance set Φ.
-/

namespace ComposableFuture

/-- A paradigmatic state consists of assumptions, constraints, and infrastructure. -/
structure ParadigmaticState where
  assumptions : Type
  constraints : Type
  infrastructure : Type
  deriving Repr

/-- A trajectory represents a transition between paradigmatic states. -/
structure Trajectory where
  source : ParadigmaticState
  target : ParadigmaticState
  deriving Repr

/-- An affordance set represents what futures are accessible from a given state. -/
def AffordanceSet (S : ParadigmaticState) : Type := sorry -- Open Problem 1: Affordance set structure (Phase 4)

/-- A composable future is a 4-tuple (S₀, τ, S₁, Φ). -/
structure ComposableFuture where
  S₀ : ParadigmaticState
  τ  : Trajectory
  S₁ : ParadigmaticState
  Φ  : AffordanceSet S₁

/-- Well-formedness condition: trajectory matches the states -/
def ComposableFuture.well_formed (F : ComposableFuture) : Prop :=
  F.τ.source = F.S₀ ∧ F.τ.target = F.S₁

/-- A trajectory is stateless if it does not depend on history.
    Phase 2: Formal definition requires trajectory refactor to indexed type.
    For now, this is a placeholder predicate. -/
def Trajectory.isStateless (_τ : Trajectory) : Prop := True

/-- A composable future is stateless if its trajectory is stateless. -/
def ComposableFuture.isStateless (F : ComposableFuture) : Prop := F.τ.isStateless

end ComposableFuture

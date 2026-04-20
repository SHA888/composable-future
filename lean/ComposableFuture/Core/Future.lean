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

-- Note: The concrete implementation is `AffordanceDescriptor S` in
-- ComposableFuture.Core.Affordance. A direct definitional connection is blocked
-- by a universe mismatch: AffordanceDescriptor S lives in Type 1 (because
-- ParadigmaticState contains Type fields), while uses here require Type.
-- Until that is resolved, this placeholder keeps downstream modules compiling.
-- This addresses Open Problem 1 (Affordance set structure, Phase 4).

/-- Placeholder: affordance set over a paradigmatic state.

Full implementation is in `AffordanceDescriptor S` (Core.Affordance).
Open Problem 1: connect this placeholder to that type once the universe
level is reconciled.
-/
def AffordanceSet (S : ParadigmaticState) : Type := sorry

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
    Phase 2.1: Placeholder - all trajectories currently considered stateless.
    Phase 2.2: Replace with actual definition after trajectory refactor to indexed type.
    
    Formal definition will be:
    ∀ {S₀ S₁ S₂} (h₁ h₂ : List ParadigmaticState),
      h₁.getLast? = some S₀ → h₂.getLast? = some S₀ →
      τ.apply h₁ = τ.apply h₂ -/
def Trajectory.isStateless (_τ : Trajectory) : Prop := True

/-- A composable future is stateless if its trajectory is stateless. -/
def ComposableFuture.isStateless (F : ComposableFuture) : Prop := F.τ.isStateless

end ComposableFuture

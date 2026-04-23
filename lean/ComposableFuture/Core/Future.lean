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

-- Note: The richer concrete representation is `AffordanceDescriptor S` in
-- ComposableFuture.Core.Affordance. A direct definitional connection to that
-- type is blocked by a universe mismatch: AffordanceDescriptor S lives in
-- Type 1 (because ParadigmaticState contains Type fields), while uses here
-- require Type.
--
-- Open Problem 1 (Phase 4): replace this Unit-valued placeholder with a
-- richer Type-level structure, either by restricting ParadigmaticState's
-- component types to a small universe or by lifting the whole ComposableFuture
-- structure to Type 1.

/-- Placeholder affordance set over a paradigmatic state.

At v0.1 this is the unit type — every state trivially has one "affordance"
slot, which is enough for the compositional laws below (associativity,
closure, well-formedness) to be stated and proved without appeal to
Φ's internal structure.

The richer representation `AffordanceDescriptor S` (Core.Affordance) is
carried alongside as `AffordanceSet.impl` in Type 1, for Phase 4 work.
-/
def AffordanceSet (_S : ParadigmaticState) : Type := Unit

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

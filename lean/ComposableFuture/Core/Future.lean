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

-- Note: AffordanceSet is defined in ComposableFuture.Core.Affordance
-- as a proper dependent type. We use a forward declaration here.
--
-- This opaque declaration is later connected to the actual implementation
-- via `affordance_set_eq` theorem in Affordance.lean.
--
-- This addresses Open Problem 1 (Affordance set structure, Phase 4).

/-- Forward declaration: AffordanceSet is defined in the Affordance module.

The actual implementation is `AffordanceDescriptor S`, a record containing:
- S₁: target paradigmatic state
- trajectory_spec: the trajectory connecting states
- source_eq, target_eq: proofs that trajectory matches states

This opaque declaration breaks the module dependency cycle; the connection
to the implementation is established by the `affordance_set_eq` theorem.
-/
opaque AffordanceSet (S : ParadigmaticState) : Type

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

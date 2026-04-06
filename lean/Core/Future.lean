import Mathlib.Data.Finset.Basic

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
  deriving Repr, BEq

/-- A trajectory represents a transition between paradigmatic states. -/
structure Trajectory where
  source : ParadigmaticState
  target : ParadigmaticState
  deriving Repr, BEq

/-- An affordance set represents what futures are accessible from a given state. -/
def AffordanceSet (S : ParadigmaticState) : Type := Finset (Type)

/-- A composable future is a 4-tuple (S₀, τ, S₁, Φ). -/
structure ComposableFuture where
  S₀ : ParadigmaticState
  τ  : Trajectory
  S₁ : ParadigmaticState
  Φ  : AffordanceSet S₁
  deriving Repr, BEq

/-- Well-formedness condition: trajectory matches the states -/
def ComposableFuture.wellFormed (F : ComposableFuture) : Prop :=
  F.τ.source = F.S₀ ∧ F.τ.target = F.S₁

end ComposableFuture

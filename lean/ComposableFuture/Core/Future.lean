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

/-- A trajectory represents a transition between paradigmatic states. -/
structure Trajectory where
  source : ParadigmaticState
  target : ParadigmaticState
  deriving Repr

/-- Endpoint-determination of `Trajectory`: equal `source` and `target` imply
    equal trajectories.

    **This is a v0.1/v0.2 fact, not a theorem about trajectories in general.** It
    holds only because `Trajectory` currently has no fields beyond its two
    endpoints. Phase 2's trajectory enrichment (adding an internal path,
    e.g. `List ParadigmaticState` of intermediate stages) will make this
    statement false: two distinct paths between the same endpoints exist.

    The deliberately specific name `endpoint_ext` (rather than `ext_eq`) is
    intended to surface this dependency at every call site. Any caller that
    invokes this lemma is implicitly asserting that the two trajectories'
    *endpoints alone* should determine equality — which is precisely what
    the Phase 2 refactor is meant to undo. Such call sites are therefore
    pre-flagged as needing to be revisited.

    See also: `Core/Effect.lean` (callers in identity-law proofs) and
    `proofs/attempt-associativity.md` for the design history. -/
theorem Trajectory.endpoint_ext {τ₁ τ₂ : Trajectory}
    (h₁ : τ₁.source = τ₂.source)
    (h₂ : τ₁.target = τ₂.target) :
    τ₁ = τ₂ := by
  cases τ₁
  cases τ₂
  subst h₁
  subst h₂
  rfl

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
    Phase 2.1: Placeholder — all trajectories currently considered stateless.
    Phase 2.2: Replace with actual definition after trajectory refactor.

    Formal definition will be:
    ∀ {S₀ S₁ S₂} (h₁ h₂ : List ParadigmaticState),
      h₁.getLast? = some S₀ → h₂.getLast? = some S₀ →
      τ.apply h₁ = τ.apply h₂ -/
def Trajectory.isStateless (_τ : Trajectory) : Prop := True

/-- A composable future is stateless if its trajectory is stateless. -/
def ComposableFuture.isStateless (F : ComposableFuture) : Prop := F.τ.isStateless

end ComposableFuture

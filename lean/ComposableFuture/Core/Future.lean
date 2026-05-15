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

## Design change (v0.3, ADR-0005, state-anchored correction)

v0.2 removed Φ as a stored field to resolve a universe mismatch (the attempt
to use `AffordanceDescriptor S₀ : Type 1` while `ComposableFuture : Type 0`).
This created a theory split: the paper's 4-tuple vs. Lean's 3-tuple.

ADR-0005 originally proposed `Φ : Set ComposableFuture`, but that is
kernel-rejected: `Set T = T → Prop` places `ComposableFuture` in the
contravariant (domain) position of its own field — a strict-positivity
violation. The correction restores the 4-tuple with a *state-anchored*
carrier: `Φ : Set ParadigmaticState`. `ParadigmaticState` does not contain
`ComposableFuture`, so there is no positivity or universe issue.

The paper's future-set object `𝒫(F)` is recovered on demand by the
projection `ComposableFuture.afforded F := { G | G.S₀ ∈ F.Φ }`. For a
well-formed future (`F.Φ = {F.S₁}`), `afforded F = AffordanceSet F.S₁` —
content-equivalent to the paper's `Φ : S₁ → 𝒫(F)`.

The identity future carries `Φ = {S}` (Option B): a null transition keeps S
accessible, so `afforded (idFuture S) = AffordanceSet S`. The terminate
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

    v0.3 (ADR-0005, state-anchored): Φ is a stored field
    `Φ : Set ParadigmaticState` carrying the *anchor states* of the affordance
    set. The literal `Set ComposableFuture` is kernel-rejected (strict
    positivity: `Set T = T → Prop` puts the type in contravariant position).
    The paper's future-set is recovered by the `afforded` projection below;
    for well-formed futures it equals `AffordanceSet F.S₁` exactly. -/
structure ComposableFuture where
  S₀ : ParadigmaticState
  τ  : Trajectory
  S₁ : ParadigmaticState
  Φ  : Set ParadigmaticState

/-- Well-formedness condition: trajectory matches the states and the affordance
    anchor is exactly the target state.
    For a well-formed future, `F.Φ = {F.S₁}`, so `afforded F = AffordanceSet F.S₁`. -/
def ComposableFuture.well_formed (F : ComposableFuture) : Prop :=
  F.τ.source = F.S₀ ∧ F.τ.target = F.S₁ ∧ F.Φ = {F.S₁}

/-- The affordance set at state S: the set of all composable futures whose
    source state is S.

    This matches the paper's definition Φ : S₁ → P(F), where P(F) is the
    powerset of composable futures. The set comprehension `{F | F.S₀ = S}`
    is well-defined for any S: it is always non-empty (containing at least
    `idFuture S`) and closed under sequential composition. -/
def AffordanceSet (S : ParadigmaticState) : Set ComposableFuture :=
  setOf fun F => F.S₀ = S

/-- The future-set afforded by `F`: every composable future whose source state
    is one of `F`'s anchor states. This is the recovered paper object `𝒫(F)`
    — stored indirectly via `F.Φ : Set ParadigmaticState` (the keys) and
    reconstructed here on demand (the values). -/
def ComposableFuture.afforded (F : ComposableFuture) : Set ComposableFuture :=
  { G : ComposableFuture | G.S₀ ∈ F.Φ }

/-- **Content equivalence with the paper.** For a well-formed future,
    `afforded F = AffordanceSet F.S₁`. This certifies the state-anchored
    representation is faithful to the paper's `Φ : S₁ → 𝒫(F)`:

    `afforded F = {G | G.S₀ ∈ F.Φ} = {G | G.S₀ ∈ {F.S₁}} = {G | G.S₀ = F.S₁}
                = AffordanceSet F.S₁`. -/
theorem ComposableFuture.afforded_eq_affordanceSet
    (F : ComposableFuture) (hF : F.well_formed) :
    F.afforded = AffordanceSet F.S₁ := by
  unfold ComposableFuture.afforded AffordanceSet
  ext G
  rw [hF.2.2]
  exact Iff.rfl


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

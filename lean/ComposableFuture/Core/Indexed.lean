import ComposableFuture.Core.Future
import Mathlib.Tactic

/-! # Indexed Future Theory

This module formalizes the indexed monad / graded monad approach for the general
(path-dependent) case. The key insight is that if we index futures by trajectory
type, and trajectory type composition is associative by construction, then
associativity holds in the indexed setting.

Based on:
- Orchard, Petricek, Mycroft (2014): "The semantic marriage of monads and effects"
  (Primary reference for indexed monads — the candidate resolution for OP1)
- Orchard, Wadler, Eades (2020): "Unifying graded and parameterised monads"
  (Follow-up work unifying graded and parameterised monad frameworks)
- Fujii (2019): "A 2-Categorical Study of Graded and Indexed Monads"
  (Mathematical foundation for Kleisli/Eilenberg-Moore constructions)

## Graded Monad Definition

A graded monad over a monoidal category (M, ⊗, I) is a family of endofunctors T_m
with:
- μ_{m,n} : T_m(T_n A) → T_{m⊗n} A  (multiplication/bind)
- η : A → T_I A                     (unit)

For Composable Future:
- M = TrajectoryType (a monoid of trajectory classifications)
- T_t = Future indexed by trajectory type t
- ⊗ = compose (associative trajectory type composition)

This gives us associativity: (F >>= G) >>= H = F >>= (G >>= H) in the indexed setting.
-/

namespace ComposableFuture

/-- TrajectoryType is the "grading" type for futures.

At v0.1 this is a *trivial* (single-inhabitant) grading, which is sufficient
to state the graded-monad laws but does not yet distinguish trajectory
classes. Phase 2 will refine it to a free-monoid structure over trajectory
stages (e.g. stateless vs. linear vs. branching), at which point
associativity of composition becomes non-trivial.

Making `TrajectoryType` a subsingleton lets all three `TrajectoryTypeCompose`
laws (assoc, left_id, right_id) close by `rfl` without smuggling in a
bespoke monoid instance whose associativity we would have to prove. -/
abbrev TrajectoryType := Unit

/-- Composition operation for trajectory types.
    This typeclass enables different composition rules for different trajectory types. -/
class TrajectoryTypeCompose (T : Type) where
  /-- Compose two trajectory types -/
  compose : T → T → T
  /-- Unit trajectory type -/
  unit : T
  /-- Associativity law -/
  assoc : ∀ a b c, compose (compose a b) c = compose a (compose b c)
  /-- Left identity law -/
  left_id : ∀ a, compose unit a = a
  /-- Right identity law -/
  right_id : ∀ a, compose a unit = a

/-- The grading monoid structure for TrajectoryType.

With `TrajectoryType = Unit`, this is the trivial (one-element) monoid and
all three laws close by `rfl`. Phase 2 will replace this with a free
monoid on trajectory stages so that different trajectory classes are
genuinely distinguished at the index level. -/
instance : TrajectoryTypeCompose TrajectoryType where
  compose _ _ := ()
  unit        := ()
  assoc    := by intros; rfl
  left_id  := by intro a; rfl
  right_id := by intro a; rfl

/-- An IndexedFuture is graded by trajectory type.
    The index `t` tracks the trajectory type, enabling fine-grained control
    over composition and effect tracking. -/
structure IndexedFuture (t : TrajectoryType) where
  /-- Source paradigmatic state -/
  S₀ : ParadigmaticState
  /-- Target paradigmatic state -/
  S₁ : ParadigmaticState
  /-- The trajectory, which must have type matching the index `t` -/
  τ : Trajectory
  /-- Affordance set at the target state -/
  Φ : AffordanceSet S₁
  /-- Well-formedness: trajectory connects the states -/
  well_formed : τ.source = S₀ ∧ τ.target = S₁

/-- Indexed sequential bind.

    Composition of trajectory types is tracked in the index:
    bind : IndexedFuture t₁ → IndexedFuture t₂ → IndexedFuture (t₁ ⊗ t₂)
    
    This is the graded monad multiplication μ_{t₁,t₂}. -/
def IndexedFuture.seqBind
    {t₁ t₂ : TrajectoryType}
    [TrajectoryTypeCompose TrajectoryType]
    (F : IndexedFuture t₁)
    (G : IndexedFuture t₂)
    (h : F.S₁ = G.S₀) :
    IndexedFuture (TrajectoryTypeCompose.compose t₁ t₂) :=
  { S₀ := F.S₀
    S₁ := G.S₁
    τ := { source := F.τ.source, target := G.τ.target }
    Φ := G.Φ
    well_formed := by
      constructor
      · -- τ.source = F.S₀
        simp [F.well_formed.1]
      · -- τ.target = G.S₁
        simp [G.well_formed.2] }

/-- Identity indexed future at the unit trajectory type.
    This is the graded monad unit η : A → T_I A.
    The identity future is always indexed by the unit trajectory type. -/
def IndexedFuture.idFuture
    [TrajectoryTypeCompose TrajectoryType]
    (S : ParadigmaticState) :
    IndexedFuture (TrajectoryTypeCompose.unit (T := TrajectoryType)) :=
  { S₀ := S
    S₁ := S
    τ := { source := S, target := S }
    Φ := ()
    well_formed := by exact ⟨rfl, rfl⟩ }

/-! ## Indexed Endpoint-Extraction Associativity

The theorem below inherits the same caveat as `Laws.seqBind_endpoint_assoc`
and `Stateless.assoc_stateless_endpoint`: it is endpoint-extraction
associativity, not paradigm-trajectory composition associativity. With
`TrajectoryType := Unit`, the graded structure is also currently trivial,
so the indexed framing does not yet *add* anything beyond the unindexed
result.

The substantive indexed associativity — the result that Orchard,
Petricek & Mycroft (2014) actually proves — requires (a) `TrajectoryType`
to be a non-trivial free monoid over trajectory stages, and (b) the
underlying `Trajectory` to carry a path that `seqBind` actually
concatenates. Both are open Phase 2 refactors. -/

/-- Endpoint-extraction associativity for indexed futures.

See the section header above for the honest framing of what this proves
versus what a substantive indexed-monad associativity would require. -/
theorem IndexedFuture.endpoint_assoc
    {t₁ t₂ t₃ : TrajectoryType}
    [tc : TrajectoryTypeCompose TrajectoryType]
    (F : IndexedFuture t₁)
    (G : IndexedFuture t₂)
    (H : IndexedFuture t₃)
    (h₁ : F.S₁ = G.S₀)
    (h₂ : G.S₁ = H.S₀)
    (h₃ : (IndexedFuture.seqBind F G h₁).S₁ = H.S₀)
    (h₄ : F.S₁ = (IndexedFuture.seqBind G H h₂).S₀) :
    cast (congr_arg IndexedFuture (tc.assoc t₁ t₂ t₃))
      (IndexedFuture.seqBind (IndexedFuture.seqBind F G h₁) H h₃) =
    IndexedFuture.seqBind F (IndexedFuture.seqBind G H h₂) h₄ := by
  -- With `TrajectoryType := Unit`, the compose-associativity witness reduces to
  -- `rfl`, so `cast (congr_arg IndexedFuture rfl) x = x` definitionally. Both
  -- sides of the equation then unfold to the same `IndexedFuture ()` record
  -- (same S₀, S₁, τ, Φ; `well_formed` proofs identified by proof irrelevance).
  rfl

/-- Left identity for indexed futures.
    The identity future has type unit, so composition is unit ⊗ t = t.
    
    We use `cast` with the identity law to convert the result type. -/
theorem IndexedFuture.left_id
    {t : TrajectoryType}
    [tc : TrajectoryTypeCompose TrajectoryType]
    (F : IndexedFuture t)
    (S : ParadigmaticState)
    (h : S = F.S₀) :
    cast (congr_arg IndexedFuture (tc.left_id t))
      (IndexedFuture.seqBind
        (IndexedFuture.idFuture S) F
        (by simp [IndexedFuture.idFuture, h])) = F := by
  -- With `TrajectoryType := Unit`, `tc.left_id t : compose () t = t` reduces
  -- to `rfl`, so `cast` is identity. What remains is to show the resulting
  -- `IndexedFuture` equals `F` — both sides have `S₀ = S = F.S₀`
  -- (using `h`), the same `S₁`, τ = { source := S, target := F.τ.target }
  -- on the left vs. `F.τ` on the right (which agrees via `F.well_formed.1`
  -- under the substitution `h`), and the same Φ.
  subst h
  rcases F with ⟨F_S₀, F_S₁, ⟨τ_src, τ_tgt⟩, _Φ, ⟨hsrc, _htgt⟩⟩
  simp_all [IndexedFuture.seqBind, IndexedFuture.idFuture]

/-- Right identity for indexed futures.
    The identity future has type unit, so composition is t ⊗ unit = t.
    
    We use `cast` with the identity law to convert the result type. -/
theorem IndexedFuture.right_id
    {t : TrajectoryType}
    [tc : TrajectoryTypeCompose TrajectoryType]
    (F : IndexedFuture t)
    (S : ParadigmaticState)
    (h : F.S₁ = S) :
    cast (congr_arg IndexedFuture (tc.right_id t))
      (IndexedFuture.seqBind F
        (IndexedFuture.idFuture S)
        (by simp [IndexedFuture.idFuture, h])) = F := by
  -- Dual to `left_id`. `tc.right_id t` reduces to `rfl` under
  -- `TrajectoryType := Unit`, `cast` vanishes, and after substituting `h`
  -- the trajectory endpoints match F's via `F.well_formed.2`.
  subst h
  rcases F with ⟨F_S₀, F_S₁, ⟨τ_src, τ_tgt⟩, _Φ, ⟨_hsrc, htgt⟩⟩
  simp_all [IndexedFuture.seqBind, IndexedFuture.idFuture]

/-! ## Concrete Trajectory Types

Phase 2 will distinguish trajectory classes (stateless / linear / branching)
by promoting `TrajectoryType` to a non-trivial monoid. At v0.1 all three
collapse to the single inhabitant of `Unit`; they are kept as named
aliases so that Phase 2 refactors can re-specialize them without touching
call sites. -/

/-- The stateless trajectory type — unit of the (trivial) monoid. -/
def statelessType : TrajectoryType := ()

/-- A linear trajectory type (path-dependent, non-branching). v0.1 alias. -/
def linearType : TrajectoryType := ()

/-- A branching trajectory type (divergent transitions). v0.1 alias. -/
def branchingType : TrajectoryType := ()

/-- Sanity checks: under the trivial monoid, all compositions collapse to unit. -/
example : TrajectoryTypeCompose.compose statelessType linearType = linearType := rfl
example : TrajectoryTypeCompose.compose linearType statelessType = linearType := rfl
example : TrajectoryTypeCompose.compose linearType branchingType =
    TrajectoryTypeCompose.compose statelessType statelessType := rfl

end ComposableFuture

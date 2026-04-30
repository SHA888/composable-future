import ComposableFuture.Core.Future
import ComposableFuture.Core.Operators

/-!
# Affordance Set as Dependent Type (Phase 4)

This module formalizes the affordance set Φ as a dependent type over paradigmatic
states, addressing Open Problems 1, 2, and 4 from the Composable Future theory.

## Key Insight

An affordance set Φ at state S represents the futures that are *accessible* from S.
Unlike a trajectory τ which describes a specific transition, Φ captures the
*potential* — what could happen, given the paradigm defined by S.

Formally:
- Φ : Π(S : ParadigmaticState), Type — a dependent type family
- Elements of Φ S are "affordance descriptors" encoding possible futures from S

## Open Problems Addressed

- **OP1 (Phase 4)**: Affordance set structure — Φ as proper dependent type
- **OP2**: Φ well-definedness — Φ is well-defined at the type level before S₁ realization
- **OP4**: Affordance composition — Φ ∘ Φ' respects paradigm-specific typing

## Design Decisions

1. **Affordance as record**: Each affordance descriptor contains:
   - Target state S₁ (where this affordance leads)
   - A trajectory specification from current state to S₁

2. **Composition as dependent function**: `composeSequential` and `composeParallel`
respect the type dependency — the result type depends on the composed state.

3. **Well-definedness proof**: Shows pre-realization (type-level) and
post-realization (value-level) affordances are connected by canonical map.
-/

namespace ComposableFuture

-- ============================================================
-- P4.1: Affordance Set as Dependent Type
-- ============================================================

/-- An affordance descriptor represents one possible future from a state.

An affordance at state S₀ describes a potential trajectory to some target state S₁,
along with evidence that this transition is valid within the current paradigm.

This is the richer (Type 1) representation that `AffordanceSet` in
`Future.lean` will eventually point to once the universe level is
reconciled (Phase 4).
-/
structure AffordanceDescriptor (S₀ : ParadigmaticState) where
  /-- The target state this affordance leads to -/
  S₁ : ParadigmaticState
  /-- Evidence that a trajectory exists from S₀ to S₁

  In a full implementation, this would include:
  - A specific trajectory value
  - Well-formedness proof that τ.source = S₀ ∧ τ.target = S₁
  - Optional: probability weight for probabilistic affordances
  -/
  trajectory_spec : Trajectory
  /-- Evidence that the trajectory matches our states -/
  source_eq : trajectory_spec.source = S₀
  target_eq : trajectory_spec.target = S₁

-- `AffordanceSet` is declared in Future.lean as `Unit` (Type 0) to keep
-- downstream code in `Type`. `AffordanceDescriptor` is the richer (Type 1)
-- representation carried here. A universe mismatch prevents a direct
-- definitional equality; see Open Problem 1 (Phase 4).

/-- Concrete implementation of the affordance set as a dependent record.

This is the intended definition of `AffordanceSet S` (declared in Future.lean).
It lives in `Type 1` because `ParadigmaticState` contains `Type` fields, while
the placeholder in Future.lean uses `Type`. Until the universe level is
reconciled (Open Problem 1), this type and `AffordanceSet S` are *not*
definitionally or propositionally equal — they are kept separate intentionally.
-/
-- Open Problem 1: reconcile with AffordanceSet (Type vs Type 1).
@[reducible]
def AffordanceSet.impl (S : ParadigmaticState) : Type 1 :=
  AffordanceDescriptor S

-- ============================================================
-- P4.1: Affordance Composition
-- ============================================================

-- `paradigmaticTensor` is defined in Core.Operators so both modules can
-- share the component-wise cartesian state product.

scoped infixr:60 " ⊗ " => paradigmaticTensor

/-- Sequential composition of affordances: Φ₁ ∘ Φ₂

Given:
- φ₁ : AffordanceSet S₀ — an affordance from S₀ to some S₁
- φ₂ : AffordanceSet S₁ — an affordance from S₁ to some S₂

Returns a composite affordance from S₀ to S₂.

This is the "chaining" of affordances: if S₀ affords reaching S₁, and
S₁ affords reaching S₂, then S₀ affords (indirectly) reaching S₂.

Note: This is a partial function — it requires φ₁.S₁ = φ₂.S₀ (matching states).
The type system tracks this dependency.
-/
-- Note: the original trajectory data from φ₁ and φ₂ is not stored in the
-- composed descriptor — only the endpoints are preserved. This is intentional
-- for the type-level representation; concrete trajectory composition would
-- require a richer trajectory model (Phase 2).
def composeSequential {S₀ : ParadigmaticState}
  (φ₁ : AffordanceDescriptor S₀) (φ₂ : AffordanceDescriptor φ₁.S₁) :
  AffordanceDescriptor S₀ where
  S₁ := φ₂.S₁
  trajectory_spec :=
    { source := S₀
    , target := φ₂.S₁ }
  source_eq := rfl
  target_eq := rfl

/-- Parallel composition of affordances: Φ₁ ⊗ Φ₂

Given:
- φ₁ : AffordanceDescriptor S₁ — affordance from S₁ to S₁'
- φ₂ : AffordanceDescriptor S₂ — affordance from S₂ to S₂'

Returns a composite affordance from (S₁ ⊗ S₂) to (S₁' ⊗ S₂').

This captures the intuition: if you can do X in paradigm P₁ and Y in
paradigm P₂, you can do both simultaneously in the joint paradigm P₁ ⊗ P₂.

The tensor product preserves the component structure, allowing independent
affordances to coexist.
-/
-- Note: trajectory data is dropped for the same reason as composeSequential.
def composeParallel {S₁ S₂ : ParadigmaticState}
  (φ₁ : AffordanceDescriptor S₁) (φ₂ : AffordanceDescriptor S₂) :
  AffordanceDescriptor (S₁ ⊗ S₂) where
  S₁ := φ₁.S₁ ⊗ φ₂.S₁
  trajectory_spec :=
    { source := S₁ ⊗ S₂
    , target := φ₁.S₁ ⊗ φ₂.S₁ }
  source_eq := rfl
  target_eq := rfl

-- ============================================================
-- P4.3: Open Problem 2 — Φ Well-Definedness
-- ============================================================

/-- Pre-realization affordance: a type-level specification.

Before S₁ is realized (concretely instantiated), Φ exists as a type
representing *possible* affordances. This is the "modal" view — what
could be done, given the paradigm.

This corresponds to Chemero's ecological affordances: they exist as
relations between organism and environment, prior to actualization.
-/
def PreRealizedAffordance (S₀ : ParadigmaticState) : Type :=
  AffordanceSet S₀

/-- Post-realization affordance: a value-level list of actual affordances.

After S₁ is realized, Φ becomes a concrete list of trajectories that
were actually available. This is the "actual" view — what was
truly possible in hindsight.

Note: lives in `Type 1` because `AffordanceDescriptor S₀` does, since
`ParadigmaticState` has `Type`-valued fields. -/
def PostRealizedAffordance (S₀ : ParadigmaticState) : Type 1 :=
  List (AffordanceDescriptor S₀)

/-- The canonical map from post-realization to pre-realization.

This theorem establishes that post-realized affordances (concrete sets)
can be lifted to pre-realized affordances (type-level specifications).

The map is many-to-one: multiple concrete instantiations may satisfy
the same type-level specification.

This resolves Open Problem 2: "Is Φ well-defined before S₁ is realized?"

Answer: Yes — Φ is well-defined at the type level (as `AffordanceSet S₀`)
before realization. Post-realization concrete sets are refinements
(projections) of this type.
-/
def pre_post_correspondence {S₀ : ParadigmaticState}
  (_post : PostRealizedAffordance S₀) :
  PreRealizedAffordance S₀ :=
  -- `PreRealizedAffordance S₀` unfolds to `AffordanceSet S₀`, which is
  -- `Unit` at v0.1. Every post-realized list maps to the unique pre-realized
  -- affordance witness — the map is many-to-one, as the comment records.
  ()

/-- Pre-realization Φ is well-defined: the type is inhabited for every state.

This is the core formal answer to Open Problem 2: "Is Φ well-defined
before S₁ is realized?"  The theorem states that for every paradigmatic
state S, the type `PreRealizedAffordance S` has at least one inhabitant.
At v0.1 this is trivial (the type is `Unit`), but the statement is
universe-generic: it will remain valid when `AffordanceSet` is upgraded
to a non-trivial dependent type in Phase 4 (Open Problem 1).

**Falsifying condition:** If this theorem failed, Φ would be undefined at
the type level for some state, making indexed-monad bind operations
impossible before S₁ realization. -/
instance pre_realized_is_well_defined (S : ParadigmaticState) :
    Inhabited (PreRealizedAffordance S) :=
  ⟨()⟩

/-- The canonical map is surjective onto pre-realization.

Every pre-realized affordance is the image of at least one post-realized
affordance list. This bridges the modal (possible) and actual views:
whatever Φ specifies at the type level can be realized by some concrete
set of trajectories.

At v0.1 the codomain is a singleton, so surjectivity is trivial. The
theorem documents the intent for the Phase 4 upgrade. -/
theorem pre_post_correspondence_surjective (S₀ : ParadigmaticState)
    (pre : PreRealizedAffordance S₀) :
    ∃ post : PostRealizedAffordance S₀,
      pre_post_correspondence post = pre :=
  ⟨[], rfl⟩

/-- The canonical map is many-to-one: distinct realizations refine the
same specification.

This formalizes the abstraction relationship: pre-realization is a
coarser description than post-realization. Two different lists of
concrete affordances may satisfy the same type-level Φ.

This is the *converse* of injectivity — it is exactly what we want.
If the map were injective (one-to-one), pre-realization would encode
as much information as post-realization, defeating the purpose of the
distinction. -/
theorem pre_post_correspondence_many_to_one (S₀ : ParadigmaticState) :
    ∃ (l₁ l₂ : PostRealizedAffordance S₀),
      l₁ ≠ l₂ ∧
      pre_post_correspondence (S₀ := S₀) l₁ =
      pre_post_correspondence (S₀ := S₀) l₂ := by
  refine ⟨[], [⟨S₀, { source := S₀, target := S₀ }, rfl, rfl⟩], ?_, rfl⟩
  -- [] ≠ [x]: h : [] = [x], so h.symm : [x] = [] contradicts List.cons_ne_nil
  intro h; exact absurd h.symm (List.cons_ne_nil _ _)

/-- Φ is well-defined at the type level.

This is the key result: `AffordanceSet S` is a well-formed dependent type
for any paradigmatic state S. The type exists and is inhabited precisely
when the paradigm supports affordances.
-/
-- `AffordanceDescriptor S` is always inhabitable: a self-loop affordance exists.
-- Stated over `AffordanceSet.impl` (not `AffordanceSet`) due to the universe gap.
theorem affordance_set_well_defined (S : ParadigmaticState) :
    Nonempty (AffordanceSet.impl S) := by
  exact ⟨⟨S, { source := S, target := S }, rfl, rfl⟩⟩

-- ============================================================
-- P4.3: Adversarial tests (TEST_SKILLS §2.2)
-- ============================================================

-- Test T1: Instance synthesis works for a concrete state (not just universally).
-- Spec: pre_realized_is_well_defined — "inhabited for every state"
-- Negative confirmation: removing the instance makes this `#check` fail at
-- elaboration time, proving the instance is load-bearing.
-- Source: TODO.md P4.3 "pre_realized_is_well_defined — inhabited for every state"
private def _testConcreteState : ParadigmaticState :=
  { assumptions := Unit, constraints := Unit, infrastructure := Unit }

example : Inhabited (PreRealizedAffordance _testConcreteState) :=
  inferInstance

-- Test T2: A non-empty post-realization also surjects onto pre-realization.
-- Spec: pre_post_correspondence_surjective — "every pre-realization is realized
--   by some post-realization." The production proof only witnesses [].
--   This test confirms a non-empty list is also a valid witness.
-- Source: TODO.md P4.3 "pre_post_correspondence_surjective"
theorem pre_post_correspondence_surjective_nonempty (S₀ : ParadigmaticState) :
    ∃ post : PostRealizedAffordance S₀,
      post ≠ [] ∧ pre_post_correspondence post = () := by
  exact ⟨[⟨S₀, { source := S₀, target := S₀ }, rfl, rfl⟩],
         List.cons_ne_nil _ _,
         rfl⟩

-- Test T3: Two distinct singleton lists with different descriptors collapse to
-- the same pre-realization (many-to-one beyond the empty/non-empty case).
-- Spec: pre_post_correspondence_many_to_one — "map is non-injective."
-- Negative confirmation: if pre_post_correspondence were injective (i.e. if
--   AffordanceSet were upgraded from Unit to a richer type that distinguishes
--   descriptors), this theorem would fail — surfacing the Phase 4 obligation.
-- Source: TODO.md P4.3 "pre_post_correspondence_many_to_one"
theorem pre_post_correspondence_many_to_one_singletons (S₀ S₁ : ParadigmaticState) :
    pre_post_correspondence (S₀ := S₀) [⟨S₀, { source := S₀, target := S₀ }, rfl, rfl⟩] =
    pre_post_correspondence (S₀ := S₀) [⟨S₁, { source := S₀, target := S₁ }, rfl, rfl⟩] :=
  rfl

-- ============================================================
-- P4.4: Gate Check Documentation
-- ============================================================

-- Affordance composition respects the dependent type structure.
--
-- This documents that composing affordances produces an affordance
-- whose type correctly depends on the composed paradigmatic state.
--
-- For sequential composition:
--   φ₁ : AffordanceDescriptor S₀  →  S₁
--   φ₂ : AffordanceDescriptor S₁  →  S₂
--   ─────────────────────────────────
--   φ₁ ∘ φ₂ : AffordanceDescriptor S₀  →  S₂
--
-- For parallel composition:
--   φ₁ : AffordanceDescriptor S₁  →  S₁'
--   φ₂ : AffordanceDescriptor S₂  →  S₂'
--   ─────────────────────────────────────────
--   φ₁ ⊗ φ₂ : AffordanceDescriptor (S₁ ⊗ S₂)  →  (S₁' ⊗ S₂')
--
-- This resolves Open Problem 4: "Does Φ ∘ Φ' hold?"
--
-- Answer: Yes — composition is well-typed and respects the dependent
-- type structure. The composed affordance lives in the correct type
-- indexed by the composed paradigmatic state.
--
-- Type-correctness by construction:
-- - `composeSequential φ₁ φ₂` returns `AffordanceDescriptor S₀`
-- - `AffordanceSet.impl S₀ = AffordanceDescriptor S₀` by definition
-- - Therefore the result has the correct type
--
-- TODO: Formalize membership relation for affordance sets to state
-- `composeSequential φ₁ φ₂ ∈ AffordanceSet.impl S₀` as a theorem.

end ComposableFuture

import ComposableFuture.Core.Future
import ComposableFuture.Core.Operators

/-!
# Affordance Set — Membership Witnesses and Composition (Phase 4, v0.3)

**v0.3 (ADR-0005, state-anchored):** Φ is now a *stored field*
`Φ : Set ParadigmaticState` on `ComposableFuture`. `AffordanceSet S :=
{F : ComposableFuture | F.S₀ = S}` is still defined in `Core.Future`, but it is
no longer the primary carrier of Φ — it is the *target* of the `afforded`
projection (`afforded F = AffordanceSet F.S₁` for well-formed F, theorem
`afforded_eq_affordanceSet`). `AffordanceDescriptor` remains a construction
helper only. The OP1/OP2/OP4 notes below are retained for history; read
"definition of Φ" as "the `afforded` view of the stored Φ".

This module provides:

1. **`AffordanceDescriptor`** — a concrete witness for affordance set membership.
   An element of `AffordanceSet S₀` is any `ComposableFuture` with `.S₀ = S₀`;
   `AffordanceDescriptor` is a record that certifies membership by carrying
   the source-equality proof explicitly, along with a target state.

2. **Composition operations** — `composeSequential` and `composeParallel`
   produce valid members of the appropriate affordance sets.

3. **OP1 resolution** — `AffordanceSet S` is a proper `Set` type with no
   universe mismatch. `AffordanceDescriptor` (in `Type 1` because
   `ParadigmaticState` has `Type`-valued fields) is only a witness helper,
   not the definition of Φ.

4. **OP2 resolution** — `AffordanceSet S` is defined and non-empty for every S
   (contains `idFuture S`). Φ is well-defined before S₁ is realized because
   it is a set comprehension over `ComposableFuture`, not a value-level
   computation that depends on S₁ being realized.

5. **OP4 resolution** — `seqBind_Φ_eq` shows `(F >>= G).Φ = G.Φ` (by `rfl`).
   `seqBind_mem_affordanceSet` shows sequential composition is closed in
   `AffordanceSet F.S₀`. Descriptor-based witnesses close the remaining cases.
-/

namespace ComposableFuture

-- ============================================================
-- P4.1: AffordanceDescriptor — Concrete Membership Witness
-- ============================================================

/-- An affordance descriptor is a concrete witness for membership in
    `AffordanceSet S₀`.

    An affordance at state S₀ certifies that a specific trajectory from S₀
    to some S₁ exists, making the corresponding future a member of
    `AffordanceSet S₀`.

    Note: `AffordanceDescriptor S₀` lives in `Type 1` because
    `ParadigmaticState` has `Type`-valued fields (assumptions, constraints,
    infrastructure). This is unproblematic in v0.2: it is only a witness
    helper, not the definition of Φ (which is `Set ComposableFuture`). -/
structure AffordanceDescriptor (S₀ : ParadigmaticState) where
  /-- The target state this affordance leads to -/
  S₁ : ParadigmaticState
  /-- A trajectory from S₀ to S₁ -/
  trajectory_spec : Trajectory
  /-- Evidence that the trajectory starts at S₀ -/
  source_eq : trajectory_spec.source = S₀
  /-- Evidence that the trajectory ends at S₁ -/
  target_eq : trajectory_spec.target = S₁

/-- Convert an affordance descriptor to a `ComposableFuture`.
    The Φ anchor is the singleton `{φ.S₁}` (well-formed: `afforded` then
    recovers `AffordanceSet φ.S₁`). -/
def AffordanceDescriptor.toFuture {S₀ : ParadigmaticState}
    (φ : AffordanceDescriptor S₀) : ComposableFuture :=
  { S₀ := S₀, τ := φ.trajectory_spec, S₁ := φ.S₁, Φ := {φ.S₁} }

/-- The future produced by a descriptor is a member of `AffordanceSet S₀`.

    This is the formal membership certificate: `toFuture φ ∈ AffordanceSet S₀`
    holds because `(toFuture φ).S₀ = S₀` by construction. -/
theorem AffordanceDescriptor.mem_affordanceSet {S₀ : ParadigmaticState}
    (φ : AffordanceDescriptor S₀) :
    φ.toFuture ∈ AffordanceSet S₀ := rfl

-- ============================================================
-- P4.1: Affordance Composition
-- ============================================================

scoped infixr:60 " ⊗ " => paradigmaticTensor

/-- Sequential composition of affordance descriptors.

Given:
- φ₁ : AffordanceDescriptor S₀  (S₀ affords reaching some intermediate S₁)
- φ₂ : AffordanceDescriptor φ₁.S₁  (φ₁.S₁ affords reaching some S₂)

Produces a composed descriptor certifying S₀ affords reaching S₂.

v0.2 (ADR-0002): the trajectory path is concatenated: `φ₁.trajectory_spec.path ++ φ₂.trajectory_spec.path`.
-/
def composeSequential {S₀ : ParadigmaticState}
    (φ₁ : AffordanceDescriptor S₀) (φ₂ : AffordanceDescriptor φ₁.S₁) :
    AffordanceDescriptor S₀ where
  S₁              := φ₂.S₁
  trajectory_spec := { source := S₀
                      , path   := φ₁.trajectory_spec.path ++ φ₂.trajectory_spec.path
                      , target := φ₂.S₁ }
  source_eq       := rfl
  target_eq       := rfl

/-- Parallel composition of affordance descriptors.

Given:
- φ₁ : AffordanceDescriptor S₁  (S₁ affords reaching S₁')
- φ₂ : AffordanceDescriptor S₂  (S₂ affords reaching S₂')

Produces a descriptor for the joint state (S₁ ⊗ S₂) affording (S₁' ⊗ S₂').

v0.2: path is empty (parallel composition does not sequence paths). -/
def composeParallel {S₁ S₂ : ParadigmaticState}
    (φ₁ : AffordanceDescriptor S₁) (φ₂ : AffordanceDescriptor S₂) :
    AffordanceDescriptor (S₁ ⊗ S₂) where
  S₁              := φ₁.S₁ ⊗ φ₂.S₁
  trajectory_spec := { source := S₁ ⊗ S₂
                      , path   := []
                      , target := φ₁.S₁ ⊗ φ₂.S₁ }
  source_eq       := rfl
  target_eq       := rfl

-- ============================================================
-- P4.3: Open Problem 2 — Φ Well-Definedness (resolved by v0.2)
-- ============================================================

/-- **OP2 Resolution**: `AffordanceSet S₀` is always non-empty.

    The identity future `idFuture S₀` is a member of `AffordanceSet S₀`
    because `(idFuture S₀).S₀ = S₀` by definition. This shows Φ is
    well-defined at the type level before S₁ is realized: `AffordanceSet S₀`
    exists as a set comprehension independently of any concrete future.

    **Falsifying condition**: If this theorem failed, some paradigmatic state S
    would have no future with source S — contradicting `idFuture S` existing.
    This is impossible by the definition of `idFuture`. -/
theorem affordanceSet_contains_id (S₀ : ParadigmaticState) :
    idFuture S₀ ∈ AffordanceSet S₀ := rfl

/-- `AffordanceSet S₀` is non-empty (inhabited by `idFuture S₀`). -/
theorem affordanceSet_nonempty (S₀ : ParadigmaticState) :
    (AffordanceSet S₀).Nonempty :=
  ⟨idFuture S₀, rfl⟩

/-- Every state admits an `AffordanceDescriptor` (the self-loop descriptor). -/
theorem affordanceDescriptor_nonempty (S₀ : ParadigmaticState) :
    Nonempty (AffordanceDescriptor S₀) :=
  ⟨{ S₁             := S₀
     trajectory_spec := { source := S₀, path := [], target := S₀ }
     source_eq       := rfl
     target_eq       := rfl }⟩

-- ============================================================
-- P4.4: Open Problem 4 — Φ Composition (resolved by v0.2)
-- ============================================================

/-- **OP4 Resolution (main theorem)**: The Φ of a sequential composition
    equals the Φ of the last step.

    `(seqBind F G h).Φ = G.Φ`

    This is the categorical statement: the affordances available after
    sequencing F then G are exactly the affordances of G's anchor set —
    i.e., "Φ ∘ Φ' holds" in the sense that composition is closed and the
    resulting Φ is well-defined. Holds by `rfl` (state-anchored: seqBind
    propagates `Φ := G.Φ` directly). -/
theorem seqBind_Φ_eq (F G : ComposableFuture) (h : F.S₁ = G.S₀) :
    (seqBind F G h).Φ = G.Φ := rfl

/-- Sequential composition targets G's target state: `(seqBind F G h).S₁ = G.S₁`. -/
theorem seqBind_targets_G (F G : ComposableFuture) (h : F.S₁ = G.S₀) :
    (seqBind F G h).S₁ = G.S₁ := rfl

/-- **OP4 (closure)**: `AffordanceSet F.S₀` is closed under sequential composition.

    If G is reachable from F.S₁ (i.e., G ∈ AffordanceSet F.S₁),
    then `seqBind F G` is reachable from F.S₀. -/
theorem seqBind_mem_affordanceSet (F G : ComposableFuture) (h : F.S₁ = G.S₀) :
    seqBind F G h ∈ AffordanceSet F.S₀ := rfl

/-- OP4 (sequential descriptor): `composeSequential` produces a future in
    `AffordanceSet S₀`. -/
theorem composeSequential_mem {S₀ : ParadigmaticState}
    (φ₁ : AffordanceDescriptor S₀) (φ₂ : AffordanceDescriptor φ₁.S₁) :
    (composeSequential φ₁ φ₂).toFuture ∈ AffordanceSet S₀ := rfl

/-- OP4 (parallel descriptor): `composeParallel` produces a future in
    `AffordanceSet (S₁ ⊗ S₂)`. -/
theorem composeParallel_mem {S₁ S₂ : ParadigmaticState}
    (φ₁ : AffordanceDescriptor S₁) (φ₂ : AffordanceDescriptor S₂) :
    (composeParallel φ₁ φ₂).toFuture ∈ AffordanceSet (S₁ ⊗ S₂) := rfl

-- ============================================================
-- P4.4: Gate Check
-- ============================================================
--
-- **OP1 (AffordanceSet as proper dependent type)**: ✅ RESOLVED (v0.2)
--   AffordanceSet S := {F : ComposableFuture | F.S₀ = S}
--   This is a proper Set in Lean 4 with no universe mismatch.
--   AffordanceDescriptor (the witness helper) lives in Type 1, but this is
--   irrelevant to the definition of Φ.
--
-- **OP2 (Φ well-defined before S₁ realization)**: ✅ RESOLVED (v0.2)
--   AffordanceSet S₀ is defined purely from S₀ via set comprehension.
--   It is non-empty (affordanceSet_nonempty). The set exists independently
--   of any concrete realization of S₁.
--
-- **OP4 (composition of affordance sets Φ ∘ Φ')**: ✅ RESOLVED (v0.2)
--   seqBind_Φ_eq: (F >>= G).Φ = G.Φ  (rfl)
--   seqBind_mem_affordanceSet: seqBind F G ∈ AffordanceSet F.S₀  (rfl)
--   composeSequential_mem / composeParallel_mem: descriptor witnesses  (rfl)

end ComposableFuture

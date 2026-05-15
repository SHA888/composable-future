import ComposableFuture.Core.Future
import ComposableFuture.Core.Affordance

/-! # Effect System Connection (P4.2, v0.3)

This module formalizes the mapping from affordance set Φ to an effect type
system, establishing the correspondence between affordances and computational
effects.

**v0.3 (ADR-0005):** `ComposableFuture` now stores `Φ : Set ParadigmaticState`,
but `EffectfulFuture`/`EffectfulComputation` are *separate* indexed structures
that do **not** carry Φ — so this module is unchanged. `effect` stays
`AffordanceSet S₁`, which is exactly the `afforded` view of the stored Φ for a
well-formed future (`afforded_eq_affordanceSet`). The "derived, not stored"
framing below is correct *for the effect indexed structures*; on
`ComposableFuture` itself Φ is stored.

## Core Insight

The effect annotation at state S₁ is the affordance set `AffordanceSet S₁`.
This is a proper `Set ComposableFuture` — not a placeholder `Unit` value.

The `effect` annotation is now a **derived property** of the type indices, not a
stored field. For any computation indexed by `(S₀, S₁)`, the effect at S₁ is
always `AffordanceSet S₁`. This removes the need for:

- `[Subsingleton (Effect S₁)]` guards — right-identity laws now hold
  unconditionally (the effect is always `AffordanceSet S₁`, same on both sides)
- `Effect.at` as a separate value — the effect IS `AffordanceSet S₁`
- `heff : F₁.effect = F₂.effect` in `ext_eq` — determined by the type index

## Orchard et al. Indexed Monad Correspondence (v0.2)

| Orchard & Petricek            | Composable Future (v0.2)                           |
|-------------------------------|---------------------------------------------------|
| Index `i` (pre)               | Source paradigmatic state `S₀`                    |
| Index `j` (post)              | Target paradigmatic state `S₁`                    |
| Effect annotation             | `AffordanceSet S₁` — futures reachable from S₁    |
| Indexed sequencing            | `EffectfulFuture.seq`                             |
| Indexed bind `>>=`            | `EffectfulComputation.bind`                       |
| Unit `return`                 | `EffectfulComputation.pure`                       |

The effect annotation is determined by the post-index S₁ — exactly as in
Orchard & Petricek's categorical model where the grading is determined by the
monoid element indexing the computation.
-/

namespace ComposableFuture

-- ============================================================
-- P4.2: Effect Type Alias
-- ============================================================

/-- The effect annotation at a paradigmatic state S is the affordance set:
    the set of all composable futures reachable from S.

    v0.2: `Effect S : Set ComposableFuture` is a proper set, replacing the
    placeholder `Unit`. This is a VALUE alias — `Effect S` evaluates to the
    specific set `AffordanceSet S`, not a type family. Use `Set ComposableFuture`
    directly in return-type positions; use `Effect S` in expressions where you
    want to name the specific affordance set at S. -/
def Effect (S : ParadigmaticState) : Set ComposableFuture := AffordanceSet S

-- ============================================================
-- P4.2: Effectful Future (value-less indexed computation)
-- ============================================================

/-- An effectful future is an indexed transition from `S₀` to `S₁`.

    The effect annotation at S₁ is derived: `Effect S₁ = AffordanceSet S₁`.
    It is not stored as a field — it is determined by the type index S₁.

    This corresponds to Orchard & Petricek's indexed computation `M i j`
    (value-less variant). -/
structure EffectfulFuture (S₀ S₁ : ParadigmaticState) where
  /-- The trajectory connecting source to target -/
  τ : Trajectory
  /-- Evidence that τ connects S₀ to S₁ -/
  well_formed : τ.source = S₀ ∧ τ.target = S₁

/-- The effect of an effectful future: the affordance set at the target state.
    Derived from the type index S₁, not stored. -/
def EffectfulFuture.effect {S₀ S₁ : ParadigmaticState}
    (_F : EffectfulFuture S₀ S₁) : Set ComposableFuture :=
  AffordanceSet S₁

/-- Identity effectful future: stay at state S.
    Corresponds to `return` in the indexed monad.
    Path is empty (no intermediate states). -/
def EffectfulFuture.id (S : ParadigmaticState) : EffectfulFuture S S where
  τ := { source := S, path := [], target := S }
  well_formed := ⟨rfl, rfl⟩

/-- Extensionality for `EffectfulFuture`: equal trajectory implies equal records.

    v0.2: `heff` is no longer needed. The `effect` is derived from S₁ (same
    for both F₁ and F₂ since they share type indices). The `well_formed` field
    equality discharges by proof irrelevance (it is a `Prop`). -/
theorem EffectfulFuture.ext_eq {S₀ S₁ : ParadigmaticState}
    {F₁ F₂ : EffectfulFuture S₀ S₁}
    (hτ : F₁.τ = F₂.τ) :
    F₁ = F₂ := by
  cases F₁; cases F₂; subst hτ; rfl

/-- Sequential composition of effectful futures: F ; G : S₀ → S₂.

v0.2 (ADR-0002): trajectory paths are concatenated: `F.τ.path ++ G.τ.path`.
This yields substantive associativity via `List.append_assoc`.
-/
def EffectfulFuture.seq
    {S₀ S₁ S₂ : ParadigmaticState}
    (F : EffectfulFuture S₀ S₁)
    (G : EffectfulFuture S₁ S₂) :
    EffectfulFuture S₀ S₂ where
  τ := { source := S₀
        , path   := F.τ.path ++ G.τ.path
        , target := S₂ }
  well_formed := ⟨rfl, rfl⟩

/-- The effect of a composite is the effect at the final state.

    `(seq F G).effect = AffordanceSet S₂ = G.effect` — both sides are
    `AffordanceSet S₂` by the derived definition. Holds by `rfl`. -/
theorem EffectfulFuture.seq_effect_right
    {S₀ S₁ S₂ : ParadigmaticState}
    (F : EffectfulFuture S₀ S₁)
    (G : EffectfulFuture S₁ S₂) :
    (EffectfulFuture.seq F G).effect = G.effect := rfl

/-- Substantive associativity of effectful sequencing.

Follows from `List.append_assoc` on the concatenated paths. -/
theorem EffectfulFuture.seq_assoc
    {S₀ S₁ S₂ S₃ : ParadigmaticState}
    (F : EffectfulFuture S₀ S₁)
    (G : EffectfulFuture S₁ S₂)
    (H : EffectfulFuture S₂ S₃) :
    EffectfulFuture.seq (EffectfulFuture.seq F G) H =
    EffectfulFuture.seq F (EffectfulFuture.seq G H) := by
  simp [EffectfulFuture.seq, List.append_assoc]

/-- Left identity law: `id S₀ ; F = F`.

With path concatenation (id has empty path), the trajectories match
by `simp` without needing `endpoint_ext`. -/
theorem EffectfulFuture.seq_left_id
    {S₀ S₁ : ParadigmaticState}
    (F : EffectfulFuture S₀ S₁) :
    EffectfulFuture.seq (EffectfulFuture.id S₀) F = F := by
  apply EffectfulFuture.ext_eq
  ext
  · simp [EffectfulFuture.seq, EffectfulFuture.id, F.well_formed.1]
  · simp [EffectfulFuture.seq, EffectfulFuture.id, List.nil_append]
  · simp [EffectfulFuture.seq, EffectfulFuture.id, F.well_formed.2]

/-- Right identity law: `F ; id S₁ = F`.

v0.2: no `[Subsingleton (Effect S₁)]` needed. The effect is derived
from the type index S₁ and is always `AffordanceSet S₁` for both sides.
Path equality follows from `simp`. -/
theorem EffectfulFuture.seq_right_id
    {S₀ S₁ : ParadigmaticState}
    (F : EffectfulFuture S₀ S₁) :
    EffectfulFuture.seq F (EffectfulFuture.id S₁) = F := by
  apply EffectfulFuture.ext_eq
  ext
  · simp [EffectfulFuture.seq, EffectfulFuture.id, F.well_formed.1]
  · simp [EffectfulFuture.seq, EffectfulFuture.id, List.append_nil]
  · simp [EffectfulFuture.seq, EffectfulFuture.id, F.well_formed.2]

-- ============================================================
-- P4.2: Effectful Computation with Value (Full Indexed Monad)
-- ============================================================

/-- An effectful computation indexed by pre/post states, carrying a value.

    Corresponds to Orchard & Petricek's `M S₀ S₁ A`. The `effect` is
    derived from S₁, not stored. -/
structure EffectfulComputation (S₀ S₁ : ParadigmaticState) (A : Type) where
  /-- The value produced by the computation -/
  value : A
  /-- The trajectory connecting source to target -/
  τ : Trajectory
  /-- Evidence that τ connects S₀ to S₁ -/
  well_formed : τ.source = S₀ ∧ τ.target = S₁

/-- The effect of an effectful computation: the affordance set at S₁.
    Derived from the type index, not stored. -/
def EffectfulComputation.effect {S₀ S₁ : ParadigmaticState} {A : Type}
    (_C : EffectfulComputation S₀ S₁ A) : Set ComposableFuture :=
  AffordanceSet S₁

/-- Extensionality for `EffectfulComputation`.

    v0.2: `heff` removed — effect is derived from type index S₁. -/
theorem EffectfulComputation.ext_eq
    {S₀ S₁ : ParadigmaticState} {A : Type}
    {C₁ C₂ : EffectfulComputation S₀ S₁ A}
    (hval : C₁.value = C₂.value)
    (hτ : C₁.τ = C₂.τ) :
    C₁ = C₂ := by
  cases C₁; cases C₂; subst hval; subst hτ; rfl

/-- The `return` / `pure` operation of the indexed monad.
    Path is empty (no intermediate states). -/
def EffectfulComputation.pure (S : ParadigmaticState) {A : Type} (a : A) :
    EffectfulComputation S S A where
  value := a
  τ := { source := S, path := [], target := S }
  well_formed := ⟨rfl, rfl⟩

/-- The indexed bind operation `>>=`.

    The effect of the result is `AffordanceSet S₂`, derived from S₂.
    v0.2: trajectory paths are concatenated: `F.τ.path ++ (f F.value).τ.path`. -/
def EffectfulComputation.bind
    {S₀ S₁ S₂ : ParadigmaticState} {A B : Type}
    (F : EffectfulComputation S₀ S₁ A)
    (f : A → EffectfulComputation S₁ S₂ B) :
    EffectfulComputation S₀ S₂ B where
  value := (f F.value).value
  τ := { source := S₀, path := F.τ.path ++ (f F.value).τ.path, target := S₂ }
  well_formed := ⟨rfl, rfl⟩

/-- The effect of a bind is the effect at the final state. -/
theorem EffectfulComputation.bind_effect_right
    {S₀ S₁ S₂ : ParadigmaticState} {A B : Type}
    (F : EffectfulComputation S₀ S₁ A)
    (f : A → EffectfulComputation S₁ S₂ B) :
    (EffectfulComputation.bind F f).effect = (f F.value).effect := rfl

/-- Substantive associativity of indexed bind.

Follows from `List.append_assoc` on the concatenated paths. -/
theorem EffectfulComputation.bind_assoc
    {S₀ S₁ S₂ S₃ : ParadigmaticState} {A B C : Type}
    (F : EffectfulComputation S₀ S₁ A)
    (f : A → EffectfulComputation S₁ S₂ B)
    (g : B → EffectfulComputation S₂ S₃ C) :
    EffectfulComputation.bind (EffectfulComputation.bind F f) g =
    EffectfulComputation.bind F (fun a => EffectfulComputation.bind (f a) g) := by
  simp [EffectfulComputation.bind, List.append_assoc]

/-- Left identity: `return a >>= f = f a`.

With path concatenation (pure has empty path), the trajectories match
by `simp` without `endpoint_ext`. -/
theorem EffectfulComputation.bind_left_id
    {S₀ S₁ : ParadigmaticState} {A B : Type}
    (a : A)
    (f : A → EffectfulComputation S₀ S₁ B) :
    EffectfulComputation.bind (EffectfulComputation.pure S₀ a) f = f a := by
  apply EffectfulComputation.ext_eq
  · simp [EffectfulComputation.bind, EffectfulComputation.pure]
  · ext
    · simp [EffectfulComputation.bind, EffectfulComputation.pure, (f a).well_formed.1]
    · simp [EffectfulComputation.bind, EffectfulComputation.pure, List.nil_append]
    · simp [EffectfulComputation.bind, EffectfulComputation.pure, (f a).well_formed.2]

/-- Right identity: `F >>= return = F`.

v0.2: no `[Subsingleton (Effect S₁)]` needed.
Path equality follows from `simp`. -/
theorem EffectfulComputation.bind_right_id
    {S₀ S₁ : ParadigmaticState} {A : Type}
    (F : EffectfulComputation S₀ S₁ A) :
    EffectfulComputation.bind F (EffectfulComputation.pure S₁) = F := by
  apply EffectfulComputation.ext_eq
  · simp [EffectfulComputation.bind, EffectfulComputation.pure]
  · ext
    · simp [EffectfulComputation.bind, EffectfulComputation.pure, F.well_formed.1]
    · simp [EffectfulComputation.bind, EffectfulComputation.pure, List.append_nil]
    · simp [EffectfulComputation.bind, EffectfulComputation.pure, F.well_formed.2]

/-! ## Connection to Affordance Composition (v0.2)

With v0.2, the connection is now structural:

- `EffectfulFuture S₀ S₁` is a transition with effect `AffordanceSet S₁`.
- Sequencing `F : S₀ → S₁` with `G : S₁ → S₂` yields `S₀ → S₂` with
  effect `AffordanceSet S₂` — the futures enabled by the final state.
- This is exactly `seqBind_Φ_eq` from `Core.Affordance`:
  `(F >>= G).Φ = G.Φ`.
- The three Orchard & Petricek (2014) indexed-monad laws all hold:
  `seq_left_id`, `seq_right_id`, `seq_endpoint_assoc` (and the
  bind-level analogues). None require `Subsingleton` guards.
-/

end ComposableFuture

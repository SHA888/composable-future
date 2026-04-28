import ComposableFuture.Core.Future
import ComposableFuture.Core.Affordance

/-! # Effect System Connection (P4.2)

This module formalizes the mapping from affordance set Φ to an effect type
system, establishing the correspondence between affordances and computational
effects.

## Core Insight

In effect systems (Orchard, Petricek, Mycroft 2014; Orchard, Wadler, Eades 2020),
computations carry effect annotations that track what capabilities they require
or produce. For Composable Future:

- **Affordance Φ as effect**: Reaching a paradigmatic state S₁ produces the
  affordance Φ(S₁) as a computational effect — the state "affords" certain
  future transitions.
- **S₁ as effect index**: The target paradigmatic state S₁ serves as the
  effect index. Different states afford different capabilities.
- **Effect sequencing**: Sequential composition of futures corresponds to
  sequencing of affordance effects via `composeSequential`.

## Orchard et al. Indexed Monad Correspondence

Orchard & Petricek (2014) define an indexed monad `M : I → I → Type → Type`
where indices `i, j ∈ I` are pre/post conditions. For Composable Future:

| Orchard & Petricek            | Composable Future                              |
|-------------------------------|------------------------------------------------|
| Index `i` (pre)               | Source paradigmatic state `S₀`                 |
| Index `j` (post)              | Target paradigmatic state `S₁`                 |
| Effect annotation             | Affordance `Φ` at `S₁`                         |
| Indexed sequencing (no value) | `EffectfulFuture.seq` / `EffectfulFuture.id`   |
| Indexed bind `>>=`            | `EffectfulComputation.bind` (value-passing)    |
| Unit `return`                 | `EffectfulComputation.pure`                    |

Orchard & Petricek's `>>=` is the value-passing `M i j A → (A → M j k B) →
M i k B`. `EffectfulFuture.seq` is the value-less sibling (chains indexed
states without an `A → ...` continuation); the full value-passing bind is
`EffectfulComputation.bind`.

The graded monad in `Core.Indexed` uses `TrajectoryType` as the grading
monoid. This module shows that `ParadigmaticState` can serve as an
alternative effect index, with Φ playing the role of the effect annotation.

## Status

v0.1 formalization — all effects collapse to `Unit` because `AffordanceSet` is
a placeholder. Phase 4 will replace `AffordanceSet` with `AffordanceSet.impl`
once the universe level mismatch (Open Problem 1) is resolved.

## Brittleness handling (v0.1 → Phase 4)

The earlier draft of this file silently relied on `Effect S = Unit` in several
places. That dependency is now surfaced explicitly:

- The right-identity laws (`seq_right_id`, `bind_right_id`) require
  `[Subsingleton (Effect S₁)]`. In v0.1, `Subsingleton Unit` discharges this
  automatically; once `Effect` becomes nontrivial under Open Problem 1, the
  instance must either be supplied or the laws weakened — a visible
  obligation rather than a silent breakage.
- The extensionality lemmas and left-identity laws (`ext_eq`, `seq_left_id`,
  `bind_left_id`) do **not** depend on `Effect = Unit`. Their proofs go
  through for any `Effect` via Lean's proof irrelevance for the
  `well_formed` field plus `subst` on the effect equation. Misleading
  comments to the contrary have been removed.
- All four identity proofs still use `Trajectory.endpoint_ext`, which is the
  v0.1 endpoint-determination fact. Phase 2's trajectory enrichment will
  invalidate that lemma, so each call site is pre-flagged by the deliberate
  name.
-/

namespace ComposableFuture

-- ============================================================
-- P4.2: Effect System Connection
-- ============================================================

/-- An effect annotation at a paradigmatic state.

    In the Composable Future theory, the natural effect annotation is the
    affordance set at that state. We use the placeholder `AffordanceSet`
    (Type 0) for the main definitions; the richer `AffordanceSet.impl`
    (Type 1) is the intended representation once universe levels are
    reconciled (Open Problem 1, Phase 4). -/
abbrev Effect (S : ParadigmaticState) : Type := AffordanceSet S

/-- The trivial effect at any state under the placeholder.
    This will become the actual affordance descriptor when universe levels
    are unified. -/
def Effect.at (S : ParadigmaticState) : Effect S := ()

/-- An effectful future is an indexed computation from `S₀` to `S₁` with
    an effect annotation at `S₁`.

    This corresponds to an indexed computation in Orchard & Petricek's
    framework: the indices are the pre-state `S₀` and post-state `S₁`,
    and the effect annotation is the affordance at `S₁`.

    The type indices `S₀` and `S₁` ensure that effectful futures are only
    composed when the intermediate states match — exactly the same type
    safety provided by `composeSequential` for affordances. -/
structure EffectfulFuture (S₀ S₁ : ParadigmaticState) where
  /-- The trajectory connecting source to target -/
  τ : Trajectory
  /-- Evidence that τ connects S₀ to S₁ -/
  well_formed : τ.source = S₀ ∧ τ.target = S₁
  /-- The effect annotation at the target state -/
  effect : Effect S₁

/-- Identity effectful future: stay at state S with trivial effect.

    This corresponds to `return` in the indexed monad: a computation
    that does nothing and produces no new effect. -/
def EffectfulFuture.id (S : ParadigmaticState) : EffectfulFuture S S where
  τ := { source := S, target := S }
  well_formed := ⟨rfl, rfl⟩
  effect := Effect.at S

/-- Extensionality for EffectfulFuture: equal trajectory and equal effect imply
    equal records.

    This proof is **independent** of the v0.1 `Effect = Unit` placeholder:
    `subst heff` substitutes one effect variable for the other regardless of
    the type, and the residual `well_formed` field equality discharges by
    proof irrelevance (the field is a `Prop`). The lemma will continue to
    hold under Open Problem 1's upgrade of `AffordanceSet`. -/
theorem EffectfulFuture.ext_eq {F₁ F₂ : EffectfulFuture S₀ S₁}
    (hτ : F₁.τ = F₂.τ)
    (heff : F₁.effect = F₂.effect) :
    F₁ = F₂ := by
  cases F₁
  cases F₂
  subst hτ
  subst heff
  rfl

/-- Sequential composition of effectful futures.

    Given F : S₀ → S₁ and G : S₁ → S₂, produce F ; G : S₀ → S₂.

    This is the indexed bind operation: the effect of the composite is the
    effect at the final state S₂. This captures the intuition that the
    affordance available after the entire sequence is determined by the
    final state reached.

    Type-correctness is enforced by the indices: G's source must equal
    F's target, matching the `composeSequential` well-typedness discipline.

    Note: trajectory data from `F.τ` and `G.τ` is dropped — only the endpoints
    are preserved. This is intentional and mirrors `composeSequential` in
    `Core.Affordance` (see Affordance.lean:111–114). Concrete trajectory
    composition would require a richer trajectory model (Phase 2). -/
def EffectfulFuture.seq
    {S₀ S₁ S₂ : ParadigmaticState}
    (_F : EffectfulFuture S₀ S₁)
    (G : EffectfulFuture S₁ S₂) :
    EffectfulFuture S₀ S₂ where
  τ := { source := S₀, target := S₂ }
  well_formed := ⟨rfl, rfl⟩
  effect := G.effect

/-- Definitional sanity check: by construction `(seq F G).effect = G.effect`.

    `EffectfulFuture.seq` is *defined* with `effect := G.effect` (line 131),
    so this closes by `rfl`. The lemma exists to confirm the definition
    matches the intended "effect of the composite is the affordance at the
    final state" reading — it is **not** a substantive theorem about how
    affordances actually propagate through sequential composition. The
    substantive version requires affordance composition `Φ ∘ Φ'` (Open
    Problem 4, Phase 4); see `Affordance.composeSequential` for the
    descriptor-level analogue. -/
theorem EffectfulFuture.seq_effect_right
    {S₀ S₁ S₂ : ParadigmaticState}
    (F : EffectfulFuture S₀ S₁)
    (G : EffectfulFuture S₁ S₂) :
    (EffectfulFuture.seq F G).effect = G.effect := rfl

/-- Endpoint-extraction associativity of effectful sequencing.

    This is **not** the substantive paradigm-composition associativity. The
    v0.1 `EffectfulFuture.seq` discards both input trajectories and rebuilds
    `{source := S₀, target := S₃}` from the type indices alone (note `_F` is
    unused in the `seq` body). Both sides of the equation therefore reduce
    to the same record by definitional equality.

    What this theorem actually says: "endpoint extraction is associative."
    What it does **not** say: "effectful trajectory composition is
    associative."

    The substantive version requires `Trajectory` to carry an internal path
    so that `seq` concatenates trajectory data non-trivially, with the
    proof following from `List.append_assoc`. This is the open Phase 2
    refactor; see `Laws.seqBind_endpoint_assoc` for the parallel statement
    on plain `ComposableFuture` and `proofs/attempt-associativity.md` for
    design history. -/
theorem EffectfulFuture.seq_endpoint_assoc
    {S₀ S₁ S₂ S₃ : ParadigmaticState}
    (F : EffectfulFuture S₀ S₁)
    (G : EffectfulFuture S₁ S₂)
    (H : EffectfulFuture S₂ S₃) :
    EffectfulFuture.seq (EffectfulFuture.seq F G) H =
    EffectfulFuture.seq F (EffectfulFuture.seq G H) := rfl

/-- Left identity law for effectful futures.

    id(S₀) ; F = F

    The identity future at S₀ has trivial effect; sequencing it before F
    leaves F's effect unchanged.

    Effect-side robustness: by the definition of `seq`, the composite's
    effect is `F.effect`, so the effect equation reduces to `F.effect =
    F.effect` — closing by `rfl` regardless of the structure of `Effect`.
    Trajectory side still depends on v0.1 `Trajectory.endpoint_ext`. -/
theorem EffectfulFuture.seq_left_id
    {S₀ S₁ : ParadigmaticState}
    (F : EffectfulFuture S₀ S₁) :
    EffectfulFuture.seq (EffectfulFuture.id S₀) F = F := by
  apply EffectfulFuture.ext_eq
  · -- trajectory equality (v0.1 endpoint-determination)
    simp [EffectfulFuture.seq]
    have h1 := F.well_formed.1
    have h2 := F.well_formed.2
    apply Trajectory.endpoint_ext
    · exact h1.symm
    · exact h2.symm
  · -- effect equality holds for any `Effect` (composite preserves F.effect)
    exact rfl

/-- Right identity law for effectful futures.

    F ; id(S₁) = F

    Sequencing F with the identity at S₁ leaves F unchanged. The composite's
    effect is `id(S₁).effect = Effect.at S₁`, which equals `F.effect` only
    when `Effect S₁` has at most one inhabitant — captured by the explicit
    `Subsingleton (Effect S₁)` instance argument.

    In v0.1 the instance is automatic since `Effect S = Unit`. Once Open
    Problem 1 upgrades `AffordanceSet` to a non-singleton type, callers
    will have to either provide a `Subsingleton` witness or weaken the
    statement (e.g. relate the composite's effect to `F.effect` only up
    to a chosen coherence). The bracketed `[Subsingleton (Effect S₁)]`
    makes that future obligation visible at the type level. -/
theorem EffectfulFuture.seq_right_id
    {S₀ S₁ : ParadigmaticState}
    [Subsingleton (Effect S₁)]
    (F : EffectfulFuture S₀ S₁) :
    EffectfulFuture.seq F (EffectfulFuture.id S₁) = F := by
  apply EffectfulFuture.ext_eq
  · -- trajectory equality (v0.1 endpoint-determination)
    simp [EffectfulFuture.seq]
    have h1 := F.well_formed.1
    have h2 := F.well_formed.2
    apply Trajectory.endpoint_ext
    · exact h1.symm
    · exact h2.symm
  · -- effect equality from the explicit `Subsingleton` instance
    exact Subsingleton.elim _ _

/-! ## Effectful Computation with Value (Full Indexed Monad)

The definitions above model effectful transitions without an explicit value.
To complete the correspondence with Orchard & Petricek's indexed monad
`M i j A`, we introduce a value parameter `A`. -/

/-- An effectful computation indexed by pre/post states, carrying a value.

    This is the full indexed monad structure `M S₀ S₁ A` corresponding
    to Orchard & Petricek (2014):
    - Pre-state S₀ = index `i`
    - Post-state S₁ = index `j`
    - Value type A = the computation's result
    - Effect at S₁ = the affordance annotation

    In the Composable Future theory, the "value" of a computation is the
    trajectory itself (the paradigmatic transition achieved). -/
structure EffectfulComputation (S₀ S₁ : ParadigmaticState) (A : Type) where
  /-- The value produced by the computation -/
  value : A
  /-- The trajectory connecting source to target -/
  τ : Trajectory
  /-- Evidence that τ connects S₀ to S₁ -/
  well_formed : τ.source = S₀ ∧ τ.target = S₁
  /-- The effect annotation at the target state -/
  effect : Effect S₁

/-- Extensionality for `EffectfulComputation`: equal value, trajectory, and effect
    imply equal records.

    Like `EffectfulFuture.ext_eq`, this proof is **independent** of the v0.1
    `Effect = Unit` placeholder — `subst heff` substitutes one effect
    variable for the other regardless of the type, with the residual
    `well_formed` field equality discharged by proof irrelevance. -/
theorem EffectfulComputation.ext_eq {C₁ C₂ : EffectfulComputation S₀ S₁ A}
    (hval : C₁.value = C₂.value)
    (hτ : C₁.τ = C₂.τ)
    (heff : C₁.effect = C₂.effect) :
    C₁ = C₂ := by
  cases C₁
  cases C₂
  subst hval
  subst hτ
  subst heff
  rfl

/-- The `return` / `pure` operation of the indexed monad.

    Produces a trivial computation that stays at S and returns `a`,
    with the trivial effect at S. -/
def EffectfulComputation.pure (S : ParadigmaticState) (a : A) :
    EffectfulComputation S S A where
  value := a
  τ := { source := S, target := S }
  well_formed := ⟨rfl, rfl⟩
  effect := Effect.at S

/-- The indexed bind operation `>>=`.

    Sequences an effectful computation F : S₀ → S₁ with a function that
    produces a new effectful computation from F's value. The result is
    a computation from S₀ to S₂ whose effect is the effect of the second
    computation (at S₂).

    This is the standard indexed monad bind, specialized to the Composable
    Future effect model.

    Note: as in `EffectfulFuture.seq`, only trajectory endpoints are preserved
    (Phase 2 trajectory model would change this). -/
def EffectfulComputation.bind
    {S₀ S₁ S₂ : ParadigmaticState} {A B : Type}
    (F : EffectfulComputation S₀ S₁ A)
    (f : A → EffectfulComputation S₁ S₂ B) :
    EffectfulComputation S₀ S₂ B where
  value := (f F.value).value
  τ := { source := S₀, target := S₂ }
  well_formed := ⟨rfl, rfl⟩
  effect := (f F.value).effect

/-- Definitional sanity check: by construction `(bind F f).effect = (f F.value).effect`.

    `EffectfulComputation.bind` is *defined* with `effect := (f F.value).effect`
    (line 277), so this closes by `rfl`. As with `seq_effect_right`, this
    confirms the definition matches the intended reading and is not a
    substantive theorem about how affordances propagate through indexed
    bind. -/
theorem EffectfulComputation.bind_effect_right
    {S₀ S₁ S₂ : ParadigmaticState} {A B : Type}
    (F : EffectfulComputation S₀ S₁ A)
    (f : A → EffectfulComputation S₁ S₂ B) :
    (EffectfulComputation.bind F f).effect = (f F.value).effect := rfl

/-- Endpoint-extraction associativity of indexed bind:
    `(F >>= f) >>= g = F >>= (fun a => f a >>= g)`.

    Same caveat as `EffectfulFuture.seq_endpoint_assoc`: closes by `rfl`
    because `EffectfulComputation.bind` discards input trajectory data and
    rebuilds endpoints from the type indices. The substantive claim — that
    indexed bind is associative on real (path-carrying) trajectories — is
    the Phase 2 refactor. Stated here for completeness: with this lemma
    plus `bind_left_id` and `bind_right_id`, the three indexed-monad laws
    of Orchard & Petricek (2014) all hold at the endpoint level. -/
theorem EffectfulComputation.bind_endpoint_assoc
    {S₀ S₁ S₂ S₃ : ParadigmaticState} {A B C : Type}
    (F : EffectfulComputation S₀ S₁ A)
    (f : A → EffectfulComputation S₁ S₂ B)
    (g : B → EffectfulComputation S₂ S₃ C) :
    EffectfulComputation.bind (EffectfulComputation.bind F f) g =
    EffectfulComputation.bind F (fun a => EffectfulComputation.bind (f a) g) := rfl

/-- Left identity law for the indexed monad: `return a >>= f = f a`.

    Effect-side robustness: as in `seq_left_id`, the bind's definition makes
    the composite's effect equal to `(f a).effect`, so the effect equation
    reduces to `(f a).effect = (f a).effect` and closes by `rfl` for any
    `Effect`. Trajectory side still depends on v0.1 `Trajectory.endpoint_ext`. -/
theorem EffectfulComputation.bind_left_id
    {S₀ S₁ : ParadigmaticState} {A B : Type}
    (a : A)
    (f : A → EffectfulComputation S₀ S₁ B) :
    EffectfulComputation.bind (EffectfulComputation.pure S₀ a) f = f a := by
  apply EffectfulComputation.ext_eq
  · -- value equality
    simp [EffectfulComputation.bind, EffectfulComputation.pure]
  · -- trajectory equality (v0.1 endpoint-determination)
    simp [EffectfulComputation.bind, EffectfulComputation.pure]
    have h1 := (f a).well_formed.1
    have h2 := (f a).well_formed.2
    apply Trajectory.endpoint_ext
    · exact h1.symm
    · exact h2.symm
  · -- effect equality holds for any `Effect` (composite preserves `(f a).effect`)
    exact rfl

/-- Right identity law for the indexed monad: `F >>= return = F`.

    As with `EffectfulFuture.seq_right_id`, the composite's effect is
    `(pure S₁ F.value).effect = Effect.at S₁`, which equals `F.effect`
    only when `Effect S₁` is a subsingleton. The explicit
    `[Subsingleton (Effect S₁)]` instance argument surfaces that
    obligation; v0.1's `Effect = Unit` discharges it automatically. -/
theorem EffectfulComputation.bind_right_id
    {S₀ S₁ : ParadigmaticState} {A : Type}
    [Subsingleton (Effect S₁)]
    (F : EffectfulComputation S₀ S₁ A) :
    EffectfulComputation.bind F (EffectfulComputation.pure S₁) = F := by
  apply EffectfulComputation.ext_eq
  · -- value equality
    simp [EffectfulComputation.bind, EffectfulComputation.pure]
  · -- trajectory equality (v0.1 endpoint-determination)
    simp [EffectfulComputation.bind, EffectfulComputation.pure]
    have h1 := F.well_formed.1
    have h2 := F.well_formed.2
    apply Trajectory.endpoint_ext
    · exact h1.symm
    · exact h2.symm
  · -- effect equality from the explicit `Subsingleton` instance
    exact Subsingleton.elim _ _

/-! ## Connection to Affordance Composition

The `composeSequential` operator from `Core.Affordance` chains affordances:
- φ₁ : AffordanceDescriptor S₀  (S₀ affords reaching some S₁)
- φ₂ : AffordanceDescriptor S₁  (S₁ affords reaching some S₂)
- → composeSequential φ₁ φ₂ : AffordanceDescriptor S₀  (S₀ affords reaching S₂)

This is isomorphic to effect sequencing: the composed affordance describes
what S₀ affords *indirectly*, which is determined by the affordances at the
final state S₂.

The type-safe indexing by `S₁` in both `EffectfulFuture` and
`composeSequential` ensures that effects/affordances are only composed
when the intermediate states match. -/

end ComposableFuture

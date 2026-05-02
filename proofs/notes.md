# Proof Notes — Composable Future

This file contains running informal proof attempts, conjectures, and partial results
as we work through the formalization in Lean 4.

## Current Open Problems (Numbered)

### Phase 1 Open Problems (All sorry statements)

**Open Problem 1: Affordance set structure (Phase 4)**
- **Location**: `AffordanceSet (S : ParadigmaticState) : Type`
- **Issue**: Need to define what affordance sets actually are
- **Approach**: Dependent types or indexed families
- **Status**: Phase 4 target

**Open Problem 2: State product structure (Phase 2)**
- **Location**: `parTensor.S₀`, `parTensor.S₁`, `merge.S₀`
- **Issue**: How to combine two paradigmatic states into a product
- **Approach**: Cartesian product of Type components
- **Status**: Phase 2 target

**Open Problem 3: Parallel trajectory composition (Phase 2)**
- **Location**: `parTensor.τ`, `merge.τ`
- **Issue**: How trajectories compose in parallel
- **Approach**: Product of source/target trajectories
- **Status**: Phase 2 target

**Open Problem 4: Sum type for trajectories (Phase 2)**
- **Location**: `fork.τ`
- **Issue**: How to represent branching trajectories
- **Approach**: Sum type `Trajectory F.τ + Trajectory G.τ`
- **Status**: Phase 2 target

**Open Problem 5: Sum type for states (Phase 2)**
- **Location**: `fork.S₁`
- **Issue**: How to represent branching target states
- **Approach**: Sum type `F.S₁ + G.S₁`
- **Status**: Phase 2 target

**Open Problem 6: Affordance union operation (Phase 4)**
- **Location**: `fork.Φ`, `merge.Φ`
- **Issue**: How to combine affordance sets from branching
- **Approach**: Union operation on affordance sets
- **Status**: Phase 4 target

**Open Problem 7: State merge operation (Phase 2)**
- **Location**: `merge.S₁`
- **Issue**: How two independent futures reconverge
- **Approach**: Requires compatibility conditions on target states
- **Status**: Phase 2 target

**Open Problem 8: Empty affordance set (Phase 4)**
- **Location**: `idFuture.Φ`
- **Issue**: What affordances are available from identity future
- **Approach**: Empty set or minimal affordance set
- **Status**: Phase 4 target

**Open Problem 9: Left identity proof**
- **Location**: `left_identity` theorem
- **Issue**: Prove `Id >>= F = F`
- **Status**: Requires Open Problem 8 completion
- **Dependencies**: OP8

**Open Problem 10: Right identity proof**
- **Location**: `right_identity` theorem
- **Issue**: Prove `F >>= Id = F`
- **Status**: Requires Open Problem 8 completion
- **Dependencies**: OP8

**Open Problem 11: Closure proof** ✅ RESOLVED
- **Location**: `closure` theorem
- **Issue**: Prove sequential composition produces valid future
- **Status**: ✅ Resolved — trivial existence proof (`⟨seqBind F G h, rfl⟩`)
- **Note**: The meaningful closure property is well-formedness preservation (OP12)

**Open Problem 12: Well-formedness preservation proof** ✅ RESOLVED
- **Location**: `seqBind_well_formed` theorem
- **Issue**: Prove `seqBind` preserves well-formed futures
- **Status**: ✅ Resolved — proved by `simp [seqBind, ComposableFuture.well_formed]` then `constructor` with `exact hF.1` and `exact hG.2`
- **Dependencies**: None

**Open Problem 13: Probabilistic trajectory definition (Phase 3)**
- **Location**: `ProbabilisticTrajectory` type
- **Issue**: Define probabilistic transitions between states
- **Approach**: Markov kernels or probability distributions
- **Status**: Phase 3 target

**Open Problem 14: Kleisli composition for probabilistic trajectories (Phase 3)**
- **Location**: `kleisliBind` function
- **Issue**: Define composition of probabilistic trajectories
- **Approach**: Standard Kleisli composition
- **Status**: Phase 3 target

**Open Problem 15: Probabilistic associativity proof**
- **Location**: `prob_assoc` theorem
- **Issue**: Prove Kleisli associativity for probabilistic trajectories
- **Status**: Known result, should be straightforward
- **Dependencies**: OP14

**Open Problem 16: Probabilistic identity proof**
- **Location**: `prob_id` theorem
- **Issue**: Prove identity law for probabilistic trajectories
- **Status**: Known result, should be straightforward
- **Dependencies**: OP14

**Open Problem 17: Empty affordance set for indexed identity**
- **Location**: `IndexedFuture.idFuture.Φ`
- **Issue**: What affordance set should the identity future have in the indexed monad?
- **Status**: Requires affordance set structure definition (OP1)
- **Dependencies**: OP1

## Phase 2 Status Summary
- ⚠ **Endpoint-extraction associativity proved** (`Laws.seqBind_endpoint_assoc`):
  holds for all futures by definitional equality of `seqBind`. This is **not**
  paradigm-trajectory composition associativity — it is the weaker statement
  that endpoint pairing is associative. The v0.1 `seqBind` extracts only
  endpoints and discards trajectory data, so `rfl` closes the proof for
  reasons unrelated to the substantive theorem. The substantive version is
  the open Phase 2 refactor (see "Open: Substantive Associativity" below).
- ⚠ **Stateless restriction proved** (`Stateless.assoc_stateless_endpoint`):
  same caveat; restricted to the (currently vacuous) stateless subtype.
- ⚠ **Indexed/graded scaffolding** (`Indexed.lean`):
  - `TrajectoryType := Unit` (subsingleton — Phase 2 will promote to free monoid)
  - `TrajectoryTypeCompose` instance laws hold trivially by `rfl`
  - `IndexedFuture.endpoint_assoc` proved, with the same endpoint caveat
- ✅ **Weak associativity theorems proved** (`WeakAssoc.lean`) — these are
  honest as stated:
  - `weak_assoc_affordance`: associativity at affordance level
  - `weak_assoc_states`: associativity at state level

## Open: Substantive Associativity (Phase 2 refactor)

The path-composition version of `seqBind` requires `Trajectory` to carry an
internal path. Sketch:

```lean
structure Trajectory where
  source : ParadigmaticState
  target : ParadigmaticState
  path   : List ParadigmaticState   -- intermediate stages

def seqBind F G h : ComposableFuture :=
  { S₀ := F.S₀
    τ  := { source := F.τ.source
          , target := G.τ.target
          , path   := F.τ.path ++ [F.S₁] ++ G.τ.path }
    S₁ := G.S₁
    Φ  := G.Φ }
```

Then `(F >>= G) >>= H` and `F >>= (G >>= H)` produce the same `path`
*non-trivially* (both equal `F.τ.path ++ [F.S₁] ++ G.τ.path ++ [G.S₁] ++
H.τ.path` by `List.append_assoc`). This proves the substantive theorem
that the paper's narrative claims.

## Phase 1 Status Summary
- ✅ Types defined: ParadigmaticState, Trajectory, ComposableFuture
- ✅ Operators defined: >>=, ⊗, |, ⊕, Id (all with sorry stubs)
- ✅ Laws stated: identity, closure, well-formedness preservation
- ✅ All sorry statements documented with open problem numbers
- ✅ Build passes: `lake build` successful

## Key Insights

### Sequential Composition Structure
The `seqBind` operator correctly preserves the source state and passes through the target affordances. The trajectory composition assumes well-formedness of inputs.

### Well-Formedness is Central
The `well_formed` predicate ensures trajectories match their states. This is crucial for preventing invalid compositions.

### Phase Dependencies
- Phase 2: State structure and trajectory composition
- Phase 3: Probabilistic extension  
- Phase 4: Affordance set structure and operations

## Next Steps
1. **Phase 2.4**: Gate check — document outcome (proof OR counterexample OR indexed resolution) ✅ COMPLETE
2. **Phase 3**: Complete probabilistic extension (OP13-OP16)
3. **Phase 4**: Define affordance set structure (OP1, OP6, OP8, OP17) and complete law proofs
4. **Future**: Complete indexed monad monoid law proofs after trajectory refactor

## OP2 Resolution — Φ Well-Definedness Before S₁ Realization

**Status**: ✅ RESOLVED — formally stated and proved in `Core/Affordance.lean`.

**Problem**: Turvey (1992) notes that affordances are dispositional — potential before actual. But Composable Future requires Φ to be a well-defined typed function at the time of composition, before S₁ is concretely realized. Can Φ be defined at the type level (as a specification of what S₁ *could* produce) without requiring S₁ to be concretely instantiated?

**Resolution**: Yes. Φ is a dependent type `AffordanceSet S₀ : Type` that exists independently of any concrete realization of S₁. The relationship between pre-realization (type-level) and post-realization (value-level) affordances is formalized by a canonical map.

### Formal Statement

Definitions in `Core/Affordance.lean`:

- `PreRealizedAffordance S₀ : Type` := `AffordanceSet S₀`
  - A type-level specification of what S₀ affords (the "modal" view).
  - At v0.1 this is `Unit`; Phase 4 will promote it to a non-trivial dependent type.

- `PostRealizedAffordance S₀ : Type 1` := `List (AffordanceDescriptor S₀)`
  - A value-level list of concrete affordances that were actually available (the "actual" view).

- `pre_post_correspondence : PostRealizedAffordance S₀ → PreRealizedAffordance S₀`
  - The canonical map from concrete realizations to type-level specifications.
  - Many-to-one: multiple concrete lists may satisfy the same specification.

### Key Theorems

| Theorem | File | Meaning |
|---------|------|---------|
| `instance pre_realized_is_well_defined` | `Core/Affordance.lean` | `PreRealizedAffordance S` is inhabited for every state |
| `theorem pre_post_correspondence_surjective` | `Core/Affordance.lean` | Every pre-realization is realized by some post-realization |
| `theorem pre_post_correspondence_many_to_one` | `Core/Affordance.lean` | The map is non-injective (abstraction is intentional) |

### Why This Resolves OP2

The indexed monad in `Core/Effect.lean` requires `Effect S₁` (the affordance set at the target state) to be available at *type-check time* for `bind` operations. `pre_realized_is_well_defined` guarantees that this type exists and is inhabited for any S₁, even before S₁ is concretely constructed. The bind operation does not need a concrete list of affordances — it only needs the type `Effect S₁`, which is well-defined by the structure of the paradigmatic state type system.

Post-realization (the concrete `List (AffordanceDescriptor S₀)`) is a refinement of pre-realization, not a prerequisite for it. This mirrors Chemero's ecological affordances: relations between organism and environment exist prior to actualization.

### Falsifying Conditions

The resolution is falsified if any of these hold:

1. **`pre_realized_is_well_defined` fails**: Some paradigmatic state S has `Inhabited (PreRealizedAffordance S)` false. Then `Effect S` would be uninhabited, making `EffectfulComputation.bind` impossible to type-check for transitions into S.

2. **`pre_post_correspondence_surjective` fails**: Some pre-realization has no post-realization that maps to it. Then the type-level specification would be unrealizable — a paradigmatic state that *should* afford something but has no concrete trajectories that witness it.

3. **`pre_post_correspondence` is injective**: If the map were one-to-one, pre-realization would encode as much information as post-realization, collapsing the distinction and making pre-realization require post-realization (the original problem).

4. **`PreRealizedAffordance` requires `S₁` value**: If the type `PreRealizedAffordance S₀` were defined in terms of a concrete value of `S₁`, it would not be available at composition time. The dependent-type formulation `Π(S : ParadigmaticState), Type` avoids this by making the type a *function* of the state type, not a value of the state.

### Connection to Indexed Monad

In `Core/Effect.lean`, `EffectfulComputation.bind` has the type:

```lean
EffectfulComputation S₀ S₁ A → (A → EffectfulComputation S₁ S₂ B) → EffectfulComputation S₀ S₂ B
```

The `S₁` in the continuation `A → EffectfulComputation S₁ S₂ B` is a *type*, not a value. The bind operation is well-typed precisely because `Effect S₁` (the affordance set type at `S₁`) is defined as a dependent type over `S₁ : ParadigmaticState`, not as a value-level computation. `pre_realized_is_well_defined S₁` guarantees `Effect S₁` is inhabited, so the continuation can be applied.

---

## P3.2 — Connection to Furter et al. (2025)

**Background**: Furter et al. (2025) extend symmetric monoidal categories with *compositional uncertainty* via Markov kernels. Their work provides a categorical treatment of probabilistic open systems, where morphisms are stochastic transitions between state spaces and composition is via the Kleisli category of a probability monad. Their symmetric monoidal structure supports both sequential and parallel composition of uncertain transitions.

### Mapping to Composable Future

The correspondence between Furter et al.'s SMC framework and Composable Future is:

| Furter et al. | Composable Future |
|---|---|
| Objects (state spaces) | `ParadigmaticState` values |
| Morphisms (open systems) | `ComposableFuture` 4-tuples |
| Markov kernels τ : A → Dist(B) | `ProbabilisticTrajectory α β = α → PMF β` |
| Sequential composition (Kleisli) | `kleisliBind` / `seqBind` |
| Parallel/monoidal tensor ⊗ | `parTensor` / `paradigmaticTensor` |
| Change-of-base (deterministic→stochastic) | `detToProb` (Dirac delta embedding) |
| Monoidal unit | `idFuture` / `probId` |

### Key Question from TODO P3.2

Can paradigmatic trajectories be modeled as open systems?

**Answer**: Yes, with the following interpretation:
- A paradigmatic trajectory τ maps elements of S₀'s state space to distributions over S₁'s state space, making it a Markov kernel.
- The paradigmatic state (S₀.assumptions × S₀.constraints × S₀.infrastructure = `ParadigmaticState.toType S₀`) plays the role of the state space.
- The affordance set Φ at S₁ captures the "output interface" of the open system (what the system produces/enables).
- Furter et al.'s open systems have explicit input/output wiring; paradigmatic trajectories abstract this into the S₀ → S₁ typing.

### What Furter et al. Provide that Composable Future Uses

- The Kleisli category of `PMF` (probability monad) forms the substrate for `ProbabilisticTrajectory`.
- Their Theorem 3 (Kleisli composition associativity) is instantiated as `kleisli_assoc` in `Core/Probabilistic.lean`.
- The `detToProb` change-of-base (deterministic → probabilistic) mirrors their "deterministic morphism embedding" into the Markov category.
- `detToProb_id` and `detToProb_comp` establish functoriality (the embedding is a strict monoidal functor from the deterministic to the probabilistic setting).

### What Composable Future Extends Beyond Furter et al.

- The affordance set Φ at S₁ adds a *capability* layer not present in their pure-trajectory framework.
- The paradigmatic state carries semantic structure (assumptions, constraints, infrastructure) rather than being an abstract set.
- The fork `|` and merge `⊕` operators handle branching/converging paradigmatic paths, which Furter et al. address via their monoidal structure but not at the level of paradigm-specific branching.

### Status

P3.2 is now documented. The formal Lean connection is via:
- `ProbabilisticTrajectory` in `Core/Probabilistic.lean` (Markov kernels)
- `kleisliBind` + `kleisli_assoc` (Kleisli composition + associativity)
- `detToProb` + functoriality theorems (change-of-base)

### Remaining Gap

A full categorical equivalence theorem (showing ComposableFuture is a full subcategory of Furter et al.'s SMC of Markov kernels) requires the Phase 2 trajectory enrichment (giving `Trajectory` an internal path), which is deferred.

---

## OP1 Universe Mismatch — Path Forward (P4.4)

### The Problem

`AffordanceSet S` is currently defined as `Unit` (in `Type 0`) in `Core/Future.lean`, while the richer representation `AffordanceDescriptor S` (in `Core/Affordance.lean`) lives in `Type 1` because `ParadigmaticState` has `Type`-valued fields (`assumptions : Type`, etc.), making:
- `ParadigmaticState : Type 1` (contains `Type 0` values)
- `AffordanceDescriptor S₀ : Type 1` (contains a `ParadigmaticState` field)

### Why It Cannot Be Trivially Fixed

Simply replacing `AffordanceSet S := Unit` with `AffordanceSet S := AffordanceDescriptor S` would:
1. Make `ComposableFuture.Φ : AffordanceDescriptor S₁` (Type 1) — fine structurally.
2. Require all `Φ := ()` uses to become `Φ := AffordanceDescriptor.selfLoop S₁` — mechanical.
3. **Break the identity laws**: `right_identity` proves `seqBind F (idFuture F.S₁) h = F`, which requires `(idFuture F.S₁).Φ = F.Φ`. With `Φ = Unit`, both are `()`. With richer Φ, `idFuture.Φ` would be a self-loop affordance, not necessarily equal to `F.Φ`.

The identity laws break because they conflate the affordance of the identity future with the affordance of F — a property that only holds when all affordances are equal (i.e., `Φ = Unit`).

### The Correct Fix (Requiring Type-Theory Collaborator)

1. **Redesign `seqBind`** to preserve F's affordance when composing with the identity:
   - Either `seqBind F G h` carries both F.Φ and G.Φ (and identity laws select the right one).
   - Or `idFuture` takes the affordance as a parameter: `idFuture (S : ParadigmaticState) (Φ : AffordanceSet S) : ComposableFuture`.

2. **Universe-polymorphic `ParadigmaticState`**: Replace `assumptions : Type` with `assumptions : Type u` for a universe variable `u`, making `ParadigmaticState.{u}` and `AffordanceDescriptor.{u}` universe-polymorphic. All laws then hold at every universe level.

3. **Alternative: `Fintype`-bounded components**: Replace `assumptions : Type` with `assumptions : Finset String` (or a `Fintype` class), keeping everything in `Type 0`. This sacrifices the full generality of the theory but resolves the mismatch.

### Current Status

v0.1 uses `AffordanceSet S = Unit` as a placeholder. The theorems in `Core/Effect.lean` use `[Subsingleton (Effect S₁)]` as an explicit hypothesis to document exactly where the Unit-singleton assumption is needed (right-identity laws). When OP1 is resolved, these call sites will surface the obligation.

### Falsifying the Current v0.1 Laws

The `right_identity` and `seq_right_id` / `bind_right_id` laws are valid under `Subsingleton (Effect S₁)`. They will need to be reformulated once `Effect = AffordanceSet` becomes non-trivial. The reformulation is:

```lean
-- New right identity (general):
theorem right_identity_general (F : ComposableFuture) (hF : F.well_formed)
    (hΦ : F.Φ = (idFuture F.S₁).Φ) :
    seqBind F (idFuture F.S₁) (by rfl) = F
```

where `hΦ` encodes the compatibility of affordances.

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

**Open Problem 12: Well-formedness preservation proof**
- **Location**: `seqBind_well_formed` theorem
- **Issue**: Prove `seqBind` preserves well-formed futures
- **Status**: Straightforward given well-formedness definitions
- **Dependencies**: None (should be provable now)

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
- ✅ Stateless case associativity proved (`Stateless.lean` — definitional equality)
- ✅ Indexed monad construction implemented (`Indexed.lean`):
  - `TrajectoryType` as grading monoid
  - `TrajectoryTypeCompose` typeclass with associativity/identity laws
  - `IndexedFuture t` graded by trajectory type
  - `IndexedFuture.assoc` theorem using cast with monoid law
- ✅ Weak associativity theorems proved (`WeakAssoc.lean`):
  - `weak_assoc_affordance`: associativity at affordance level
  - `weak_assoc_states`: associativity at state level
- ⏳ Monoid law proofs have `sorry` placeholders (pending trajectory refactor)

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

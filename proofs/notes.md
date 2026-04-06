# Proof Notes — Composable Future

This file contains running informal proof attempts, conjectures, and partial results
as we work through the formalization in Lean 4.

## Current Understanding

### Phase 1 Status
- Basic types defined: ParadigmaticState, Trajectory, ComposableFuture
- Operators defined with stubs: >>=, ⊗, |, ⊕
- Laws stated with sorry: identity, closure, associativity
- Probabilistic extension stubbed

### Key Open Problems

#### OP1: Associativity under path-dependent τ
- **Candidate resolution**: Orchard et al.'s indexed monad framework
- **Status**: Need to formalize path-dependence as effect index
- **Next step**: Define IndexedFuture structure

#### OP2: Well-definedness of Φ before S₁ realization  
- **Approach**: Dependent types - Φ as type-level function
- **Status**: Phase 4 target
- **Next step**: Formalize AffordanceSet as dependent type

#### OP3: Correct equivalence relation
- **Candidates**: Bisimulation, history-preserving bisimulation, paradigm-specific
- **Status**: Need to test each against identity/closure laws
- **Next step**: Define equivalence relation and test laws

#### OP4: Composition of affordance sets
- **Prior**: Şahin et al. show affordance chaining in robotics
- **Status**: Phase 4 target
- **Next step**: Define tensor product on states and affordance composition

#### OP5: Completeness
- **Question**: Are all paradigmatic futures reachable by finite composition?
- **Status**: Unresolved
- **Next step**: Formalize completeness property

## Partial Results

### Sequential Bind Well-Formedness
The `seqBind` operator preserves well-formedness when the compatibility condition
`F.S₁ = G.S₀` holds. This follows directly from the definition.

### Parallel Tensor Structure
The `⊗` operator creates a product state structure that preserves the independence
of component futures. The affordance set becomes a product of affordances.

### Probabilistic Extension
The Kleisli construction for probabilistic trajectories is known to be associative
(standard result). The challenge is mapping this to paradigmatic states.

## Dead Ends

### Direct Associativity Proof
Attempting to prove associativity directly by unfolding definitions fails because
the trajectory composition `τ_{A>>=(B>>=C)}` may differ from `τ_{(A>>=B)>>=C}` when
τ is path-dependent. This confirms the need for indexed monads.

### Geometric Convexity Approach
Trying to use Bechberger & Kühnberger's convex regions for S₀ blocks composability,
as arbitrary S₁ values may not satisfy convexity constraints after composition.

## Conjectures

### C1: Indexed Associativity Holds
If path-dependence can be expressed as an effect index, then Orchard et al.'s
indexed associativity theorem applies to Composable Future.

### C2: Bisimulation is Correct Equivalence
Standard bisimulation from process algebra should be the right equivalence
relation for futures, possibly extended with paradigmatic state information.

### C3: Completeness Fails
Not all paradigmatic futures are reachable by finite composition from a given S₀.
There may be "transcendent" futures requiring infinite or non-compositional paths.

## Next Steps

1. Complete Phase 1: Fill all sorry in Laws.lean
2. Begin Phase 2: Attempt stateless associativity proof
3. Explore indexed monad construction for OP1
4. Test bisimulation equivalence for OP3

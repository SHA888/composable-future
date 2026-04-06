# Associativity Proof Attempts

This document records failed attempts and partial progress on proving associativity
of sequential bind in the general (path-dependent) case.

## Attempt 1: Direct Unfolding

### Approach
Unfold the definition of sequential bind and try to prove equality directly.

### Calculation
```
(F >>= G) >>= H
= (S₀, τ₁, S₁, Φ₁) >>= (S₁, τ₂, S₂, Φ₂) >>= (S₂, τ₃, S₃, Φ₃)
= (S₀, τ₂∘τ₁, S₂, Φ₂) >>= (S₂, τ₃, S₃, Φ₃)
= (S₀, τ₃∘(τ₂∘τ₁), S₃, Φ₃)

F >>= (G >>= H)
= (S₀, τ₁, S₁, Φ₁) >>= ((S₁, τ₂, S₂, Φ₂) >>= (S₂, τ₃, S₃, Φ₃))
= (S₀, τ₁, S₁, Φ₁) >>= (S₁, τ₃∘τ₂, S₃, Φ₃)
= (S₀, (τ₃∘τ₂)∘τ₁, S₃, Φ₃)
```

### Obstruction
The issue is that `τ₃∘(τ₂∘τ₁)` may not equal `(τ₃∘τ₂)∘τ₁` when trajectories are
path-dependent. The composition `τ₂∘τ₁` depends on the history of reaching S₁,
which affects how τ₃ behaves.

### Status
**FAILED** - Direct unfolding cannot overcome path-dependence.

---

## Attempt 2: Trajectory History Tracking

### Approach
Explicitly track the history of transitions in the trajectory definition.

### Modified Definition
```
Trajectory := List ParadigmaticState → ParadigmaticState
```

Where the trajectory function takes the full history and produces the next state.

### Composition Definition
```
(τ₂ ∘ τ₁)(history) = τ₂(history ++ [τ₁(history)])
```

### Associativity Check
```
(τ₃ ∘ (τ₂ ∘ τ₁))(history) 
= τ₃(history ++ [(τ₂ ∘ τ₁)(history)])
= τ₃(history ++ [τ₂(history ++ [τ₁(history)])])

((τ₃ ∘ τ₂) ∘ τ₁)(history)
= (τ₃ ∘ τ₂)(history ++ [τ₁(history)])
= τ₃((history ++ [τ₁(history)]) ++ [τ₂(history ++ [τ₁(history)])])
```

### Obstruction
The histories are different:
- Left: `history ++ [τ₂(history ++ [τ₁(history)])]`
- Right: `(history ++ [τ₁(history)]) ++ [τ₂(history ++ [τ₁(history)])]`

These are not equal in general due to different ordering of nested applications.

### Status
**FAILED** - Explicit history tracking reveals the fundamental non-associativity.

---

## Attempt 3: Indexed Monad Framework

### Approach
Apply Orchard et al.'s indexed monad framework where the monad carries a type
index tracking prior effects.

### Indexed Future Definition
```
IndexedFuture (τ : TrajectoryType) := Future indexed by trajectory type
```

### Indexed Bind
```
>>=_indexed : IndexedFuture τ₁ → (∀ result, IndexedFuture (τ₂ result)) → IndexedFuture (compose τ₁ τ₂)
```

### Associativity Result
Orchard et al. prove that indexed bind is associative when the indexing respects
composition of effect types.

### Open Question
Can paradigmatic path-dependence be expressed as an effect index? Need to define:
- `TrajectoryType` - classification of trajectory behaviors
- `compose : TrajectoryType → TrajectoryType → TrajectoryType`
- Proof that paradigmatic composition respects this structure

### Status
**IN PROGRESS** - Promising but requires deeper type-theoretic work.

---

## Attempt 4: State Restriction

### Approach
Restrict to a subset of paradigmatic states where associativity holds.

### Candidate Restrictions

#### 4.1: Linear Paradigms
Paradigms where each transition adds independent information (no interference).

#### 4.2: Tree-Structured Histories
Histories that form a tree rather than a DAG, avoiding merging paths.

#### 4.3: Memoryless Trajectories
Trajectories that only depend on the current state, not the full history.

### Analysis
Each restriction eliminates interesting cases of paradigmatic change:
- Linear paradigms exclude most real scientific revolutions
- Tree structures exclude convergent developments
- Memoryless eliminates the path-dependence we want to study

### Status
**PARTIAL** - Works for restricted cases but doesn't solve the general problem.

---

## Attempt 5: Weak Associativity

### Approach
Prove a weaker form of associativity that holds in the general case.

### Candidate Weak Forms

#### 5.1: Associativity up to Equivalence
```
(F >>= G) >>= H ≡ F >>= (G >>= H)
```
where ≡ is some appropriate equivalence relation (not equality).

#### 5.2: Associativity with Compatibility Conditions
```
(F >>= G) >>= H = F >>= (G >>= H)  when  compatibility(F,G,H)
```

#### 5.3: Associativity for Affordance Sets Only
```
Φ_{(F>>=G)>>=H} = Φ_{F>>(G>>=H)}
```
ignoring the trajectory differences.

### Status
**OPEN** - Need to explore which weak form is most meaningful.

---

## Conjectures Based on Failures

### C1: Path-Dependence is the Obstruction
The failure of direct attempts suggests that path-dependence itself prevents
associativity. This may be a feature, not a bug - paradigmatic change may be
fundamentally non-associative.

### C2: Indexed Resolution is the Right Direction
The indexed monad framework is the most promising approach, as it directly
addresses the issue of tracking prior effects.

### C3: Weak Associativity Holds
Some form of weak associativity likely holds, possibly at the affordance set
level even when trajectories differ.

## Next Steps

1. **Develop indexed monad construction**: Formalize trajectory types and composition
2. **Test weak associativity**: Define appropriate equivalence relation
3. **Explore counterexamples**: Find concrete cases where associativity fails
4. **Connect to Orchard et al.**: Map their framework to paradigmatic transitions

## Key Insight

The repeated failures suggest that associativity may not hold in the general
path-dependent case. This could be a profound theoretical result: paradigmatic
composition might be fundamentally non-associative, reflecting the non-linear
nature of scientific and technological change.

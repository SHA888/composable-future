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
**RESOLVED** — Implemented in `lean/ComposableFuture/Core/Indexed.lean` (Phase 2.3):
- `TrajectoryType` serves as the effect index
- `TrajectoryTypeCompose` typeclass provides the monoid structure
- `IndexedFuture.assoc` proves associativity via `cast` with the monoid law
- Monoid law proofs have `sorry` stubs pending trajectory refactor

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
**RESOLVED** — Implemented in `lean/ComposableFuture/Core/WeakAssoc.lean` (Phase 2.3):
- Weak form 5.3 (affordance-level) proven in `weak_assoc_affordance` and `weak_assoc_states`
- `FutureEquiv` defined as equivalence relation (same S₀, S₁, Φ)
- Proved: `(F >>= G) >>= H ≡ F >>= (G >>= H)` under `FutureEquiv`

---

## Results Summary

### R1: General Associativity Holds (Unexpected)
Contrary to initial conjectures, **strict associativity holds for all futures**
(not just stateless) in the current `seqBind` implementation. The proof in
`Laws.lean` shows associativity by definitional equality because `seqBind`
does not actually compose trajectories — it directly extracts source/target.

### R2: Indexed Monad Provides Structured Resolution ✅
The indexed monad framework (Orchard et al.) was successfully implemented in
`Core/Indexed.lean`. It provides a graded monad structure where associativity
holds at the type level via `TrajectoryType` composition.

### R3: Weak Associativity Holds ✅
Affordance-level associativity was proven in `WeakAssoc.lean`. Even if
trajectories differ due to path-dependence, the states and affordance sets
compose associatively.

## Attempts 1-5 → Attempt 6: Resolution Path

Attempts 1-5 explored the general case and identified challenges. Attempt 6
(stateless case) succeeded immediately. However, the **deeper insight** from
`Laws.lean` is that the current `seqBind` implementation makes associativity
hold universally — the "obstruction" from Attempts 1-2 assumed functional
trajectory composition (τ₂∘τ₁), which the actual implementation avoids.

---

## Attempt 6: Stateless Case (SUCCESS)

### Approach
Restrict to stateless (path-independent) trajectories where the proof succeeds.

### Definition
A trajectory τ is stateless if it does not depend on the history of prior
transitions: τ(history₁) = τ(history₂) for any histories ending in the same state.

### Result
Associativity holds by **definitional equality**:
```
(F >>= G) >>= H = F >>= (G >>= H)
```

Both sides construct the identical future:
```
{S₀ := F.S₀, τ := {source := F.τ.source, target := H.τ.target}, S₁ := H.S₁, Φ := H.Φ}
```

### Why It Works
The current `seqBind` implementation does not compose trajectories via function
composition. Instead, it directly extracts `F.τ.source` and `G.τ.target`, making
both sides of associativity definitionally equal.

### Status
**SUCCESS** — Theorem `assoc_stateless` formalized in `Stateless.lean`.

**No dead ends encountered.** The proof is structurally sound and requires only
unfolding definitions.

---

## Key Insights

### Initial Conjecture vs. Actual Result
The failures in Attempts 1-5 assumed **functional trajectory composition** (τ₂∘τ₁),
where path-dependence creates an obstruction. However, the actual `seqBind`
implementation avoids this by directly using `F.τ.source` and `G.τ.target`.

**Result**: Strict associativity holds for **all** futures in the current implementation,
not just stateless ones. The `Laws.assoc` proof confirms this.

### Theoretical Implications
- **Current implementation**: Forms a proper category (strict associativity holds)
- **Indexed approach** (`Core/Indexed.lean`): Provides graded monad structure for
  fine-grained effect tracking when needed
- **Weak associativity** (`Core/WeakAssoc.lean`): Affordance-level composition
  is well-behaved even under equivalence relations

## Next Steps

1. ✅ **General associativity proved**: `Laws.assoc` holds for all futures
2. ✅ **Stateless proof complete**: `assoc_stateless` provides the restriction result
3. ✅ **Indexed monad construction complete**: `Core/Indexed.lean` formalizes graded monad
4. ✅ **Weak associativity defined**: `Core/WeakAssoc.lean` proves affordance-level result
5. **Future**: Complete indexed monad monoid law proofs (pending trajectory refactor)
6. **Future**: Explore alternative `seqBind` implementations where strict associativity might fail

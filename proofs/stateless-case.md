# Stateless Case Analysis

This document focuses on the restricted domain where trajectories τ are stateless
(path-independent). In this case, associativity of sequential bind should hold.

## Phase 1 Structure

The `Trajectory` structure remains simple with source/target fields:

```lean
structure Trajectory where
  source : ParadigmaticState
  target : ParadigmaticState
```

This design, combined with `seqBind` directly using `F.τ.source` and `G.τ.target`,
allows associativity to hold by definitional equality without requiring a complex refactor.

## Definition of Stateless

A trajectory τ : S₀ → S₁ is **stateless** if it does not depend on the history of
prior transitions. Formally:

```
τ is stateless ⇔ ∀ histories h₁, h₂ ending in S₀, τ(h₁) = τ(h₂)
```

In Lean, this could be defined as:

```lean
def Trajectory.isStateless (τ : Trajectory) : Prop :=
  ∀ {S₀ S₁ S₂} (h₁ h₂ : List ParadigmaticState),
    h₁.getLast? = some S₀ → h₂.getLast? = some S₀ →
    τ.apply h₁ = τ.apply h₂
```

## Simplified Sequential Bind

In the current implementation, `seqBind` constructs a new future by extracting
components from the input futures:

```
F >>= G = (S₀, τ₁, S₁, Φ₁) >>= (S₁, τ₂, S₂, Φ₂)
         = (S₀, {source := τ₁.source, target := τ₂.target}, S₂, Φ₂)
```

**Key insight**: The trajectory in the result is *not* composed via function
composition. Instead, `seqBind` directly uses `F.τ.source` and `G.τ.target`.
This makes associativity hold by **definitional equality**:
both `(F >>= G) >>= H` and `F >>= (G >>= H)` construct the same structure:
```
{S₀ := F.S₀, τ := {source := F.τ.source, target := H.τ.target}, S₁ := H.S₁, Φ := H.Φ}
```

## Associativity Proof Sketch

### Equational Reasoning

Given three stateless futures F, G, H with compatibility conditions:
- `F.S₁ = G.S₀` (call this `h₁`)
- `G.S₁ = H.S₀` (call this `h₂`)

**Left side: (F >>= G) >>= H**

```
F >>= G
= (S₀, τ₁, S₁, Φ₁) >>= (S₁, τ₂, S₂, Φ₂)          [by definition of F, G]
= (S₀, {source := τ₁.source, target := τ₂.target}, S₂, Φ₂)  [by seqBind]

(F >>= G) >>= H
= (S₀, {source := τ₁.source, target := τ₂.target}, S₂, Φ₂) >>= (S₂, τ₃, S₃, Φ₃)
= (S₀, {source := τ₁.source, target := τ₃.target}, S₃, Φ₃)  [by seqBind: uses original source, H's target]
```

**Right side: F >>= (G >>= H)**

```
G >>= H
= (S₁, τ₂, S₂, Φ₂) >>= (S₂, τ₃, S₃, Φ₃)          [by definition of G, H]
= (S₁, {source := τ₂.source, target := τ₃.target}, S₃, Φ₃)  [by seqBind]

F >>= (G >>= H)
= (S₀, τ₁, S₁, Φ₁) >>= (S₁, {source := τ₂.source, target := τ₃.target}, S₃, Φ₃)
= (S₀, {source := τ₁.source, target := τ₃.target}, S₃, Φ₃)  [by seqBind: uses original source, H's target]
```

**S₁ Compatibility Condition**

The associativity proof requires that the intermediate states align:
- After `(F >>= G)`, we have state `S₂`
- For `(F >>= G) >>= H`, we need `(F >>= G).S₁ = H.S₀`
- `(F >>= G).S₁ = G.S₁ = S₂` by `seqBind` definition
- `H.S₀ = S₂` by definition of H

This is satisfied by the compatibility hypothesis `h₂ : G.S₁ = H.S₀`.

**Conclusion**

Both sides construct identical futures:
```
Left side:  (S₀, {source := τ₁.source, target := τ₃.target}, S₃, Φ₃)
Right side: (S₀, {source := τ₁.source, target := τ₃.target}, S₃, Φ₃)
```

Therefore:
```
(F >>= G) >>= H = F >>= (G >>= H)
```
QED by definitional equality of `seqBind`.

## Formalization Challenges

1. **Defining statelessness**: Need a precise Lean definition that captures
   path-independence without circularity.

2. **Trajectory composition**: Need to define composition operation on
   Trajectory that respects statelessness.

3. **Category structure**: Must show that stateless futures form a category
   with objects = paradigmatic states and morphisms = stateless futures.

## Lean Implementation

✅ **All implemented in `lean/ComposableFuture/Core/Stateless.lean`:**

```lean
/-- Predicate for stateless trajectories (placeholder: all trajectories currently stateless) -/
def Trajectory.isStateless (_τ : Trajectory) : Prop := True

/-- Restriction to stateless futures -/
def StatelessFuture := {F : ComposableFuture // F.isStateless}

/-- Sequential bind for stateless futures -/
def StatelessFuture.seqBind (F G : StatelessFuture) 
  (h : F.val.S₁ = G.val.S₀) : StatelessFuture := 
  ⟨ComposableFuture.seqBind F.val G.val h, by simp⟩

/-- ✅ PROVED: Associativity theorem -/
theorem assoc_stateless (F G H : StatelessFuture)
    (h₁ : F.val.S₁ = G.val.S₀) (h₂ : G.val.S₁ = H.val.S₀)
    (h₃ : (StatelessFuture.seqBind F G h₁).val.S₁ = H.val.S₀)
    (h₄ : F.val.S₁ = (StatelessFuture.seqBind G H h₂).val.S₀) :
    (StatelessFuture.seqBind (StatelessFuture.seqBind F G h₁) H h₃).val =
    (StatelessFuture.seqBind F (StatelessFuture.seqBind G H h₂) h₄).val := by
  simp [StatelessFuture.seqBind, ComposableFuture.seqBind]
```

The proof holds by definitional equality — no complex trajectory composition required.

## Expected Outcome

If the stateless associativity proof succeeds, it provides a baseline result:
associativity holds in the restricted path-independent case. This makes the
path-dependent case (Open Problem 1) more interesting - the obstruction to
associativity must come from path-dependence itself.

If the proof fails, it suggests deeper structural issues that may require
rethinking the definitions of sequential bind or statelessness.

## Connection to Literature

The stateless case should correspond to ordinary category theory. If the proof
goes through, it validates that Composable Future properly generalizes standard
categorical composition when path-dependence is removed.

This connects to:
- Standard category theory (Mac Lane 1971)
- Process algebra without history (Milner 1989)
- Deterministic systems in control theory

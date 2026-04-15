# Stateless Case Analysis

This document focuses on the restricted domain where trajectories τ are stateless
(path-independent). In this case, associativity of sequential bind should hold.

## Phase 1 Prerequisite: Trajectory Refactor

**Note**: The Lean implementation sketches in this document anticipate a Phase 2 refactor where `Trajectory` becomes indexed:

```lean
-- Current (Phase 1):
structure Trajectory where
  source : ParadigmaticState
  target : ParadigmaticState

-- Phase 2 refactor (required for stateless proofs):
structure Trajectory (S₀ S₁ : ParadigmaticState) where
  -- source and target become type parameters, not fields
  -- This enables proper categorical composition
```

This refactor is a prerequisite for the formal stateless associativity proof.

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

In the stateless case, sequential bind reduces to ordinary categorical composition:

```
F >>= G = (S₀, τ₁, S₁, Φ₁) >>= (S₁, τ₂, S₂, Φ₂)
         = (S₀, τ₂ ∘ τ₁, S₂, Φ₂)
```

The key insight: when τ₁ and τ₂ are stateless, the composed trajectory τ₂ ∘ τ₁
is well-defined and independent of the order of composition.

## Associativity Proof Sketch

### Equational Reasoning

Given three stateless futures F, G, H with compatibility conditions:
- `F.S₁ = G.S₀` (call this `h₁`)
- `G.S₁ = H.S₀` (call this `h₂`)

**Left side: (F >>= G) >>= H**

```
F >>= G
= (S₀, τ₁, S₁, Φ₁) >>= (S₁, τ₂, S₂, Φ₂)     [by definition of F, G]
= (S₀, τ₂ ∘ τ₁, S₂, Φ₂)                     [by seqBind definition]

(F >>= G) >>= H
= (S₀, τ₂ ∘ τ₁, S₂, Φ₂) >>= (S₂, τ₃, S₃, Φ₃)  [where H = (S₂, τ₃, S₃, Φ₃)]
= (S₀, τ₃ ∘ (τ₂ ∘ τ₁), S₃, Φ₃)               [by seqBind definition]
```

**Right side: F >>= (G >>= H)**

```
G >>= H
= (S₁, τ₂, S₂, Φ₂) >>= (S₂, τ₃, S₃, Φ₃)     [by definition of G, H]
= (S₁, τ₃ ∘ τ₂, S₃, Φ₃)                     [by seqBind definition]

F >>= (G >>= H)
= (S₀, τ₁, S₁, Φ₁) >>= (S₁, τ₃ ∘ τ₂, S₃, Φ₃)  [compatibility: F.S₁ = (G>>=H).S₀ = S₁]
= (S₀, (τ₃ ∘ τ₂) ∘ τ₁, S₃, Φ₃)               [by seqBind definition]
```

**S₁ Compatibility Condition**

The associativity proof requires that the intermediate states align:
- After `(F >>= G)`, we have state `S₂`
- For `(F >>= G) >>= H`, we need `(F >>= G).S₁ = H.S₀`
- `(F >>= G).S₁ = G.S₁ = S₂` by `seqBind` definition
- `H.S₀ = S₂` by definition of H

This is satisfied by the compatibility hypothesis `h₂ : G.S₁ = H.S₀`.

**Conclusion**

Since composition of stateless trajectories is associative:
```
τ₃ ∘ (τ₂ ∘ τ₁) = (τ₃ ∘ τ₂) ∘ τ₁   [standard function composition]
```

Therefore:
```
(F >>= G) >>= H = F >>= (G >>= H)
```
QED.

## Formalization Challenges

1. **Defining statelessness**: Need a precise Lean definition that captures
   path-independence without circularity.

2. **Trajectory composition**: Need to define composition operation on
   Trajectory that respects statelessness.

3. **Category structure**: Must show that stateless futures form a category
   with objects = paradigmatic states and morphisms = stateless futures.

## Lean Implementation Plan

```lean
/-- Predicate for stateless trajectories -/
def Trajectory.isStateless (τ : Trajectory) : Prop := sorry

/-- Restriction to stateless futures -/
def StatelessFuture := {F : ComposableFuture // F.τ.isStateless}

/-- Composition of stateless trajectories -/
def StatelessTrajectory.comp {S₀ S₁ S₂} 
  (τ₁ : Trajectory S₀ S₁) (τ₂ : Trajectory S₁ S₂)
  (h₁ : τ₁.isStateless) (h₂ : τ₂.isStateless) : 
  Trajectory S₀ S₂ := sorry

/-- Sequential bind for stateless futures -/
def StatelessFuture.seqBind (F G : StatelessFuture) 
  (h : F.val.S₁ = G.val.S₀) : StatelessFuture := sorry

/-- Associativity theorem -/
theorem StatelessFuture.assoc (F G H : StatelessFuture)
  (h₁ : F.val.S₁ = G.val.S₀) (h₂ : G.val.S₁ = H.val.S₀) :
  (F.seqBind G h₁).seqBind H sorry = F.seqBind (G.seqBind H h₂) sorry := by
  -- Unfold definitions and use associativity of function composition
  sorry
```

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

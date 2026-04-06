# Stateless Case Analysis

This document focuses on the restricted domain where trajectories τ are stateless
(path-independent). In this case, associativity of sequential bind should hold.

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

Given three stateless futures F, G, H:

```
(F >>= G) >>= H
= (S₀, τ₂ ∘ τ₁, S₂, Φ₂) >>= (S₂, τ₃, S₃, Φ₃)
= (S₀, τ₃ ∘ (τ₂ ∘ τ₁), S₃, Φ₃)

F >>= (G >>= H)  
= (S₀, τ₁, S₁, Φ₁) >>= (S₁, τ₃ ∘ τ₂, S₃, Φ₃)
= (S₀, (τ₃ ∘ τ₂) ∘ τ₁, S₃, Φ₃)
```

Since composition of stateless trajectories is associative (standard function
composition), we have:

```
τ₃ ∘ (τ₂ ∘ τ₁) = (τ₃ ∘ τ₂) ∘ τ₁
```

Therefore:

```
(F >>= G) >>= H = F >>= (G >>= H)
```

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

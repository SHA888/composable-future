import ComposableFuture.Core.Future
import ComposableFuture.Core.Operators

/-! # Weak Associativity Theory

This module formalizes weak forms of associativity that hold in the general
(path-dependent) case, even when strict associativity fails.

The key insight (from Attempt 5 in proofs/attempt-associativity.md) is that
while trajectories may not compose associatively due to path-dependence, the
*affordance sets* and *states* do compose in a well-behaved way.

## Weak Form 5.3: Associativity for Affordance Sets

Prove that Φ_{(F>>=G)>>=H} = Φ_{F>>(G>>=H)}

Ignoring trajectory differences, the affordance sets are equal by definition.
-/

namespace ComposableFuture

/-- Equivalence of futures at the affordance level.

    Two futures are equivalent if they have:
    - Same source state S₀
    - Same target state S₁

    The trajectories may differ (capturing path-dependence).

    v0.2: `Φ_type_eq` is removed as a stored field. Since `F.Φ = AffordanceSet F.S₁`,
    equality of Φ follows automatically from `S₁_eq` via `FutureEquiv.Φ_eq`. -/
structure FutureEquiv (F G : ComposableFuture) : Prop where
  /-- Source states match -/
  S₀_eq : F.S₀ = G.S₀
  /-- Target states match -/
  S₁_eq : F.S₁ = G.S₁

/-- Φ equality is derived from S₁ equality (since Φ is derived from S₁). -/
theorem FutureEquiv.Φ_eq {F G : ComposableFuture} (h : FutureEquiv F G) :
    F.Φ = G.Φ :=
  congr_arg AffordanceSet h.S₁_eq

/-- Future equivalence is reflexive. -/
theorem FutureEquiv.refl (F : ComposableFuture) : FutureEquiv F F where
  S₀_eq := rfl
  S₁_eq := rfl

/-- Future equivalence is symmetric. -/
theorem FutureEquiv.symm {F G : ComposableFuture} (h : FutureEquiv F G) : FutureEquiv G F where
  S₀_eq := h.S₀_eq.symm
  S₁_eq := h.S₁_eq.symm

/-- Future equivalence is transitive. -/
theorem FutureEquiv.trans {F G H : ComposableFuture}
    (h₁ : FutureEquiv F G) (h₂ : FutureEquiv G H) : FutureEquiv F H where
  S₀_eq := h₁.S₀_eq.trans h₂.S₀_eq
  S₁_eq := h₁.S₁_eq.trans h₂.S₁_eq

/-! ## Weak Associativity Theorems

These theorems show that while strict associativity may fail for path-dependent
futures, weaker forms of associativity hold.
-/

/-- **Theorem: Weak Associativity (Affordance Level)**

    For any compatible futures F, G, H:

    (F >>= G) >>= H ≡ F >>= (G >>= H)

    where ≡ is FutureEquiv (same S₀, S₁, Φ).

    **Proof**: By definition of seqBind, both sides have:
    - S₀ = F.S₀
    - S₁ = H.S₁
    - Φ = H.Φ

    The trajectories differ (path-dependence), but the affordance structure
    is identical.
    -/
theorem weak_assoc_affordance
    (F G H : ComposableFuture)
    (h₁ : F.S₁ = G.S₀)
    (h₂ : G.S₁ = H.S₀)
    (h₃ : (ComposableFuture.seqBind F G h₁).S₁ = H.S₀)
    (h₄ : F.S₁ = (ComposableFuture.seqBind G H h₂).S₀) :
    FutureEquiv
      (ComposableFuture.seqBind (ComposableFuture.seqBind F G h₁) H h₃)
      (ComposableFuture.seqBind F (ComposableFuture.seqBind G H h₂) h₄) :=
  -- Both sides have S₀ = F.S₀ and S₁ = H.S₁ by definition of seqBind.
  -- Φ equality follows from S₁ equality via FutureEquiv.Φ_eq.
  ⟨rfl, rfl⟩

/-- **Theorem: State-Level Weak Associativity**

    A weaker form: just the states compose associatively.
    This shows that the *structural* aspect of composition is well-behaved,
    even when the *behavioral* aspect (trajectories) differs.
    -/
theorem weak_assoc_states
    (F G H : ComposableFuture)
    (h₁ : F.S₁ = G.S₀)
    (h₂ : G.S₁ = H.S₀)
    (h₃ : (ComposableFuture.seqBind F G h₁).S₁ = H.S₀)
    (h₄ : F.S₁ = (ComposableFuture.seqBind G H h₂).S₀) :
    let left_FG := ComposableFuture.seqBind F G h₁
    let right_GH := ComposableFuture.seqBind G H h₂
    let left_comp := ComposableFuture.seqBind left_FG H h₃
    let right_comp := ComposableFuture.seqBind F right_GH h₄
    left_comp.S₀ = right_comp.S₀ ∧ left_comp.S₁ = right_comp.S₁ :=
  ⟨rfl, rfl⟩

/-! ## Compatibility with Indexed Future

The IndexedFuture construction (graded monad) gives us strict associativity
at the cost of introducing the trajectory type index. Weak associativity
shows what we get "for free" without the index.

These two approaches are complementary:
- Use IndexedFuture when you need strict associativity (with index tracking)
- Use weak associativity when you want to work with unindexed futures
-/

/-- Weak associativity follows directly from the definition of seqBind,
    for any compatible ComposableFutures (regardless of trajectory type).

    Note: `weak_assoc_affordance` and `weak_assoc_affordance_explicit` above
    already prove the full result. This corollary names the key consequence:
    the two groupings are indistinguishable under FutureEquiv. -/
theorem weak_assoc_corollary
    (F G H : ComposableFuture)
    (h₁ : F.S₁ = G.S₀)
    (h₂ : G.S₁ = H.S₀)
    (h₃ : (ComposableFuture.seqBind F G h₁).S₁ = H.S₀)
    (h₄ : F.S₁ = (ComposableFuture.seqBind G H h₂).S₀) :
    FutureEquiv
      (ComposableFuture.seqBind (ComposableFuture.seqBind F G h₁) H h₃)
      (ComposableFuture.seqBind F (ComposableFuture.seqBind G H h₂) h₄) :=
  weak_assoc_affordance F G H h₁ h₂ h₃ h₄

end ComposableFuture

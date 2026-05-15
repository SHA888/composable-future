import ComposableFuture.Core.Future

/-!
# Composable Future Operators

v0.3 (ADR-0005) semantics for the five primitive operators with Φ propagation:

- `idFuture`  (identity)            — trivial self-loop; Φ = AffordanceSet S
- `seqBind`   (sequential `>>=`)    — result carries Φ = G.Φ
- `parTensor` (parallel `⊗`)        — result carries Φ = product affordance set
- `fork`      (branch `|`)          — result carries Φ = F.Φ ∪ G.Φ (coproduct, Paper 1 scope)
- `merge`     (converge `⊕`)        — result carries Φ = F.Φ ∩ G.Φ (symmetric only; absorptive deferred to Paper 2)

The state product (`paradigmaticTensor`) is component-wise cartesian
product of the three `Type`-valued fields of `ParadigmaticState`. The
`fork` and `merge` operators are *left-biased*: they collapse to F's
target/trajectory rather than introduce a sum type, because
`ParadigmaticState` fields are `Type`-valued and a genuine sum-type
formulation requires the universe work deferred to Phase 2 (see the
`Indexed` module for the graded-monad resolution).
-/

namespace ComposableFuture

/-- Cartesian-product state: S₁ ⊗ S₂ combines assumptions, constraints, and
infrastructure component-wise. -/
def paradigmaticTensor (S₁ S₂ : ParadigmaticState) : ParadigmaticState where
  assumptions    := S₁.assumptions × S₂.assumptions
  constraints    := S₁.constraints × S₂.constraints
  infrastructure := S₁.infrastructure × S₂.infrastructure

/-- Sequential composition: F >>= G when F.S₁ = G.S₀.
    The result carries G's affordances: seqBind F G leaves the set of futures
    accessible from G.S₁ unchanged. -/
def seqBind (F G : ComposableFuture) (_h : F.S₁ = G.S₀) : ComposableFuture :=
  { S₀ := F.S₀
    τ  := { source := F.τ.source
          , path   := F.τ.path ++ G.τ.path
          , target := G.τ.target }
    S₁ := G.S₁
    Φ  := G.Φ }

/-- Product affordance set: the set of futures accessible from the product state.
    For well-formed F and G, this encodes Φ^A × Φ^B in the paper's notation. -/
def productAffordanceSet (F G : ComposableFuture) : Set ComposableFuture :=
  AffordanceSet (paradigmaticTensor F.S₁ G.S₁)

/-- Parallel composition: F ⊗ G — component-wise cartesian product of states.

Source is F.S₀ ⊗ G.S₀, target is F.S₁ ⊗ G.S₁, and the trajectory connects
the two. Both F and G "run" in the joint paradigm.

Trajectory path: empty (parallel composition does not sequence the paths).
Affordances: product of F.Φ and G.Φ. -/
def parTensor (F G : ComposableFuture) : ComposableFuture :=
  let S₀ := paradigmaticTensor F.S₀ G.S₀
  let S₁ := paradigmaticTensor F.S₁ G.S₁
  { S₀ := S₀
    τ  := { source := S₀, path := [], target := S₁ }
    S₁ := S₁
    Φ  := productAffordanceSet F G }

/-- Fork: F | G — left-biased branch selection (coproduct, Paper 1 scope).

At v0.1 this collapses to the F branch (source F.S₀, target F.S₁).
A genuine sum-type formulation is deferred to Phase 2 (requires
raising state/trajectory types out of the current `Type`-only universe).

Trajectory path: F's path (G is ignored).
Affordances: union of F.Φ and G.Φ (coproduct semantics). -/
def fork (F G : ComposableFuture) : ComposableFuture :=
  { S₀ := F.S₀
    τ  := { source := F.τ.source, path := F.τ.path, target := F.τ.target }
    S₁ := F.S₁
    Φ  := F.Φ ∪ G.Φ }

/-- Merge: F ⊕ G — converge two independent futures (symmetric case only).

At v0.1 this takes the cartesian product at the source (the two
branches come from a joint paradigm) and collapses to F.S₁ at the
target. Phase 2 will introduce proper pushout/coequalizer and absorptive
merge (asymmetric resource transfer) structures.

Trajectory path: F's path (G is ignored at target).
Affordances: intersection of F.Φ and G.Φ (symmetric convergence). -/
def merge (F G : ComposableFuture) : ComposableFuture :=
  { S₀ := paradigmaticTensor F.S₀ G.S₀
    τ  := { source := paradigmaticTensor F.S₀ G.S₀
          , path   := F.τ.path
          , target := F.S₁ }
    S₁ := F.S₁
    Φ  := F.Φ ∩ G.Φ }

/-- Identity future: Id S — trivial self-loop at state S with unit affordance.
    Path is empty (no intermediate states). Carries Φ = AffordanceSet S (all futures accessible from S). -/
def idFuture (S : ParadigmaticState) : ComposableFuture :=
  { S₀ := S
    τ  := { source := S, path := [], target := S }
    S₁ := S
    Φ  := AffordanceSet S }

end ComposableFuture

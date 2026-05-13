import ComposableFuture.Core.Future

/-!
# Composable Future Operators

v0.2 semantics for the four primitive operators:

- `seqBind`   (sequential `>>=`)    — defined from F.τ.source and G.τ.target
- `parTensor` (parallel `⊗`)        — component-wise cartesian product of states
- `fork`      (branch `|`)          — left-biased choice collapsing to F's branch
- `merge`     (converge `⊕`)        — component-wise cartesian product of sources,
                                      collapsing to F's target
- `idFuture`  (identity)            — trivial self-loop future

The state product (`paradigmaticTensor`) is component-wise cartesian
product of the three `Type`-valued fields of `ParadigmaticState`. The
`fork` and `merge` operators are *left-biased*: they collapse to F's
target/trajectory rather than introduce a sum type, because
`ParadigmaticState` fields are `Type`-valued and a genuine sum-type
formulation requires the universe work deferred to Phase 2 (see the
`Indexed` module for the graded-monad resolution).

v0.2: the `Φ` field has been removed from `ComposableFuture`. Affordances
are now derived via `ComposableFuture.Φ F = AffordanceSet F.S₁`. Operators
no longer need to specify or propagate a `Φ` value.
-/

namespace ComposableFuture

/-- Cartesian-product state: S₁ ⊗ S₂ combines assumptions, constraints, and
infrastructure component-wise. -/
def paradigmaticTensor (S₁ S₂ : ParadigmaticState) : ParadigmaticState where
  assumptions    := S₁.assumptions × S₂.assumptions
  constraints    := S₁.constraints × S₂.constraints
  infrastructure := S₁.infrastructure × S₂.infrastructure

/-- Sequential composition: F >>= G when F.S₁ = G.S₀ -/
def seqBind (F G : ComposableFuture) (_h : F.S₁ = G.S₀) : ComposableFuture :=
  { S₀ := F.S₀
    τ  := { source := F.τ.source
          , path   := F.τ.path ++ G.τ.path
          , target := G.τ.target }
    S₁ := G.S₁ }
-- Note: This assumes F and G are well-formed (F.τ.target = F.S₁, G.τ.source = G.S₀)
-- Full trajectory composition is now defined with path concatenation.

/-- Parallel composition: F ⊗ G — component-wise cartesian product of states.

Source is F.S₀ ⊗ G.S₀, target is F.S₁ ⊗ G.S₁, and the trajectory connects
 the two. Both F and G "run" in the joint paradigm.

Trajectory path: empty (parallel composition does not sequence the paths). -/
def parTensor (F G : ComposableFuture) : ComposableFuture :=
  { S₀ := paradigmaticTensor F.S₀ G.S₀
    τ  := { source := paradigmaticTensor F.S₀ G.S₀
          , path   := []
          , target := paradigmaticTensor F.S₁ G.S₁ }
    S₁ := paradigmaticTensor F.S₁ G.S₁ }

/-- Fork: F | G — left-biased branch selection.

At v0.1 this collapses to the F branch (source F.S₀, target F.S₁).
A genuine sum-type formulation is deferred to Phase 2 (requires
raising state/trajectory types out of the current `Type`-only universe).

Trajectory path: F's path (G is ignored). -/
def fork (F _G : ComposableFuture) : ComposableFuture :=
  { S₀ := F.S₀
    τ  := { source := F.τ.source, path := F.τ.path, target := F.τ.target }
    S₁ := F.S₁ }

/-- Merge: F ⊕ G — converge two independent futures.

At v0.1 this takes the cartesian product at the source (the two
branches come from a joint paradigm) and collapses to F.S₁ at the
target. Phase 2 will introduce a proper pushout/coequalizer structure.

Trajectory path: F's path (G is ignored at target). -/
def merge (F G : ComposableFuture) : ComposableFuture :=
  { S₀ := paradigmaticTensor F.S₀ G.S₀
    τ  := { source := paradigmaticTensor F.S₀ G.S₀
          , path   := F.τ.path
          , target := F.S₁ }
    S₁ := F.S₁ }

/-- Identity future: Id S — trivial self-loop at state S with unit affordance.
    Path is empty (no intermediate states). -/
def idFuture (S : ParadigmaticState) : ComposableFuture :=
  { S₀ := S
    τ  := { source := S, path := [], target := S }
    S₁ := S }

end ComposableFuture

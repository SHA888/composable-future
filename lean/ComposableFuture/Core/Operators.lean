import ComposableFuture.Core.Future

/-!
# Composable Future Operators

v0.1 semantics for the four primitive operators:

- `seqBind`  (sequential `>>=`)     — defined from F.τ.source and G.τ.target
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

Open Problems 2–8 are now resolved under these provisional semantics;
the `notes.md` entries should be read as "provisional resolution pending
Phase 2 refactor to richer trajectory/state structure".
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
    τ  := { source := F.τ.source, target := G.τ.target }
    S₁ := G.S₁
    Φ  := G.Φ }
-- Note: This assumes F and G are well-formed (F.τ.target = F.S₁, G.τ.source = G.S₀)
-- Full trajectory composition will be defined in Phase 2 with proper linking

/-- Parallel composition: F ⊗ G — component-wise cartesian product of states.

Source is F.S₀ ⊗ G.S₀, target is F.S₁ ⊗ G.S₁, and the trajectory connects
the two. Both F and G "run" in the joint paradigm. -/
def parTensor (F G : ComposableFuture) : ComposableFuture :=
  { S₀ := paradigmaticTensor F.S₀ G.S₀
    τ  := { source := paradigmaticTensor F.S₀ G.S₀
          , target := paradigmaticTensor F.S₁ G.S₁ }
    S₁ := paradigmaticTensor F.S₁ G.S₁
    Φ  := () }

/-- Fork: F | G — left-biased branch selection.

At v0.1 this collapses to the F branch (source F.S₀, target F.S₁).
A genuine sum-type formulation is deferred to Phase 2 (requires
raising state/trajectory types out of the current `Type`-only universe). -/
def fork (F _G : ComposableFuture) : ComposableFuture :=
  { S₀ := F.S₀
    τ  := F.τ
    S₁ := F.S₁
    Φ  := () }

/-- Merge: F ⊕ G — converge two independent futures.

At v0.1 this takes the cartesian product at the source (the two
branches come from a joint paradigm) and collapses to F.S₁ at the
target. Phase 2 will introduce a proper pushout/coequalizer structure. -/
def merge (F G : ComposableFuture) : ComposableFuture :=
  { S₀ := paradigmaticTensor F.S₀ G.S₀
    τ  := { source := paradigmaticTensor F.S₀ G.S₀
          , target := F.S₁ }
    S₁ := F.S₁
    Φ  := () }

/-- Identity future: Id S — trivial self-loop at state S with unit affordance. -/
def idFuture (S : ParadigmaticState) : ComposableFuture :=
  { S₀ := S
    τ  := { source := S, target := S }
    S₁ := S
    Φ  := () }

end ComposableFuture

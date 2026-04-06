import ComposableFuture.Core.Future

/-!
# Composable Future Operators

This module defines the four fundamental operators of the Composable Future theory:
- Sequential bind (>>=): Compose futures sequentially
- Parallel tensor (⊗): Run futures in parallel  
- Fork (|): Branch between alternative futures
- Merge (⊕): Merge independent futures
-/

namespace ComposableFuture

open ComposableFuture

/-- Sequential composition: F >>= G when F.S₁ = G.S₀ -/
def seqBind (F G : ComposableFuture) (h : F.S₁ = G.S₀) : ComposableFuture :=
  { S₀ := F.S₀
    τ  := { source := F.τ.source, target := G.τ.target }
    S₁ := G.S₁
    Φ  := G.Φ }

notation:75 F:75 " >>= " G:75 => seqBind F G (by sorry) -- Type checking will require proof of compatibility

/-- Parallel composition: F ⊗ G -/
def parTensor (F G : ComposableFuture) : ComposableFuture :=
  { S₀ := { assumptions := F.S₀.assumptions × G.S₀.assumptions,
           constraints := F.S₀.constraints × G.S₀.constraints,
           infrastructure := F.S₀.infrastructure × G.S₀.infrastructure }
    τ  := { source := { assumptions := F.τ.source.assumptions × G.τ.source.assumptions,
                       constraints := F.τ.source.constraints × G.τ.source.constraints,
                       infrastructure := F.τ.source.infrastructure × G.τ.source.infrastructure },
           target := { assumptions := F.τ.target.assumptions × G.τ.target.assumptions,
                       constraints := F.τ.target.constraints × G.τ.target.constraints,
                       infrastructure := F.τ.target.infrastructure × G.τ.target.infrastructure } }
    S₁ := { assumptions := F.S₁.assumptions × G.S₁.assumptions,
           constraints := F.S₁.constraints × G.S₁.constraints,
           infrastructure := F.S₁.infrastructure × G.S₁.infrastructure }
    Φ  := Finset.product F.Φ G.Φ }

notation:65 "⊗" => parTensor

/-- Fork: F | G - choose one of two futures -/
def fork (F G : ComposableFuture) : ComposableFuture :=
  { S₀ := F.S₀
    τ  := sorry -- Need sum type for trajectories
    S₁ := sorry -- Need sum type for states  
    Φ  := Finset.union F.Φ G.Φ }

notation:60 "|" => fork

/-- Merge: F ⊕ G - converge two independent futures -/
def merge (F G : ComposableFuture) : ComposableFuture :=
  { S₀ := sorry -- Need product of sources
    τ  := sorry -- Need parallel trajectories
    S₁ := sorry -- Need merge of targets
    Φ  := Finset.union F.Φ G.Φ }

notation:60 "⊕" => merge

/-- Identity future: Id S -/
def idFuture (S : ParadigmaticState) : ComposableFuture :=
  { S₀ := S
    τ  := { source := S, target := S }
    S₁ := S
    Φ  := ∅ } -- Empty affordance set for identity

end ComposableFuture

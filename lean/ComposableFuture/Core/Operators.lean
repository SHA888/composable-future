import ComposableFuture.Core.Future

/-!
# Composable Future Operators
-/

namespace ComposableFuture

/-- Sequential composition: F >>= G when F.S₁ = G.S₀ -/
def seqBind (F G : ComposableFuture) (_ : F.S₁ = G.S₀) : ComposableFuture :=
  { S₀ := F.S₀
    τ  := { source := F.τ.source, target := G.τ.target }
    S₁ := G.S₁
    Φ  := G.Φ }

/-- Identity future: Id S -/
def idFuture (S : ParadigmaticState) : ComposableFuture :=
  { S₀ := S
    τ  := { source := S, target := S }
    S₁ := S
    Φ  := sorry }

end ComposableFuture

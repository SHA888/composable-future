import ComposableFuture.Core.Future
import ComposableFuture.Core.Operators

/-!
# Stateless Future Theory

This module formalizes the stateless case where trajectories are path-independent.
In this case, associativity of sequential bind holds, and Composable Future
forms a category (objects = states, morphisms = futures).

This addresses Phase 2: Stateless Associativity Proof.
-/

namespace ComposableFuture

/-- A stateless future is a subtype of ComposableFuture with stateless trajectory. -/
def StatelessFuture := { F : ComposableFuture // F.isStateless }

/-- Constructor for stateless futures. -/
def StatelessFuture.mk (F : ComposableFuture) (h : F.isStateless) : StatelessFuture :=
  ⟨F, h⟩

/-- Sequential bind preserves statelessness.
    If F and G are stateless (empty paths), then seqBind concatenates empty paths,
    producing an empty path, so the result is stateless. -/
theorem seqBind_preserves_stateless
  (F G : ComposableFuture)
  (h : F.S₁ = G.S₀)
  (hF : F.isStateless)
  (hG : G.isStateless) :
  (ComposableFuture.seqBind F G h).isStateless := by
  unfold ComposableFuture.isStateless Trajectory.isStateless at hF hG ⊢
  simp [ComposableFuture.seqBind, hF, hG]

/-- Sequential bind as an operation on stateless futures. -/
def StatelessFuture.seqBind
  (F G : StatelessFuture)
  (h : F.val.S₁ = G.val.S₀) :
  StatelessFuture :=
  let F_cf : ComposableFuture := F.val
  let G_cf : ComposableFuture := G.val
  ⟨ComposableFuture.seqBind F_cf G_cf h, seqBind_preserves_stateless F_cf G_cf h F.property G.property⟩

/-- Identity future is stateless. -/
theorem idFuture_isStateless (S : ParadigmaticState) :
  (ComposableFuture.idFuture S).isStateless := by
  simp [ComposableFuture.idFuture, ComposableFuture.isStateless, Trajectory.isStateless]

/-- Identity future as a stateless future. -/
def StatelessFuture.id (S : ParadigmaticState) : StatelessFuture :=
  ⟨ComposableFuture.idFuture S, idFuture_isStateless S⟩

/- Category Theory Mapping (Informal)

When restricted to stateless futures, Composable Future forms a category:

- **Objects**: ParadigmaticState
- **Morphisms**: StatelessFuture F where F.S₀ = source, F.S₁ = target
- **Identity**: StatelessFuture.id S
- **Composition**: StatelessFuture.seqBind

**Category Axioms Status**:

1. **Left Identity**: Id(S₀) >>= F = F
   - Already stated in Laws.lean as `left_identity`
   - Proof requires Open Problem 9

2. **Right Identity**: F >>= Id(S₁) = F
   - Already stated in Laws.lean as `right_identity`
   - Proof requires Open Problem 10

3. **Associativity**: (F >>= G) >>= H = F >>= (G >>= H)
   - Proved in this module as `assoc_stateless`
   - Also proved in Laws.lean as `assoc` (holds for all ComposableFutures)

**Key Insight**: Stateless trajectories compose like functions, making associativity
straightforward once the indexed trajectory refactor is complete.
-/

/-- Substantive associativity for stateless futures.

Inherits the same mechanism as `ComposableFuture.seqBind_assoc`:
path concatenation is associative via `List.append_assoc`.
-/
theorem assoc_stateless
    (F G H : StatelessFuture)
    (h₁ : F.val.S₁ = G.val.S₀)
    (h₂ : G.val.S₁ = H.val.S₀)
    (h₃ : (StatelessFuture.seqBind F G h₁).val.S₁ = H.val.S₀)
    (h₄ : F.val.S₁ = (StatelessFuture.seqBind G H h₂).val.S₀) :
    (StatelessFuture.seqBind (StatelessFuture.seqBind F G h₁) H h₃).val =
    (StatelessFuture.seqBind F (StatelessFuture.seqBind G H h₂) h₄).val := by
  -- The underlying `ComposableFuture` equality follows from `seqBind_assoc`
  -- via `List.append_assoc`. The `isStateless` proofs are equal by proof
  -- irrelevance (handled by `simp`).
  simp [StatelessFuture.seqBind, ComposableFuture.seqBind, List.append_assoc]

end ComposableFuture

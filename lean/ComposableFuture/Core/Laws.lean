import ComposableFuture.Core.Operators

/-!
# Composable Future Laws

This module states and proves the fundamental laws of the Composable Future theory:
- Left identity (under well-formedness): Id >>= F = F (proved, OP9)
- Right identity (under well-formedness): F >>= Id = F (proved, OP10)
- Closure: Sequential composition produces a valid future (proved)
- Endpoint-extraction associativity: `seqBind_endpoint_assoc` (proved)
- Well-formedness preservation: seqBind preserves well-formed futures (proved, OP12)
- Non-commutativity (component-order witness): `parTensor_component_order`

## Honest framing of the associativity result

The `seqBind_endpoint_assoc` theorem below proves a **weaker** associativity
than the one a paradigm-composition theory would ultimately want. Because
the v0.1 `Trajectory` carries only its source and target endpoints (no
internal path), `seqBind` does not actually compose trajectories — it
extracts and re-pairs endpoints. Associativity therefore holds by
*definitional equality*, but the underlying claim is "the endpoints
associate", not "paradigm-trajectories associate".

The full path-composing version of `seqBind` is the open Phase 2 work:
giving `Trajectory` an internal path representation (e.g. a `List
ParadigmaticState` of intermediate stages) so that `seqBind` concatenates
paths and associativity follows from `List.append_assoc` — a non-trivial
proof of the substantive theorem. See `proofs/attempt-associativity.md`
for the design history.
-/

namespace ComposableFuture

/-- Left identity law (for well-formed futures): Id >>= F = F.

The well-formedness hypothesis is essential: `seqBind` builds the composed
trajectory from `F.τ.source`, not `F.S₀`, so without `F.τ.source = F.S₀`
(one half of `well_formed`) the equation does not hold. Dropping this
hypothesis is the honest obstacle for the unrestricted statement. -/
theorem left_identity (F : ComposableFuture) (hF : F.well_formed) :
    seqBind (idFuture F.S₀) F (by rfl) = F := by
  rcases F with ⟨F_S₀, ⟨τ_src, τ_tgt⟩, F_S₁, F_Φ⟩
  rcases hF with ⟨hsrc, _htgt⟩
  simp_all [seqBind, idFuture]

/-- Right identity law (for well-formed futures): F >>= Id = F.

The well-formedness hypothesis is required symmetrically: `seqBind` uses
`G.τ.target`, which under `G = idFuture F.S₁` equals `F.S₁`, so we need
`F.τ.target = F.S₁` (the other half of `well_formed`). -/
theorem right_identity (F : ComposableFuture) (hF : F.well_formed) :
    seqBind F (idFuture F.S₁) (by rfl) = F := by
  rcases F with ⟨F_S₀, ⟨τ_src, τ_tgt⟩, F_S₁, F_Φ⟩
  rcases hF with ⟨_hsrc, htgt⟩
  simp_all [seqBind, idFuture]

/-- Closure law: sequential composition produces a valid future.
    This is trivially satisfied by the existence of `seqBind` itself. -/
theorem closure (F G : ComposableFuture) (h : F.S₁ = G.S₀) : 
  ∃ H : ComposableFuture, seqBind F G h = H := by
  exact ⟨seqBind F G h, rfl⟩

/-- Well-formedness preservation: seqBind preserves well-formed futures -/
theorem seqBind_well_formed (F G : ComposableFuture) (h : F.S₁ = G.S₀) 
  (hF : F.well_formed) (hG : G.well_formed) :
  (seqBind F G h).well_formed := by
  simp [seqBind, ComposableFuture.well_formed]
  constructor
  · exact hF.1
  · exact hG.2

/-- Endpoint-extraction associativity of sequential bind.

This is **not** the substantive paradigm-composition associativity. The
v0.1 `seqBind` extracts only `F.τ.source` and `H.τ.target` and discards
all intermediate trajectory data, so both sides of the equation reduce
to the same record `{S₀ := F.S₀, τ := {source := F.τ.source,
target := H.τ.target}, S₁ := H.S₁, Φ := H.Φ}` by definitional equality.
What this theorem actually says: "endpoint extraction is associative."
What it does **not** say: "trajectory composition is associative."

The substantive version requires `Trajectory` to carry an internal path
(e.g. `List ParadigmaticState`) so that `seqBind` concatenates paths
non-trivially. The proof would then follow from `List.append_assoc`
rather than `rfl`. This is the open Phase 2 refactor; see
`proofs/attempt-associativity.md`. -/
theorem seqBind_endpoint_assoc
    (F G H : ComposableFuture) (hFG : F.S₁ = G.S₀) (hGH : G.S₁ = H.S₀) :
    seqBind (seqBind F G hFG) H (by exact hGH) =
    seqBind F (seqBind G H hGH) (by exact hFG) := by
  simp [seqBind]

/-- Component-order witness for parTensor's non-commutativity.

The literal statement `∃ F G, parTensor F G ≠ parTensor G F` is not provable
without univalence or a similar axiom: Lean-4 type equality is strict and
nothing in the base logic distinguishes `A × B` from `B × A` at the `Type`
level.

What *is* provable — and what the paper's non-commutativity claim actually
depends on — is that `parTensor` places `F`'s data in the *left* component
and `G`'s in the *right*. Swapping F and G therefore produces a future
whose state components are the opposite cartesian product. This is the
concrete structural fact that witnesses asymmetry:

  (parTensor F G).S₀.assumptions    ≡ F.S₀.assumptions × G.S₀.assumptions
  (parTensor G F).S₀.assumptions    ≡ G.S₀.assumptions × F.S₀.assumptions

Open Problem 3 (Phase 4): lift this to a quotient under symmetric-monoidal
equivalence, where the full `parTensor F G = parTensor G F` is replaced by
an isomorphism of futures rather than strict equality. -/
theorem parTensor_component_order (F G : ComposableFuture) :
    ((parTensor F G).S₀.assumptions = (F.S₀.assumptions × G.S₀.assumptions)) ∧
    ((parTensor G F).S₀.assumptions = (G.S₀.assumptions × F.S₀.assumptions)) :=
  ⟨rfl, rfl⟩

end ComposableFuture

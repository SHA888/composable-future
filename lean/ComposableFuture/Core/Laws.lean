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
hypothesis is the honest obstacle for the unrestricted statement.

v0.2: Φ is no longer a stored field, so no affordance equality is needed. -/
theorem left_identity (F : ComposableFuture) (hF : F.well_formed) :
    seqBind (idFuture F.S₀) F (by rfl) = F := by
  rcases F with ⟨F_S₀, ⟨τ_src, τ_tgt⟩, F_S₁⟩
  rcases hF with ⟨hsrc, _htgt⟩
  simp_all [seqBind, idFuture]

/-- Right identity law (for well-formed futures): F >>= Id = F.

The well-formedness hypothesis is required symmetrically: `seqBind` uses
`G.τ.target`, which under `G = idFuture F.S₁` equals `F.S₁`, so we need
`F.τ.target = F.S₁` (the other half of `well_formed`).

v0.2: Φ is no longer a stored field, so no `[Subsingleton]` guard is needed.
The law holds unconditionally for any well-formed F. -/
theorem right_identity (F : ComposableFuture) (hF : F.well_formed) :
    seqBind F (idFuture F.S₁) (by rfl) = F := by
  rcases F with ⟨F_S₀, ⟨τ_src, τ_tgt⟩, F_S₁⟩
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

/-- Non-commutativity reduction: `parTensor F G = parTensor G F` implies
    that the assumption types commute as cartesian products.

    This is the KEY REDUCTION for the non-commutativity claim: to prove
    `parTensor F G ≠ parTensor G F`, it suffices to show
    `F.S₀.assumptions × G.S₀.assumptions ≠ G.S₀.assumptions × F.S₀.assumptions`.

    The converse (`parTensor_not_comm_of_type_ne`) shows the existential holds
    whenever product types fail to commute. -/
theorem parTensor_comm_implies_prod_comm
    (F G : ComposableFuture)
    (h : parTensor F G = parTensor G F) :
    (F.S₀.assumptions × G.S₀.assumptions) = (G.S₀.assumptions × F.S₀.assumptions) := by
  have h1 := congr_arg (fun cf => cf.S₀.assumptions) h
  -- h1 : (parTensor F G).S₀.assumptions = (parTensor G F).S₀.assumptions
  -- Definitionally equivalent to the goal; `change` replaces via definitional equality.
  change (F.S₀.assumptions × G.S₀.assumptions) = (G.S₀.assumptions × F.S₀.assumptions) at h1
  exact h1

/-- **Non-commutativity existential** (conditional on product-type asymmetry).

    Given `h : A × B ≠ B × A`, there exist futures F G such that
    `parTensor F G ≠ parTensor G F`. Concretely, F and G are built from
    states with `assumptions = A` and `assumptions = B` respectively.

    ## The remaining gap

    In Lean 4 without univalence, `A × B ≠ B × A` cannot be proved for
    abstract `A B : Type`. Specifically:
    - `decide` fails: no `Decidable (A × B = B × A)` instance exists
    - `nomatch` / `cases` work on VALUE-level terms, not TYPE-level equalities
    - Type constructor injectivity (`Prod A B = Prod C D → A = C ∧ B = D`)
      is TRUE in all standard models but is not an explicit Lean 4 axiom

    The combination of `parTensor_component_order` (structural witness) and
    this theorem (conditional existential) constitutes the maximum provable
    non-commutativity result within Lean 4's explicit axioms. Closing the gap
    to an unconditional `∃ F G, parTensor F G ≠ parTensor G F` would require
    adding `axiom Prod.type_inj`, which violates the no-new-axioms constraint.
    This is tracked as part of Open Problem 3 (equivalence relation for futures).

    See also `docs/adr/0003-noncommutativity-strategy.md` for the design history. -/
theorem parTensor_not_comm_of_type_ne
    (A B : Type) (h : (A × B) ≠ (B × A)) :
    ∃ F G : ComposableFuture, parTensor F G ≠ parTensor G F := by
  -- F has assumptions = A, G has assumptions = B
  let S_A : ParadigmaticState := { assumptions := A, constraints := Unit
                                  , infrastructure := Unit }
  let S_B : ParadigmaticState := { assumptions := B, constraints := Unit
                                  , infrastructure := Unit }
  let F : ComposableFuture := { S₀ := S_A
                               , τ := { source := S_A, target := S_A }
                               , S₁ := S_A }
  let G : ComposableFuture := { S₀ := S_B
                               , τ := { source := S_B, target := S_B }
                               , S₁ := S_B }
  -- If parTensor F G = parTensor G F, then A × B = B × A — contradiction with h
  refine ⟨F, G, fun heq => ?_⟩
  exact h (parTensor_comm_implies_prod_comm F G heq)

end ComposableFuture

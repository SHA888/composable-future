import ComposableFuture.Core.Operators

/-!
# Composable Future Laws

This module states and proves the fundamental laws of the Composable Future theory:
- Left identity (under well-formedness): Id >>= F = F (proved, OP9)
- Right identity (under well-formedness): F >>= Id = F (proved, OP10)
- Closure: Sequential composition produces a valid future (proved)
- Substantive associativity: `seqBind_assoc` (proved, ADR-0002)
- Well-formedness preservation: seqBind preserves well-formed futures (proved, OP12)
- Non-commutativity (component-order witness): `parTensor_component_order`

## Associativity (v0.2, ADR-0002)

`seqBind_assoc` proves **substantive** associativity. The v0.2 `Trajectory`
carries an internal `path : List ParadigmaticState`, and `seqBind` concatenates
paths: `(F >>= G).τ.path = F.τ.path ++ G.τ.path`. Associativity then follows
from `List.append_assoc` — the proof term is non-trivial and the result is
"paradigm-trajectories associate", not merely "endpoints associate".
-/

namespace ComposableFuture

/-- Left identity law (for well-formed futures): Id >>= F = F.

The well-formedness hypothesis is essential: `seqBind` builds the composed
trajectory from `F.τ.source` and `F.τ.path`. For the path to match,
we need `F.τ.source = F.S₀` (first half of `well_formed`). The path equality
`[] ++ F.τ.path = F.τ.path` is trivial.

v0.2: Φ is no longer a stored field, so no affordance equality is needed. -/
theorem left_identity (F : ComposableFuture) (hF : F.well_formed) :
    seqBind (idFuture F.S₀) F (by rfl) = F := by
  obtain ⟨S₀, ⟨src, path, tgt⟩, S₁, Φ⟩ := F
  have hsrc : src = S₀ := hF.1
  simp only [seqBind, idFuture, List.nil_append]
  rw [hsrc]

/-- Right identity law (for well-formed futures): F >>= Id = F.

The well-formedness hypothesis is required symmetrically: `seqBind` uses
`G.τ.target`, which under `G = idFuture F.S₁` equals `F.S₁`, so we need
`F.τ.target = F.S₁` (the other half of `well_formed`). The path equality
`F.τ.path ++ [] = F.τ.path` is trivial.

v0.3 (ADR-0005): no `[Subsingleton]` guard needed. `seqBind F (idFuture F.S₁)`
carries `Φ := (idFuture F.S₁).Φ = {F.S₁}`; matching this against `F.Φ` is
exactly `hF.2.2 : F.Φ = {F.S₁}` — the proof is substantive in the Φ conjunct,
not definitional. -/
theorem right_identity (F : ComposableFuture) (hF : F.well_formed) :
    seqBind F (idFuture F.S₁) (by rfl) = F := by
  obtain ⟨S₀, ⟨src, path, tgt⟩, S₁, Φ⟩ := F
  have htgt : tgt = S₁ := hF.2.1
  have hphi : Φ = {S₁} := hF.2.2
  simp only [seqBind, idFuture, List.append_nil]
  rw [htgt, hphi]

/-- Closure law: sequential composition produces a valid future.
    This is trivially satisfied by the existence of `seqBind` itself. -/
theorem closure (F G : ComposableFuture) (h : F.S₁ = G.S₀) :
  ∃ H : ComposableFuture, seqBind F G h = H := by
  exact ⟨seqBind F G h, rfl⟩

/-- Well-formedness preservation: seqBind preserves well-formed futures -/
theorem seqBind_well_formed (F G : ComposableFuture) (h : F.S₁ = G.S₀)
  (hF : F.well_formed) (hG : G.well_formed) :
  (seqBind F G h).well_formed := by
  simp only [seqBind, ComposableFuture.well_formed]
  exact ⟨hF.1, hG.2.1, hG.2.2⟩

/-- Substantive associativity of sequential bind.

With the enriched `Trajectory` carrying a `path` field, `seqBind` now
concatenates paths: `(F >>= G).τ.path = F.τ.path ++ G.τ.path`.
Associativity then follows from `List.append_assoc`.

This is the theorem that matches the paper's claim: sequential composition
of futures is associative. The proof term contains `List.append_assoc`,
not `rfl`. -/
theorem seqBind_assoc
    (F G H : ComposableFuture)
    (h₁ : F.S₁ = G.S₀) (h₂ : G.S₁ = H.S₀) :
    seqBind (seqBind F G h₁) H (by exact h₂) =
    seqBind F (seqBind G H h₂) (by exact h₁) := by
  simp [seqBind, List.append_assoc]

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
                               , τ := { source := S_A, path := [], target := S_A }
                               , S₁ := S_A
                               , Φ := {S_A} }
  let G : ComposableFuture := { S₀ := S_B
                               , τ := { source := S_B, path := [], target := S_B }
                               , S₁ := S_B
                               , Φ := {S_B} }
  -- If parTensor F G = parTensor G F, then A × B = B × A — contradiction with h
  refine ⟨F, G, fun heq => ?_⟩
  exact h (parTensor_comm_implies_prod_comm F G heq)

end ComposableFuture

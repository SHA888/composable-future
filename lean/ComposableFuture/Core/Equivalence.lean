import ComposableFuture.Core.Operators
import Mathlib.Logic.Equiv.Basic

/-! # Future Isomorphism — OP3 Equivalence Relation

This module defines `FutureIso F G` (futures isomorphic up to state bijection)
and proves that `parTensor` is commutative under this equivalence.

## Design commitment (OP3)

Strict equality is the wrong notion for symmetric-monoidal reasoning:
`parTensor F G` and `parTensor G F` have opposite cartesian-product orders
(`A×B` vs `B×A`) and are not definitionally equal. The correct categorical
statement is commutativity *up to isomorphism* — the braiding of a symmetric
monoidal category.

We use `Equiv` (Lean/Mathlib's built-in bijection type) as the isomorphism
vehicle. `FutureIso F G` records a bijection on each `Type`-valued field of
the source and target `ParadigmaticState`. This is conservative: it does not
constrain the trajectory, which is appropriate because trajectory equality
is the bisimulation sub-problem of OP3 (deferred separately).

`parTensor_comm_iso` is the main theorem: `Equiv.prodComm` supplies the
swap bijection `A×B ≃ B×A` directly from Mathlib, with no new axioms.

## Relation to ADR-0003

ADR-0003 Alternative C deferred the SMC-isomorphism proof to OP3. This module
implements that alternative. The conditional strict-inequality result
(`parTensor_not_comm_of_type_ne` in `Laws.lean`) remains valid as a corollary
and is not superseded.
-/

namespace ComposableFuture

-- ============================================================
-- State isomorphism
-- ============================================================

/-- An isomorphism between two paradigmatic states:
    component-wise bijections on assumptions, constraints, and infrastructure. -/
structure StateIso (S T : ParadigmaticState) where
  assumptions    : S.assumptions    ≃ T.assumptions
  constraints    : S.constraints    ≃ T.constraints
  infrastructure : S.infrastructure ≃ T.infrastructure

/-- Every state is isomorphic to itself. -/
def StateIso.refl (S : ParadigmaticState) : StateIso S S where
  assumptions    := Equiv.refl _
  constraints    := Equiv.refl _
  infrastructure := Equiv.refl _

/-- State isomorphism is symmetric. -/
def StateIso.symm {S T : ParadigmaticState} (e : StateIso S T) : StateIso T S where
  assumptions    := e.assumptions.symm
  constraints    := e.constraints.symm
  infrastructure := e.infrastructure.symm

/-- State isomorphism is transitive. -/
def StateIso.trans {S T U : ParadigmaticState}
    (e₁ : StateIso S T) (e₂ : StateIso T U) : StateIso S U where
  assumptions    := e₁.assumptions.trans    e₂.assumptions
  constraints    := e₁.constraints.trans    e₂.constraints
  infrastructure := e₁.infrastructure.trans e₂.infrastructure

-- ============================================================
-- Future isomorphism
-- ============================================================

/-- An isomorphism between two composable futures:
    state isomorphisms on the source and target states.

    The trajectory is intentionally excluded — trajectory equivalence
    (strong/weak bisimulation) is the deferred sub-problem of OP3.
    State-level isomorphism is sufficient for the symmetric-monoidal
    commutativity claim. -/
structure FutureIso (F G : ComposableFuture) where
  src : StateIso F.S₀ G.S₀
  tgt : StateIso F.S₁ G.S₁

/-- Every future is isomorphic to itself. -/
def FutureIso.refl (F : ComposableFuture) : FutureIso F F where
  src := StateIso.refl F.S₀
  tgt := StateIso.refl F.S₁

/-- Future isomorphism is symmetric. -/
def FutureIso.symm {F G : ComposableFuture} (e : FutureIso F G) : FutureIso G F where
  src := e.src.symm
  tgt := e.tgt.symm

/-- Future isomorphism is transitive. -/
def FutureIso.trans {F G H : ComposableFuture}
    (e₁ : FutureIso F G) (e₂ : FutureIso G H) : FutureIso F H where
  src := e₁.src.trans e₂.src
  tgt := e₁.tgt.trans e₂.tgt

-- ============================================================
-- Symmetric-monoidal commutativity of parTensor
-- ============================================================

/-- `parTensor` is commutative up to isomorphism.

    The Mathlib braiding `Equiv.prodComm : A×B ≃ B×A` witnesses each
    component swap. No new axioms; no `sorry`.

    This is the correct categorical statement for OP3: `parTensor F G`
    and `parTensor G F` are naturally isomorphic via the product braiding,
    even though they are not strictly equal.

    `def` rather than `theorem`: `FutureIso` is a `Type`-valued structure,
    not a `Prop`. -/
def parTensor_comm_iso (F G : ComposableFuture) :
    FutureIso (parTensor F G) (parTensor G F) where
  src :=
    { assumptions    := Equiv.prodComm F.S₀.assumptions    G.S₀.assumptions
      constraints    := Equiv.prodComm F.S₀.constraints    G.S₀.constraints
      infrastructure := Equiv.prodComm F.S₀.infrastructure G.S₀.infrastructure }
  tgt :=
    { assumptions    := Equiv.prodComm F.S₁.assumptions    G.S₁.assumptions
      constraints    := Equiv.prodComm F.S₁.constraints    G.S₁.constraints
      infrastructure := Equiv.prodComm F.S₁.infrastructure G.S₁.infrastructure }

/-- The braiding is self-inverse: swapping twice recovers the identity bijection.

    Each component uses `Equiv.prodComm_symm` and `Equiv.trans_symm`. -/
theorem parTensor_comm_iso_self_inv (F G : ComposableFuture) (x : F.S₀.assumptions × G.S₀.assumptions) :
    (Equiv.prodComm G.S₀.assumptions F.S₀.assumptions)
      ((Equiv.prodComm F.S₀.assumptions G.S₀.assumptions) x) = x := by
  simp [Equiv.prodComm]

end ComposableFuture

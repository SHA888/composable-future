import ComposableFuture.Core.Operators
import Mathlib.Logic.Equiv.Basic

/-! # Future Isomorphism — OP3 Equivalence Relation (COMPLETE)

This module defines the full equivalence relation for composable futures,
closing Open Problem 3 (equivalence relation / bisimulation).

## Two layers of equivalence

### Layer 1 — StateIso
Component-wise `Equiv` bijections on `ParadigmaticState` fields.

### Layer 2 — PathIso + TrajectoryEquiv  (bisimulation sub-problem, CLOSED)
`PathIso xs ys` is a pointwise `StateIso` along trajectory path lists.
`TrajectoryEquiv τ₁ τ₂` pairs `StateIso` on source/target with `PathIso` on paths.

This is the adaptation of strong bisimulation to the `List`-based path
representation: two trajectories are equivalent iff every step is matched
by a state isomorphism — the correct notion for deterministic (non-branching)
composable futures.

Design justification (Wang 2021 vs. strong vs. weak bisimulation):
- `Trajectory` has no silent transitions → weak bisimulation reduces to strong
- `Trajectory` has no branching structure → Wang 2021 history-preserving
  bisimilarity's extra history-isomorphism requirement is redundant here
- `PathIso` (= strong bisimulation adapted to lists) is therefore the minimal
  complete choice

### Layer 3 — FutureIso  (full equivalence, OP3 CLOSED)
`FutureIso F G` = `StateIso` on S₀ and S₁ + `TrajectoryEquiv` on τ.
Equivalence relation: `refl`, `symm`, `trans`.
`ComposableFuture` forms a `Setoid` under `Nonempty (FutureIso · ·)`.

### Main result
`parTensor_comm_iso F G : FutureIso (parTensor F G) (parTensor G F)` —
commutativity up to full isomorphism. Both sides produce `path = []`,
so `PathIso.nil : PathIso [] []` witnesses the trajectory path equivalence.

## Relation to ADR-0003

ADR-0003 Alternative C deferred the SMC-isomorphism proof to OP3. This module
implements that alternative and additionally closes the bisimulation sub-problem.
The conditional strict-inequality result (`parTensor_not_comm_of_type_ne` in
`Laws.lean`) remains valid as a corollary and is not superseded.

No new axioms; no `sorry`.
-/

namespace ComposableFuture

-- ============================================================
-- Layer 1: State isomorphism
-- ============================================================

/-- An isomorphism between two paradigmatic states:
    component-wise bijections on assumptions, constraints, and infrastructure. -/
structure StateIso (S T : ParadigmaticState) where
  assumptions    : S.assumptions    ≃ T.assumptions
  constraints    : S.constraints    ≃ T.constraints
  infrastructure : S.infrastructure ≃ T.infrastructure

def StateIso.refl (S : ParadigmaticState) : StateIso S S where
  assumptions    := Equiv.refl _
  constraints    := Equiv.refl _
  infrastructure := Equiv.refl _

def StateIso.symm {S T : ParadigmaticState} (e : StateIso S T) : StateIso T S where
  assumptions    := e.assumptions.symm
  constraints    := e.constraints.symm
  infrastructure := e.infrastructure.symm

def StateIso.trans {S T U : ParadigmaticState}
    (e₁ : StateIso S T) (e₂ : StateIso T U) : StateIso S U where
  assumptions    := e₁.assumptions.trans    e₂.assumptions
  constraints    := e₁.constraints.trans    e₂.constraints
  infrastructure := e₁.infrastructure.trans e₂.infrastructure

-- ============================================================
-- Layer 2a: Path isomorphism (bisimulation sub-problem, OP3)
-- ============================================================

/-- Pointwise state isomorphism along trajectory path lists.
    `PathIso xs ys` holds iff the lists have equal length and each
    position carries a `StateIso` — the list-indexed analogue of strong
    bisimulation for deterministic (non-branching) systems. -/
inductive PathIso : List ParadigmaticState → List ParadigmaticState → Type 1 where
  | nil  : PathIso [] []
  | cons : StateIso s t → PathIso xs ys → PathIso (s :: xs) (t :: ys)

def PathIso.refl : (xs : List ParadigmaticState) → PathIso xs xs
  | []      => .nil
  | x :: xs => .cons (StateIso.refl x) (PathIso.refl xs)

def PathIso.symm {xs ys : List ParadigmaticState} (p : PathIso xs ys) : PathIso ys xs :=
  match p with
  | .nil      => .nil
  | .cons e r => .cons e.symm r.symm

def PathIso.trans {xs ys zs : List ParadigmaticState}
    (p : PathIso xs ys) (q : PathIso ys zs) : PathIso xs zs :=
  match p, q with
  | .nil,         .nil         => .nil
  | .cons e₁ r₁, .cons e₂ r₂  => .cons (e₁.trans e₂) (r₁.trans r₂)

-- ============================================================
-- Layer 2b: Trajectory equivalence
-- ============================================================

/-- Trajectory trace equivalence: isomorphic source, path-wise states, and target.
    Two trajectories are equivalent iff their full state sequences are pointwise
    isomorphic via `StateIso`. -/
structure TrajectoryEquiv (τ₁ τ₂ : Trajectory) where
  src  : StateIso τ₁.source τ₂.source
  path : PathIso  τ₁.path   τ₂.path
  tgt  : StateIso τ₁.target τ₂.target

def TrajectoryEquiv.refl (τ : Trajectory) : TrajectoryEquiv τ τ where
  src  := StateIso.refl τ.source
  path := PathIso.refl  τ.path
  tgt  := StateIso.refl τ.target

def TrajectoryEquiv.symm {τ₁ τ₂ : Trajectory} (e : TrajectoryEquiv τ₁ τ₂) :
    TrajectoryEquiv τ₂ τ₁ where
  src  := e.src.symm
  path := e.path.symm
  tgt  := e.tgt.symm

def TrajectoryEquiv.trans {τ₁ τ₂ τ₃ : Trajectory}
    (e₁ : TrajectoryEquiv τ₁ τ₂) (e₂ : TrajectoryEquiv τ₂ τ₃) :
    TrajectoryEquiv τ₁ τ₃ where
  src  := e₁.src.trans  e₂.src
  path := e₁.path.trans e₂.path
  tgt  := e₁.tgt.trans  e₂.tgt

-- ============================================================
-- Layer 3: Full future isomorphism (OP3 CLOSED)
-- ============================================================

/-- A full isomorphism between two composable futures:
    `StateIso` on S₀ and S₁, plus `TrajectoryEquiv` on τ.

    This closes OP3 completely. The trajectory field implements the
    bisimulation sub-problem: every intermediate state in the path is
    matched by a state bijection. -/
structure FutureIso (F G : ComposableFuture) where
  src  : StateIso        F.S₀ G.S₀
  traj : TrajectoryEquiv F.τ  G.τ
  tgt  : StateIso        F.S₁ G.S₁

def FutureIso.refl (F : ComposableFuture) : FutureIso F F where
  src  := StateIso.refl       F.S₀
  traj := TrajectoryEquiv.refl F.τ
  tgt  := StateIso.refl       F.S₁

def FutureIso.symm {F G : ComposableFuture} (e : FutureIso F G) : FutureIso G F where
  src  := e.src.symm
  traj := e.traj.symm
  tgt  := e.tgt.symm

def FutureIso.trans {F G H : ComposableFuture}
    (e₁ : FutureIso F G) (e₂ : FutureIso G H) : FutureIso F H where
  src  := e₁.src.trans  e₂.src
  traj := e₁.traj.trans e₂.traj
  tgt  := e₁.tgt.trans  e₂.tgt

/-- `ComposableFuture` forms a setoid under future isomorphism. -/
instance : Setoid ComposableFuture where
  r F G  := Nonempty (FutureIso F G)
  iseqv  := {
    refl  := fun F     => ⟨FutureIso.refl F⟩
    symm  := fun ⟨e⟩   => ⟨e.symm⟩
    trans := fun ⟨e₁⟩ ⟨e₂⟩ => ⟨e₁.trans e₂⟩
  }

-- ============================================================
-- Symmetric-monoidal commutativity of parTensor (OP3 CLOSED)
-- ============================================================

/-- `parTensor` is commutative up to full isomorphism.

    `Equiv.prodComm : A×B ≃ B×A` witnesses the state component swaps.
    `PathIso.nil` witnesses the trajectory path equivalence: `parTensor`
    always produces `path = []`, so both sides trivially satisfy `PathIso [] []`.

    This closes OP3 completely:
    - SMC commutativity  ✓  (src/tgt StateIso via Equiv.prodComm)
    - Bisimulation sub-problem  ✓  (traj.path = PathIso.nil, empty paths match)

    `def` rather than `theorem`: `FutureIso` is `Type`-valued, not `Prop`-valued.
    No new axioms; no `sorry`. -/
def parTensor_comm_iso (F G : ComposableFuture) :
    FutureIso (parTensor F G) (parTensor G F) where
  src  :=
    { assumptions    := Equiv.prodComm F.S₀.assumptions    G.S₀.assumptions
      constraints    := Equiv.prodComm F.S₀.constraints    G.S₀.constraints
      infrastructure := Equiv.prodComm F.S₀.infrastructure G.S₀.infrastructure }
  traj :=
    { src  := { assumptions    := Equiv.prodComm F.S₀.assumptions    G.S₀.assumptions
                constraints    := Equiv.prodComm F.S₀.constraints    G.S₀.constraints
                infrastructure := Equiv.prodComm F.S₀.infrastructure G.S₀.infrastructure }
      path := PathIso.nil
      tgt  := { assumptions    := Equiv.prodComm F.S₁.assumptions    G.S₁.assumptions
                constraints    := Equiv.prodComm F.S₁.constraints    G.S₁.constraints
                infrastructure := Equiv.prodComm F.S₁.infrastructure G.S₁.infrastructure } }
  tgt  :=
    { assumptions    := Equiv.prodComm F.S₁.assumptions    G.S₁.assumptions
      constraints    := Equiv.prodComm F.S₁.constraints    G.S₁.constraints
      infrastructure := Equiv.prodComm F.S₁.infrastructure G.S₁.infrastructure }

/-- The braiding is self-inverse at the element level. -/
theorem parTensor_comm_iso_self_inv (F G : ComposableFuture)
    (x : F.S₀.assumptions × G.S₀.assumptions) :
    (Equiv.prodComm G.S₀.assumptions F.S₀.assumptions)
      ((Equiv.prodComm F.S₀.assumptions G.S₀.assumptions) x) = x := by
  simp [Equiv.prodComm]

end ComposableFuture

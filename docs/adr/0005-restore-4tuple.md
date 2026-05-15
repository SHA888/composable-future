# ADR-0005 — Restore 4-tuple: Add Stored Φ Field to ComposableFuture

| Field         | Value                                             |
| ------------- | ------------------------------------------------- |
| Status        | **Accepted** (2026-05-15)                         |
| Date          | 2026-05-15                                        |
| Reversibility | **One-way door** — changes public theorem surface |
| Supersedes    | v0.2 derived-Φ refactor (informal, no prior ADR)  |
| Superseded by | —                                                 |

---

## Context

### The split

The v0.2 refactor removed `Φ` as a stored field from `ComposableFuture` to resolve:

1. A universe mismatch (`AffordanceDescriptor S₀ : Type 1` while `ComposableFuture : Type 0`)
2. The recursive type problem: `F = (S₀, τ, S₁, Φ)` where `Φ : S₁ → 𝒫(F)` — `F` appears
   in its own definition

The resolution was `AffordanceSet S := {F : ComposableFuture | F.S₀ = S}`, making Φ a
global set comprehension derived from any state. This created a theory split:

| Dimension           | Paper (v0.1)              | Lean (v0.2)                   |
| ------------------- | ------------------------- | ----------------------------- |
| Arity               | 4-tuple                   | 3-tuple                       |
| Φ status            | Stored, future-specific   | Derived, state-indexed        |
| Null future Φ       | `Φ∅(S) = ∅`               | `AffordanceSet S` (non-empty) |
| Identity law result | carries `Φ∅`              | carries `F.Φ`                 |
| `⊗` affordances     | `Φ^A × Φ^B`               | not implemented               |
| Remark 4.1          | affordances collapse to ∅ | directly contradicted         |

Eight divergences documented 2026-05-15.

### The recursive type — resolved

`Φ : Set ComposableFuture = ComposableFuture → Prop` is admissible in Lean 4.
`Set` is a function type, not an inductive occurrence. There is no strict positive
occurrence violation. Storing `Φ : Set ComposableFuture` in `ComposableFuture` is
type-theoretically safe at the same universe level. This was the core concern that
triggered the v0.2 refactor; it is not an obstacle to restoration.

### The universe mismatch — resolved

`Set ComposableFuture : Type` lives in the same universe as `ComposableFuture`.
The v0.2 mismatch arose from using `AffordanceDescriptor S₀ : Type 1` (which contains
`ParadigmaticState` fields of type `Type`). Using `Set ComposableFuture` directly
avoids `AffordanceDescriptor` entirely and has no universe issue.

---

## The Design Decision (locked 2026-05-15)

**Option B selected:** `idFuture S` carries `Φ = AffordanceSet S`.

### Decision rationale

Three options were weighed on five axes:

| Axis                                          | Option A (`Φ∅ = ∅`)      | Option B (`AffordanceSet S`)           | Option C (parameterized)   |
| --------------------------------------------- | ------------------------ | -------------------------------------- | -------------------------- |
| Identity law holds as stated                  | ✗ Requires reformulation | ✓ Holds for well-formed futures        | ✓ Trivially                |
| Lean proof burden                             | High                     | Low                                    | High (invasive call sites) |
| Paper 1 distinguishes idFuture from terminate | ✗ No                     | ✓ Yes (by Φ value)                     | ✓ Yes                      |
| Paper 2 enrichment composes cleanly           | ✓                        | ✓ Terminate carries Φ = ∅ specifically | Less clear                 |
| Chemero relational ontology                   | ✗ Contradicts            | ✓ Supports                             | Neutral                    |

**Option A rejected:** The paper's Proposition 4.1 claims `F >>= Id = F`. Under Option A,
the result carries `Φ∅ = ∅ ≠ F.Φ` in general, making the identity law false as stated.
Remark 4.1 ("affordances collapse to ∅") conflated identity with termination. Option A
requires weakening the identity law — a retreat, not a refinement.

**Option C rejected:** Parameterizing `idFuture` with `Φ` makes the type signature invasive
(40+ call sites), introduces ambiguity about which Φ the caller should pass, and makes
the identity future "context-relative" in a way that obscures its mathematical role.

**Option B rationale:**

1. **Mathematical:** A null transition changes nothing. A transition that changes nothing
   changes nothing about what is accessible. Affordances are relations between composition
   context and state features (Chemero 2003); if neither changes, the relational structure
   is preserved. `AffordanceSet S` is exactly the set of futures accessible from S — the
   null future correctly carries this entire set.

2. **Lean:** `right_identity` holds for well-formed futures without `Subsingleton` guard.
   Both sides carry `AffordanceSet F.S₁`; the proof is clean.

3. **Paper 1 / Paper 2 separation:** Under Option B, terminate (Paper 2) is the operation
   that genuinely zeros affordances. It is distinguished from identity by its resource
   signature under Coecke–Fritz–Spekkens (2016) enrichment. Paper 1 already provides the
   qualitative distinction (Φ-based); Paper 2 adds the quantitative one (resource-based).
   The two papers compose cleanly without Paper 1 needing to be revised when Paper 2 arrives.

4. **Remark 4.1 revision:** The revision is an upgrade, not a retreat. The new Remark 4.1:
   "The affordance set of `F >>= Id_S₁` equals `F.Φ`: composing with the null future
   preserves all affordances accessible from `S₁`, because a transition that changes nothing
   changes nothing about what is accessible. The operation that genuinely zeros affordances
   is the terminate operator (Paper 2), which carries a non-trivial resource signature
   under the enrichment of Coecke, Fritz, and Spekkens (2016)."

---

## Decision (Accepted)

Add `Φ : Set ComposableFuture` as a stored field of `ComposableFuture`. Set
`idFuture S` to carry `Φ = AffordanceSet S`. Extend `well_formed` with
`F.Φ = AffordanceSet F.S₁`. Update all four operators with Φ propagation rules.

### Theorem surface changes

```lean
-- New ComposableFuture (4-tuple restored)
structure ComposableFuture where
  S₀ : ParadigmaticState
  τ  : Trajectory
  S₁ : ParadigmaticState
  Φ  : Set ComposableFuture   -- stored; Set ComposableFuture = ComposableFuture → Prop

-- Extended well_formed
def ComposableFuture.well_formed (F : ComposableFuture) : Prop :=
  F.τ.source = F.S₀ ∧ F.τ.target = F.S₁ ∧ F.Φ = AffordanceSet F.S₁

-- idFuture (Option B)
def idFuture (S : ParadigmaticState) : ComposableFuture :=
  { S₀ := S
    τ  := { source := S, path := [], target := S }
    S₁ := S
    Φ  := AffordanceSet S }

-- Operator Φ propagation rules (per paper)
-- seqBind:   result.Φ = G.Φ
-- parTensor: result.Φ = product affordance set (encode as Set ComposableFuture)
-- fork:      result.Φ = F.Φ ∪ G.Φ  (coproduct — Paper 1 scope)
-- merge:     result.Φ = F.Φ ∩ G.Φ  (intersection — symmetric case only)
```

### Identity law (post-ADR-0005)

```lean
-- right_identity: no Subsingleton guard needed
theorem right_identity (F : ComposableFuture) (hF : F.well_formed) :
    seqBind F (idFuture F.S₁) (by rfl) = F := by
  -- (seqBind F (idFuture F.S₁)).Φ = (idFuture F.S₁).Φ = AffordanceSet F.S₁ = F.Φ
  -- via hF.2.2 : F.Φ = AffordanceSet F.S₁
  ...
```

### FutureIso extension

```lean
structure FutureIso (F G : ComposableFuture) where
  src  : StateIso F.S₀ G.S₀
  traj : TrajectoryEquiv F.τ G.τ
  tgt  : StateIso F.S₁ G.S₁
  phi  : F.Φ = G.Φ   -- propositional equality on Set ComposableFuture
```

---

## Consequences

**Must update:**

- `lean/ComposableFuture/Core/Future.lean` — add `Φ` field; extend `well_formed`
- `lean/ComposableFuture/Core/Operators.lean` — all operators propagate `Φ`
- `lean/ComposableFuture/Core/Laws.lean` — identity law proof restructured; no `Subsingleton`
- `lean/ComposableFuture/Core/Affordance.lean` — `AffordanceDescriptor` remains helper
- `lean/ComposableFuture/Core/Effect.lean` — `EffectfulFuture.effect` simplified
- `lean/ComposableFuture/Core/Equivalence.lean` — `FutureIso` gains `phi` field

**Not affected:**

- `lean/ComposableFuture/Core/Indexed.lean` — indexed structure independent
- `lean/ComposableFuture/Core/Probabilistic.lean` — independent
- `lean/ComposableFuture/Core/Stateless.lean` — minimal surface change

**Paper changes (Zenodo v0.2):**

- Def 2.3 revised: `Id_S := (S, id_S, S, AffordanceSet S)`
- Remark 4.1 revised: null future preserves Φ; terminate is Paper 2
- Proposition 4.1 proof: identity holds fully, result carries `F.Φ`
- Operators §3: parTensor carries `Φ^A × Φ^B` (implemented); fork carries `Φ^A ⊔ Φ^B`;
  merge carries `Φ^A ∩ Φ^B` (symmetric only; absorptive deferred)

**Estimated scope:** ~100–120 lines across 6 files.

---

## Falsifying outcome

After ADR-0005 implementation, if any of these hold, the ADR has failed:

1. `right_identity` requires `sorry` or a hypothesis not present in the paper
2. `lake build` fails or reports warnings
3. The paper's Proposition 4.1 proof sketch is not corroborated by the Lean proof
4. `FutureIso` breaks for futures with identical states but different `Φ` values

---

## Gate condition

`lake build` passes with:

- 0 errors
- 0 warnings
- 0 sorry

Verify: `#print right_identity` — proof term must use `hF.2.2` (the Φ well_formed conjunct),
not `rfl` or `Subsingleton`. This confirms the proof is substantive, not definitional.

---

## Alternatives considered

**Option A (`Φ∅ = ∅`):**
Rejected. Identity law becomes false as stated in the paper. Remark 4.1 survives literally
but Paper 1's core law weakens. Option B's revision of Remark 4.1 is mathematically superior.

**Option C (parameterized `idFuture`):**
Rejected. Invasive type signature changes (~40 call sites). Conceptually confusing —
"doing nothing" should not require the caller to specify what affordances to preserve.

**Keep v0.2 derived-Φ and revise paper to match:**
Rejected. Would require removing the 4-tuple from the abstract, rewriting Def 2.2,
removing Remark 4.1, and accepting a philosophically weaker theory. The stored-Φ
with Option B is strictly richer.

**Coinductive definition:**
Correct but significantly increases formalization complexity. `Set ComposableFuture`
achieves the same semantic content without coinductive machinery. Deferred indefinitely.

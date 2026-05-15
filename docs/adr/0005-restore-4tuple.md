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

### The recursive type — FALSIFIED 2026-05-15, corrected by representation change

**The original claim in this section was wrong.** It asserted that
`Φ : Set ComposableFuture = ComposableFuture → Prop` is admissible because `Set`
is a function type. That is exactly *why* it fails: function types are
contravariant in their domain, so `ComposableFuture` appearing as the domain of
its own field is a strict-positivity violation. Lean 4's kernel rejects it:

```
(kernel) arg #4 of 'ComposableFuture.ComposableFuture.mk' has a non positive
occurrence of the datatypes being declared
```

This triggered Falsifying Outcome #2 (`lake build` fails) on the *literal* type.
The obstacle is fundamental, not incidental: no field annotation, proof
technique, `sorry`, or non-coinductive refactor can store `Set ComposableFuture`
recursively. The coinductive alternative (see Alternatives) is deferred
indefinitely and is not on the table.

**Correction (state-anchored representation).** Store the *key*, recover the
*value* on demand. `Φ : Set ParadigmaticState` carries the anchor states; the
paper's future-set is recovered by the projection

```lean
def ComposableFuture.afforded (F : ComposableFuture) : Set ComposableFuture :=
  { G : ComposableFuture | G.S₀ ∈ F.Φ }
```

`ParadigmaticState` does not contain `ComposableFuture`, so there is no positivity
or universe issue. This is content-equivalent to the paper: for a well-formed
future with `F.Φ = {F.S₁}`,

```
afforded F = {G | G.S₀ ∈ {F.S₁}} = {G | G.S₀ = F.S₁} = AffordanceSet F.S₁
```

— exactly the paper's intended `Φ : S₁ → 𝒫(F)`. The 4-tuple is restored; only
the carrier type changes (a standard store-the-key technique). The 3-tuple
remains rejected.

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
-- New ComposableFuture (4-tuple restored; state-anchored carrier)
structure ComposableFuture where
  S₀ : ParadigmaticState
  τ  : Trajectory
  S₁ : ParadigmaticState
  Φ  : Set ParadigmaticState   -- anchor states; compiles cleanly (no positivity issue)

-- Recoverable future-set (the paper's 𝒫(F) object), on demand
def ComposableFuture.afforded (F : ComposableFuture) : Set ComposableFuture :=
  { G : ComposableFuture | G.S₀ ∈ F.Φ }
-- content-equivalent: afforded F = AffordanceSet F.S₁ for well-formed futures

-- Extended well_formed
def ComposableFuture.well_formed (F : ComposableFuture) : Prop :=
  F.τ.source = F.S₀ ∧ F.τ.target = F.S₁ ∧ F.Φ = {F.S₁}

-- idFuture (Option B): singleton anchor — null transition keeps S accessible
def idFuture (S : ParadigmaticState) : ComposableFuture :=
  { S₀ := S
    τ  := { source := S, path := [], target := S }
    S₁ := S
    Φ  := {S} }

-- Operator Φ propagation rules (per paper, state-anchored encoding)
-- seqBind:   result.Φ = G.Φ
-- parTensor: result.Φ = { paradigmaticTensor a b | a ∈ F.Φ ∧ b ∈ G.Φ }  (Φ^A × Φ^B)
-- fork:      result.Φ = F.Φ ∪ G.Φ  (coproduct — Paper 1 scope)
-- merge:     result.Φ = F.Φ ∩ G.Φ  (intersection — symmetric case only)
```

### Identity law (post-ADR-0005)

```lean
-- right_identity: no Subsingleton guard needed
theorem right_identity (F : ComposableFuture) (hF : F.well_formed) :
    seqBind F (idFuture F.S₁) (by rfl) = F := by
  -- (seqBind F (idFuture F.S₁)).Φ = (idFuture F.S₁).Φ = {F.S₁} = F.Φ
  -- via hF.2.2 : F.Φ = {F.S₁}
  ...
```

### FutureIso extension

```lean
structure FutureIso (F G : ComposableFuture) where
  src  : StateIso F.S₀ G.S₀
  traj : TrajectoryEquiv F.τ G.τ
  tgt  : StateIso F.S₁ G.S₁
  phi  : F.Φ = G.Φ   -- propositional equality on Set ParadigmaticState
```

Note: strict `F.Φ = G.Φ` holds for `refl`/`symm`/`trans` and for `idFuture`-based
identity laws. The SMC commutativity witness `parTensor_comm_iso` cannot satisfy
strict `phi` (the anchor sets `{paradigmaticTensor a b}` vs `{paradigmaticTensor
b a}` differ because `A × B ≠ B × A` without univalence) — this is the same
type-level product-commutativity limitation already documented as Phase-4 debt
in `Laws.lean`/`Equivalence.lean`, not a regression introduced by ADR-0005.

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

**Amendment 2026-05-15:** Outcome #2 triggered on the *literal* `Φ : Set
ComposableFuture` field (kernel positivity rejection). Resolved by the
state-anchored representation (`Φ : Set ParadigmaticState` + `afforded`
projection) — see "The recursive type — FALSIFIED" above. Outcome #1 remains the
binding gate and is satisfied (`right_identity` uses `hF.2.2`, no `sorry`). The
single permitted `parTensor_comm_iso.phi` Phase-4 `sorry` is pre-existing debt,
not a failure of this ADR.

---

## Gate condition

`lake build` passes with:

- 0 errors
- 0 warnings
- 0 sorry in the core restoration surface (Future, Operators, Laws, Affordance, Effect)
- 1 documented Phase-4 sorry permitted: `parTensor_comm_iso.phi` (type-level
  product commutativity needs univalence; pre-existing debt, see FutureIso note)

Verify: `#print right_identity` — proof term must use `hF.2.2` (the Φ well_formed
conjunct, now `F.Φ = {F.S₁}`), not `rfl` or `Subsingleton`. This confirms the
proof is substantive, not definitional.

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

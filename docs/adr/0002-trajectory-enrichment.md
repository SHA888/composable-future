# ADR-0002 — Trajectory Enrichment for Substantive Associativity

| Field | Value |
|---|---|
| Status | **Proposed** |
| Date | 2026-04-29 |
| Reversibility | **One-way door** — see §Cost of reversal |
| Supersedes | — |
| Superseded by | — |

---

## Context

### What exists

`Trajectory` currently has exactly two fields:

```lean
structure Trajectory where
  source : ParadigmaticState
  target : ParadigmaticState
```

`seqBind F G h` builds a new future whose `τ.source = F.τ.source` and
`τ.target = G.τ.target`, discarding everything in between. As a result,
`seqBind_endpoint_assoc` closes by `rfl` — both `(F >>= G) >>= H` and
`F >>= (G >>= H)` produce the record `{source := F.τ.source, target := H.τ.target}`.
This is *endpoint-extraction associativity*, not *paradigm-trajectory
composition associativity*.

The paper (§3, Associativity law) claims: sequential composition of futures
is associative. The informal meaning is that the path through paradigmatic
states associates — `(P₀ → P₁ → P₂) → P₃` and `P₀ → (P₁ → P₂ → P₃)` both
witness the same traversal. This is NOT what the current proof shows.

### Why it matters

Three existing theorems are named as "endpoint-extraction" explicitly in
their docstrings to pre-flag this gap:

- `Laws.seqBind_endpoint_assoc` (comment: "endpoint extraction, not trajectory composition")
- `Stateless.assoc_stateless_endpoint`
- `IndexedFuture.endpoint_assoc`
- `EffectfulFuture.seq_endpoint_assoc`
- `EffectfulComputation.bind_endpoint_assoc`

Every call site of `Trajectory.endpoint_ext` (renamed from `ext_eq` for
this reason) is also pre-flagged: it asserts that two trajectories with equal
endpoints are equal — which becomes FALSE once a `path` field is added.

The pre-flagging was explicitly done in the v0.1 refactor so that this ADR
would find them automatically.

### What a substantive proof requires

If `Trajectory` carries `path : List ParadigmaticState` (intermediate stages),
`seqBind` would concatenate:

```
(F >>= G).τ.path = F.τ.path ++ [F.S₁] ++ G.τ.path
```

Then `(F >>= G) >>= H` and `F >>= (G >>= H)` produce the same path
`F.τ.path ++ [F.S₁] ++ G.τ.path ++ [G.S₁] ++ H.τ.path` by
`List.append_assoc`. That is the substantive claim.

---

## Problem statement

> Can we prove that paradigmatic trajectory composition is associative — not
> just that endpoint-pairing is associative?

**Falsifying outcome**: A proof attempt produces a goal that closes only
because `seqBind` still discards intermediate trajectory data (i.e., the
proof is still just `rfl` or `simp [seqBind]` with no `List.append_assoc`
in the proof term). If that happens, the refactor was incomplete.

---

## Constraint check (docs/constraints.md)

- **Lean 4 v4.30.0-rc1**: `List.append_assoc` is in `Init.Data.List.Basic`,
  available without Mathlib import.
- **`Trajectory.endpoint_ext`**: explicitly pre-flagged at 5+ call sites.
  All will need updating — estimated 30–50 lines across `Laws.lean`,
  `Effect.lean`, `Indexed.lean`.
- **Paper commitment**: the paper claims associativity; this refactor makes
  the Lean proof match that claim.
- **Team constraint**: `List.append_assoc` proofs are within solo-researcher
  Lean expertise. No collaborator required for this ADR.

---

## Decision

Add `path : List ParadigmaticState` to `Trajectory` and redefine `seqBind`
to concatenate paths. Prove substantive associativity via `List.append_assoc`.

### Theorem signature (public surface — one-way contract)

```lean
-- New Trajectory definition
structure Trajectory where
  source : ParadigmaticState
  path   : List ParadigmaticState   -- intermediate stages
  target : ParadigmaticState

-- New seqBind
def seqBind (F G : ComposableFuture) (h : F.S₁ = G.S₀) : ComposableFuture :=
  { S₀ := F.S₀
    τ  := { source := F.τ.source
          , path   := F.τ.path ++ [F.S₁] ++ G.τ.path
          , target := G.τ.target }
    S₁ := G.S₁ }

-- Substantive associativity (replaces seqBind_endpoint_assoc)
theorem seqBind_assoc
    (F G H : ComposableFuture)
    (h₁ : F.S₁ = G.S₀) (h₂ : G.S₁ = H.S₀) :
    seqBind (seqBind F G h₁) H (by simp [seqBind, h₂]) =
    seqBind F (seqBind G H h₂) (by exact h₁) := by
  simp [seqBind, List.append_assoc]
```

The proof closes by `simp [seqBind, List.append_assoc]` — a non-trivial use
of list associativity, not a `rfl`.

### What `Trajectory.endpoint_ext` becomes

The lemma `Trajectory.endpoint_ext` becomes FALSE under the new definition.
It must be **deleted** (not weakened) and every caller updated. Call sites
that only care about endpoints should extract `source` and `target` manually.

### Identity laws

With the path representation, `idFuture S` should carry an empty path:
```lean
def idFuture (S : ParadigmaticState) : ComposableFuture :=
  { S₀ := S
    τ  := { source := S, path := [], target := S }
    S₁ := S }
```

Left identity: `seqBind (idFuture F.S₀) F h` produces
`path = [] ++ [F.S₀] ++ F.τ.path`. For this to equal `F.τ.path`, we need
`[F.S₀] ++ F.τ.path = F.τ.path` — which requires `F.τ.source = F.S₀`
(the `well_formed` hypothesis). So **identity laws remain conditional** on
`well_formed` after this refactor. Removing that hypothesis requires a
separate ADR (not yet proposed; deferred to after this refactor lands).

---

## Consequences

**Must update:**
- `lean/ComposableFuture/Core/Future.lean` — add `path` field, update `endpoint_ext` → delete
- `lean/ComposableFuture/Core/Operators.lean` — all 5 operators need `path` logic
- `lean/ComposableFuture/Core/Laws.lean` — replace `seqBind_endpoint_assoc` with `seqBind_assoc`; update identity-law proofs
- `lean/ComposableFuture/Core/Stateless.lean` — update `assoc_stateless_endpoint` → `assoc_stateless`
- `lean/ComposableFuture/Core/Indexed.lean` — update `IndexedFuture.seqBind`, `endpoint_assoc`
- `lean/ComposableFuture/Core/WeakAssoc.lean` — weak associativity theorems may strengthen
- `lean/ComposableFuture/Core/Effect.lean` — update `seq_endpoint_assoc` → `seq_assoc`
- `lean/ComposableFuture/Core/Affordance.lean` — `composeSequential` may need path logic

**Estimated scope:** ~150–200 lines of proof updates across 8 files.

**Gate**: `lake build` passes and `seqBind_assoc` proof term contains
`List.append_assoc` (verifiable with `#print seqBind_assoc`).

---

## Cost of reversal (one-way door justification)

Once `Trajectory` gains a `path` field, rolling back requires:
- Removing the field and all `path`-threaded proof terms
- Re-introducing `Trajectory.endpoint_ext`
- Reverting 8 files to endpoint-only proofs

Estimated reversal cost: 4–6 hours. Classified as one-way because the
substantive-associativity proof is the main deliverable of Phase 5, and
the paper's claim cannot be honoured without it.

---

## Alternatives considered

**A. Add `path : List ParadigmaticState` to `Trajectory` (chosen).**
Direct, matches the mathematical intuition, proof closes by `List.append_assoc`.

**B. Reframe the paper's associativity claim as endpoint-extraction.**
Requires a Zenodo v0.2. The paper's text says "sequential composition of
futures is associative" — endpoint-extraction is not what a reader would
understand. Rejected: weakens the published claim without mathematical
justification.

**C. Use a free-monad representation for trajectories (`Trajectory.Comp`
as a list of atomic steps).**
Correct but significantly increases the formalization complexity — requires
defining a quotient by congruence or a canonical form. The `List`
representation in Option A achieves the same mathematical content with
less Lean infrastructure. Deferred to Phase 6 if a richer trajectory
model is needed.

**D. Accept the current endpoint-extraction proof as Phase 5 complete.**
Rejects the paper's claim. Not acceptable under the constraint that Lean
proofs corroborate the paper.

# ADR-0001 — Record Proof Architecture Decisions

| Field | Value |
|---|---|
| Status | **Accepted** |
| Date | 2026-04-29 |
| Reversibility | Two-way door (changing the process, not the proofs) |
| Supersedes | — |
| Superseded by | — |

---

## Context

The Composable Future project makes mathematical claims in a Zenodo preprint
(doi: 10.5281/zenodo.19433811) and is formalizing them in Lean 4. As the
formalization deepens into Phase 5, decisions arise that have lasting
consequences: which proof strategy to use for a given theorem, whether a
weaker result is an acceptable substitute, how to handle a type-theoretic
obstacle, and how to stage work that requires a collaborator.

Without a decision record discipline, these choices happen implicitly in
commit messages or not at all. The result is ADR drift: the implementation
diverges from the paper, and future contributors (or the author six months
later) cannot reconstruct why a particular approach was taken.

---

## Decision

We adopt Architecture Decision Records (ADRs) — adapted here as *Proof
Decision Records* — for any decision that:

1. Changes a theorem's statement (hypotheses, conclusion, or universe level).
2. Introduces or removes a sorry or axiom.
3. Changes a core data structure (`ComposableFuture`, `Trajectory`,
   `AffordanceSet`, `ParadigmaticState`) in a way that invalidates existing
   proofs.
4. Chooses a proof strategy that forecloses an alternative (e.g., choosing
   an indexed-monad approach over a fibered-category approach for associativity).
5. Pins or upgrades a Mathlib or Lean 4 version.

ADRs live in `docs/adr/`, are numbered sequentially, and follow the template
in this document. They are immutable once accepted; changes go through a
supersession ADR that explicitly states why the prior decision existed
(PLAN_SKILLS §2.4 — Chesterton's Fence).

The ADR template fields are: Status, Date, Reversibility, Context, Decision,
Consequences, Falsifying outcome, Alternatives considered, Supersedes /
Superseded by.

---

## Consequences

- Every PR or commit that falls into the categories above must reference an
  ADR number (e.g., `implements ADR-0002`) or create a new ADR.
- `TODO.md` P5.x items that correspond to ADRs are cross-referenced.
- The constraint inventory (`docs/constraints.md`) is reviewed when a new
  ADR is proposed; if a constraint has changed, update it first.

---

## Falsifying outcome

If after six months there are Lean file changes that alter theorem statements,
introduce sorry, or modify core data structures without a corresponding ADR,
this ADR has failed. Measurement: `git log --follow lean/ComposableFuture/Core/`
cross-referenced against `docs/adr/`.

---

## Alternatives considered

**A. Commit messages only.** Fast, zero overhead. Fails because commit
messages are not searchable by decision type, and don't enforce the
"why the previous decision existed" discipline.

**B. GitHub Issues for each decision.** Better discoverability but
requires network access to read and doesn't travel with the repo.

**C. This ADR format (chosen).** Files in the repo, co-located with the
code, readable offline, version-controlled.

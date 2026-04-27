# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Nature

This is a research repository, not a typical software project. It contains three parallel tracks:

1. **Lean 4 formalization** (`lean/`) — the active development surface
2. **LaTeX positioning paper** (`paper/`) — Level 1 publication artifact
3. **Python audit tooling** (`search.py`, `refinement.py`, `audit/`) — **frozen**; Phase 0 synthesis is complete

The central object is a `ComposableFuture`, a 4-tuple `F = (S₀, τ, S₁, Φ)` representing a paradigmatic transition. The theory is being mechanized in Lean 4 with Mathlib.

## Commands

### Lean (primary)

```bash
cd lean
lake update      # one-time, fetch Mathlib (pinned to v4.30.0-rc1 via lean-toolchain)
lake build       # build whole library
```

There is no test suite separate from the build — proof correctness *is* the test. A successful `lake build` means every theorem checks and there are no unfilled `sorry`s outside those documented as open problems.

The Lean toolchain version is pinned in `lean/lean-toolchain` and managed by elan; do not edit unless intentionally bumping. Mathlib is pinned in `lean/lakefile.lean` to `v4.30.0-rc1` — must match the toolchain.

### Python audit scripts — DO NOT RUN on the main `audit/` tree

```bash
uv sync                                  # install deps
uv run search.py --version audit-v2 all  # only with --version flag, into a NEW directory
uv run refinement.py --version audit-v2 4
```

Running `search.py` or `refinement.py` without `--version` will prompt and *overwrite* the manually completed synthesis in `audit/domain-N-*.md`. Phase 0 is complete; treat those files as read-only artifacts. New audit work goes in a separate directory (e.g., `audit-v2/`) via the `--version` flag.

### LaTeX paper

```bash
cd paper && latexmk -pdf composable-future-level1.tex
```

The compiled `paper/*.pdf` is checked in (note the `!paper/*.pdf` exception in `.gitignore`).

## Architecture

### Lean module layout (`lean/ComposableFuture/Core/`)

- `Future.lean` — base types: `ParadigmaticState`, `Trajectory`, `ComposableFuture`, `well_formed` predicate. **`AffordanceSet` is currently `Unit`** as a v0.1 placeholder; the richer `AffordanceDescriptor` lives in `Affordance.lean` but is not yet wired in due to a universe mismatch (see comment in `Future.lean` lines 24–34).
- `Operators.lean` — `seqBind` (`>>=`), `parTensor` (`⊗`), `fork` (`|`), `merge` (`⊕`), `idFuture`. All five use **left-biased / endpoint-only** v0.1 semantics: `fork` collapses to F's branch, `seqBind` extracts only `F.τ.source` and `G.τ.target` and discards intermediate trajectory data.
- `Laws.lean` — identity (under `well_formed`), closure, **endpoint-extraction** associativity, well-formedness preservation, parTensor non-commutativity (component-order witness, not strict inequality — strict inequality requires univalence).
- `Stateless.lean` — restricted-domain associativity (currently vacuous: all trajectories satisfy `isStateless` because the predicate is `True`).
- `Indexed.lean` — graded/indexed monad scaffolding. `TrajectoryType := Unit` is a placeholder; Phase 2 will promote it to a free monoid.
- `WeakAssoc.lean` — weak associativity at affordance level and state level. **These are honest as stated** (unlike the endpoint-extraction theorems).
- `Probabilistic.lean` — Phase 3 Kleisli extension stubs (OP13–OP16).
- `Affordance.lean` — Phase 4 work on Φ as a dependent type.

### The associativity caveat — read this before claiming results

The single most important conceptual point in this codebase: **endpoint-extraction associativity is NOT substantive paradigm-composition associativity.**

Because v0.1 `Trajectory` carries only `source` and `target` (no internal path), `seqBind` does not concatenate trajectories — it re-pairs endpoints. Theorems like `Laws.seqBind_endpoint_assoc`, `Stateless.assoc_stateless_endpoint`, and `IndexedFuture.endpoint_assoc` close by `rfl` *because of this trivial extraction*, not because trajectory composition is genuinely associative.

The substantive theorem is open Phase 2 work: give `Trajectory` a `path : List ParadigmaticState` field, define `seqBind` to concatenate paths, and prove associativity from `List.append_assoc`. Sketch in `proofs/notes.md` §"Open: Substantive Associativity". When discussing or extending associativity proofs, preserve this distinction in comments and commit messages — the recent commits `becd8d7` and `bafc41d` exist precisely to relabel earlier overclaims.

### Open-problem numbering

Two parallel OP numbering systems exist. Don't conflate them:

- **Internal** (`proofs/notes.md` OP1–OP17) — used in Lean source comments and `sorry` annotations.
- **Paper** (`audit/gap-summary.md` §7, README) — `OP1` there means "associativity", which the indexed-monad construction has resolved at the endpoint-extraction level.

The mapping is documented per-OP in `proofs/notes.md`. When adding a `sorry`, reference the *internal* number.

## Conventions

From `CONTRIBUTING.md`:

- Types `PascalCase`, functions `camelCase`, theorems `snake_case`, namespaces `PascalCase`.
- Every `sorry` must carry a comment naming what is unproved, the OP number, and the current obstacle. Do not introduce undocumented `sorry`s.

## What lives where

- `proofs/notes.md` — running record of OP1–OP17 status; check before adding a new open problem to avoid duplicating an existing entry.
- `proofs/attempt-associativity.md` — design history of the associativity refactor; consult before proposing a new approach.
- `proofs/stateless-case.md` — restricted-domain analysis.
- `TODO.md` — 5-phase roadmap.
- `audit/domain-N-*.md` — completed Phase 0 synthesis. **Read-only.**

# Systematic Review Results — HISTORICAL SNAPSHOT

> **Note**: This file documents the state after Phase 1 completion (April 2026).
> For current status, see `TODO.md` and individual source files.

## Summary (Phase 1 State)

All syntax and API issues from the initial systematic review were resolved.
The Lean 4 scaffold was established with all core types and operators defined.

## Current Status

| Phase | Status | Key Deliverables |
|-------|--------|------------------|
| Phase 0 | ✅ COMPLETE | Audit synthesis across 5 domains |
| Phase 1 | ✅ COMPLETE | Lean 4 scaffold with types, operators, laws |
| Phase 2 | ⚠ PARTIAL  | Endpoint-extraction associativity proved; path-composition associativity is open |

## Major Results

1. **Endpoint-extraction associativity proved** (`Laws.seqBind_endpoint_assoc`):
   `(F >>= G) >>= H = F >>= (G >>= H)` holds by *definitional equality* of `seqBind`,
   because the v0.1 `seqBind` extracts only `F.τ.source` and `H.τ.target` and discards
   any internal trajectory data. This is **not** the substantive paradigm-composition
   associativity; it is the weaker statement that endpoint pairing is associative.
2. **Stateless restriction** (`Stateless.assoc_stateless_endpoint`): the same theorem
   restricted to the (currently vacuous) `Trajectory.isStateless` subtype.
3. **Indexed/graded scaffolding** (`Indexed.lean`): `IndexedFuture.endpoint_assoc` plus
   left/right identity. With `TrajectoryType := Unit` at v0.1 the graded structure is
   trivial, so the indexed framing does not yet add power over the unindexed result.
4. **Weak associativity** (`WeakAssoc.lean`): affordance-level and state-level
   associativity-up-to-equivalence. These are honest as stated.

## Open: Substantive Associativity (Phase 2 refactor)

The path-composition version of associativity requires `Trajectory` to carry an
internal path (e.g. `intermediate : List ParadigmaticState`) so that `seqBind`
concatenates paths. Then associativity follows from `List.append_assoc` — a real
proof rather than `rfl`. This is the work that would let the paper claim
"trajectories compose associatively" without overstating what the artifact proves.

## This File

Preserved for historical reference. See:
- `TODO.md` for current phase status
- `proofs/notes.md` for open problem tracking
- `proofs/attempt-associativity.md` for resolution details

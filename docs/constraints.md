# Composable Future — Constraint Inventory

> PLAN_SKILLS.md §2 — "Enumerate latency budgets, cost ceilings, regulatory
> boundaries, team expertise, license compatibility, deployment targets,
> sustainability of OSS dependencies."
> Last reviewed: 2026-04-29
> Policy: review within 6 months of last entry (next: 2026-10-29)

---

## 1. Toolchain (hard constraints — one-way)

| Constraint | Value | Source |
|---|---|---|
| Lean 4 version | `leanprover/lean4:v4.30.0-rc1` | `lean/lean-toolchain` |
| Mathlib version | `v4.30.0-rc1` (rev `0c154d67`) | `lean/lake-manifest.json` |
| Lake version | `1.2.0` | `lean/lake-manifest.json` |
| Mathlib upgrade policy | Pin until a proof breaks or a needed lemma is missing; then upgrade atomically | ADR-0001 |

**Implication**: any ADR that proposes a tactic or Mathlib lemma must cite that
the lemma exists in `v4.30.0-rc1`. Proposing use of a lemma added in a later
version requires an accompanying Mathlib version bump ADR.

---

## 2. Type-theoretic constraints (intrinsic to Lean 4)

| Constraint | Impact on decisions |
|---|---|
| No univalence axiom | Cannot prove `A ≠ B : Type` for distinct types A, B without a concrete distinguishing term |
| `propext` available | Proof-irrelevant propositions; `well_formed` field equality holds automatically |
| `funext` available | Function extensionality; needed for set/predicate equality |
| No decidable equality on `Type`-valued struct fields | `ParadigmaticState.assumptions : Type` — cannot use `decide` for inequality |
| `Trajectory.endpoint_ext` is a pre-flagged one-way door | 12 call sites pre-flagged; invalidated when `Trajectory` gains a `path` field (ADR-0002) |
| `Set α = α → Prop : Type u` when `α : Type u` | `AffordanceSet S : Set ComposableFuture` is well-typed without universe issues |

---

## 3. Paper commitments (external contract — one-way)

The Zenodo preprint (doi: 10.5281/zenodo.19433811, v0.1) makes the following
claims that Lean proofs must corroborate:

| Paper claim | Current Lean status | Obligation |
|---|---|---|
| Identity: `Id >>= F = F`, `F >>= Id = F` | Proved with `well_formed` hypothesis | Unconditional proof blocked on trajectory refactor (ADR-0002) |
| Closure: `∀ A B, A >>= B ∈ F` | Proved trivially | ✅ gate satisfied |
| Associativity: holds for stateless τ | Endpoint-extraction proved; substantive version open | ADR-0002 |
| Non-commutativity: `A ⊗ B ≠ B ⊗ A` in general | Component-order witness proved; strict `≠` open | ADR-0003 |
| Kleisli category for probabilistic extension | Proved over placeholder PMF | ADR-0004 (upgrade to Mathlib PMF) |
| Φ : S₁ → P(F) as dependent type | Proved in v0.2 (derived-Φ) | ✅ gate satisfied |

The paper cannot be revised without a new Zenodo version. Therefore proofs must
match the paper's claims, not vice versa. **Weakening a theorem's hypothesis
below what the paper states requires a Zenodo v0.2 and a supersession ADR.**

---

## 4. Team constraints

| Constraint | Value |
|---|---|
| Principal researcher | Solo (I Made Agus Kresna Sucandra) |
| Lean 4 / Mathlib depth | Intermediate — can prove equational goals, use `simp`/`decide`/`rcases`; dependent-type universe manipulation requires consultation |
| Category theory background | Strong (indexed monads, Kleisli, fibered categories) |
| Time budget | Part-time academic research; no hard deadline for Phase 5 |
| Collaborator status | Not yet engaged; profile documented in TODO.md |

**Implication**: decisions that require deep Lean 4 tactic expertise (e.g., working
with `cast`, `HEq`, coinductive types) should be classified as requiring
collaborator involvement and deferred unless a Mathlib lemma handles the heavy
lifting.

---

## 5. Proof-engineering constraints

| Constraint | Value |
|---|---|
| Zero-sorry target (Phase 5 gate) | All non-open theorems must close without `sorry` |
| No new axioms | Beyond Lean 4's core (`propext`, `funext`, `Classical.choice`) — no `axiom` declarations |
| Honest framing | Weaker results (endpoint-extraction) must be named and documented as such; they cannot be presented as the substantive claim |
| Proof length budget | Individual proof blocks ≤ 50 lines; longer proofs require a helper lemma strategy |

---

## 6. OSS sustainability

| Dependency | Risk | Mitigation |
|---|---|---|
| Mathlib4 | Active, well-maintained; API churn between minor versions | Pinned rev; upgrade atomically with a full `lake build` gate |
| Lean 4 | Stable compiler track; `v4.30.0-rc1` is tested | Toolchain pinned; upgrade only if Mathlib requires it |
| Plausible (in lake-manifest) | Testing library; transitive dep of Mathlib | No direct use in this project; low risk |

---

## 7. License

Theory and audit materials: CC BY 4.0  
Code (Lean proofs): MIT  
Both are permissive — no constraint on academic publication venues.

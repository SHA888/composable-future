# Composable Future — Constraint Inventory

> PLAN_SKILLS.md §2 — "Enumerate latency budgets, cost ceilings, regulatory
> boundaries, team expertise, license compatibility, deployment targets,
> sustainability of OSS dependencies."
> Last reviewed: 2026-05-15
> Policy: review within 6 months of last entry (next: 2026-11-15)

---

## 1. Toolchain (hard constraints — one-way)

| Constraint             | Value                                                                          | Source                    |
| ---------------------- | ------------------------------------------------------------------------------ | ------------------------- |
| Lean 4 version         | `leanprover/lean4:v4.30.0-rc1`                                                 | `lean/lean-toolchain`     |
| Mathlib version        | `v4.30.0-rc1` (rev `0c154d67`)                                                 | `lean/lake-manifest.json` |
| Lake version           | `1.2.0`                                                                        | `lean/lake-manifest.json` |
| Mathlib upgrade policy | Pin until a proof breaks or a needed lemma is missing; then upgrade atomically | ADR-0001                  |

**Implication**: any ADR that proposes a tactic or Mathlib lemma must cite that
the lemma exists in `v4.30.0-rc1`. Proposing use of a lemma added in a later
version requires an accompanying Mathlib version bump ADR.

---

## 2. Type-theoretic constraints (intrinsic to Lean 4)

| Constraint                                           | Impact on decisions                                                                        |
| ---------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| No univalence axiom                                  | Cannot prove `A ≠ B : Type` for distinct types A, B without a concrete distinguishing term |
| `propext` available                                  | Proof-irrelevant propositions; `well_formed` field equality holds automatically            |
| `funext` available                                   | Function extensionality; needed for set/predicate equality                                 |
| No decidable equality on `Type`-valued struct fields | `ParadigmaticState.assumptions : Type` — cannot use `decide` for inequality                |
| `Set α = α → Prop : Type u` when `α : Type u`        | `Φ : Set ComposableFuture` is well-typed without universe issues (ADR-0005)                |
| `ComposableFuture` with `Φ : Set ComposableFuture`   | No strict positive occurrence — Lean 4 accepts this; `Set` is a function type              |
| `Trajectory.endpoint_ext` deleted (ADR-0002)         | 12 call sites pre-flagged; invalidated when `path` field added                             |

---

## 3. Paper commitments (external contract — one-way)

The Zenodo preprint (doi: 10.5281/zenodo.19433811, v0.1) makes the following
claims that Lean proofs must corroborate. v0.2 will update several of these.

| Paper claim                                  | Current Lean status                           | Action                                                         |
| -------------------------------------------- | --------------------------------------------- | -------------------------------------------------------------- |
| **4-tuple F = (S₀, τ, S₁, Φ)**               | 3-tuple in v0.2; Φ derived                    | ADR-0005 — restore stored Φ field                              |
| Identity: `Id >>= F = F`, `F >>= Id = F`     | Proved with `well_formed` hypothesis          | Unconditional proof blocked on ADR-0005                        |
| **Remark 4.1: result carries Φ∅**            | Directly contradicted (Φ always non-empty)    | v0.2 revision: null future preserves Φ; terminate is Paper 2   |
| **Def 2.3: `Φ∅(S) = ∅`**                     | `AffordanceSet S` always non-empty            | v0.2 revision: `idFuture` carries `AffordanceSet S` (Option B) |
| Closure: `∀ A B, A >>= B ∈ F`                | Proved trivially                              | ✅ gate satisfied                                              |
| Associativity: holds for stateless τ         | Five substantive theorems, 0 sorry            | ✅ resolved — update paper OP1 status                          |
| Non-commutativity: `A ⊗ B ≠ B ⊗ A`           | Conditional + structural witness + iso proved | ADR-0003 Path 3 (accept conditional)                           |
| Kleisli category for probabilistic extension | Proved over Mathlib PMF                       | ✅ gate satisfied                                              |
| Φ : S₁ → P(F) as dependent type              | v0.2 derived; ADR-0005 restores stored field  | ✅ after ADR-0005                                              |
| OP1 open and unresolved                      | Five Lean proofs, 0 sorry                     | v0.2 must update OP1 status                                    |

The paper cannot be revised without a new Zenodo version. Lean proofs must
match paper claims, not vice versa. **Weakening a theorem's hypothesis
below what the paper states requires a Zenodo v0.2 and a supersession ADR.**

---

## 4. Publication constraints (added 2026-05-15)

| Constraint               | Value                             | Rationale                                                                         |
| ------------------------ | --------------------------------- | --------------------------------------------------------------------------------- |
| arXiv                    | Not available — no endorser found | arXiv requires math.CT or cs.LO endorsement; endorsement requests declined        |
| Primary publication path | Zenodo preprint → ACT 2027 → LMCS | Zenodo is the primary citable record; no arXiv dependency                         |
| Paper 2 venue            | TAC or JPAA                       | Lawvere enrichment + Coecke–Fritz–Spekkens is TAC territory                       |
| Paper 3 venue            | PLOS ONE or systems journal       | Applied, interdisciplinary; operational falsifiability is the primary deliverable |
| Open access              | Required for all three papers     | Track 2 moat requires public citability                                           |
| Track 2 exposure         | None — private                    | Biokhor, LMIC, clinical specifics never appear in public outputs                  |

---

## 5. Theory design decisions (locked — one-way)

| Decision                   | Value                                                              | ADR          | Date           |
| -------------------------- | ------------------------------------------------------------------ | ------------ | -------------- |
| Trajectory carries path    | `path : List ParadigmaticState`                                    | ADR-0002     | 2026-05-13     |
| Associativity mechanism    | `List.append_assoc` (substantive)                                  | ADR-0002     | 2026-05-13     |
| PMF implementation         | Mathlib `PMF` (genuine distributions)                              | ADR-0004     | 2026-05-07     |
| Non-commutativity strategy | Conditional result + structural witness + OP3 iso                  | ADR-0003     | 2026-05-08     |
| **Φ storage**              | **Stored field `Φ : Set ComposableFuture`**                        | **ADR-0005** | **2026-05-15** |
| **idFuture Φ**             | **`AffordanceSet S` (Option B — null preserves affordances)**      | **ADR-0005** | **2026-05-15** |
| **Terminate operator**     | **Deferred to Paper 2 (unary; resource signature under CFS 2016)** | **ADR-0005** | **2026-05-15** |
| **Merge scope**            | **Symmetric case only in Paper 1; absorptive merge is Paper 2**    | **ADR-0005** | **2026-05-15** |

---

## 6. Team constraints

| Constraint                 | Value                                                                                                                               |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| Principal researcher       | Solo (I Made Agus Kresna Sucandra)                                                                                                  |
| Lean 4 / Mathlib depth     | Intermediate — can prove equational goals, use `simp`/`decide`/`rcases`; dependent-type universe manipulation requires consultation |
| Category theory background | Strong (indexed monads, Kleisli, fibered categories, Lawvere enrichment)                                                            |
| Paper 2 expertise gap      | Coecke–Fritz–Spekkens resource theory — requires study before Paper 2 scoping                                                       |
| Time budget                | Part-time academic research; no hard deadline for Phase 5/6                                                                         |
| Collaborator status        | Not yet engaged; profile documented in TODO.md; seek after Paper 1 ACT submission                                                   |

---

## 7. Proof-engineering constraints

| Constraint                       | Value                                                                              |
| -------------------------------- | ---------------------------------------------------------------------------------- |
| Zero-sorry target (Phase 5 gate) | All non-open theorems must close without `sorry`                                   |
| No new axioms                    | Beyond Lean 4's core (`propext`, `funext`, `Classical.choice`)                     |
| Honest framing                   | Weaker results must be named as such; cannot be presented as the substantive claim |
| Proof length budget              | Individual proof blocks ≤ 50 lines; longer proofs require a helper lemma strategy  |
| ADR-0003 Path 3                  | Accept conditional non-commutativity; do not add `axiom Prod.type_inj`             |

---

## 8. OSS sustainability

| Dependency             | Risk                                                      | Mitigation                                                 |
| ---------------------- | --------------------------------------------------------- | ---------------------------------------------------------- |
| Mathlib4               | Active, well-maintained; API churn between minor versions | Pinned rev; upgrade atomically with full `lake build` gate |
| Lean 4                 | Stable compiler track; `v4.30.0-rc1` is tested            | Toolchain pinned; upgrade only if Mathlib requires it      |
| Plausible (transitive) | Testing library; low direct use                           | No direct use in this project; low risk                    |

---

## 9. License

Theory and audit materials: CC BY 4.0
Code (Lean proofs): MIT
Both are permissive — no constraint on academic publication venues.

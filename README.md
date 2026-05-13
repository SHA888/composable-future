# Composable Future

A formal theory of paradigmatic futures as composable algebraic structures.

**Status:** Phase 5 in progress — 0 `sorry`, 0 warnings; ADR-0004 ✅ ADR-0003 🟡 ADR-0002 ✅  
**Track:** Theory (public) + Applied formalization (private)  
**Latest:** Level 1 positioning paper (8 pages) ready for arXiv submission

---

## Preprint

> **Composable Future: Toward an Algebraic Theory of Paradigmatic Transitions**  
> I Made Agus Kresna Sucandra — Fakultas Kedokteran, Universitas Udayana  
> Version 0.1 — April 6, 2026
>
> 📄 [doi.org/10.5281/zenodo.19433811](https://doi.org/10.5281/zenodo.19433811)
>
> _Comments welcome._

---

## The Claim

_Composable Future_ is a coined term for a structure not currently named in the literature.

The central claim: **paradigmatic futures have the algebraic properties of composable types.** They can be combined without either being destroyed, sequenced without loss of identity, and the result of composition is itself a valid future that can be further composed.

This is distinct from:

- _Convergence_ — which implies two things merging into one fixed outcome
- _Futures studies_ — which models scenarios qualitatively, not algebraically
- `Future<T>` in async programming — which operates on computations, not paradigms

---

## Core Definition

A Future `F` is a 3-tuple (v0.2):

```
F = (S₀, τ, S₁)
```

| Symbol | Meaning                                                                        |
| ------ | ------------------------------------------------------------------------------ |
| `S₀`   | Current paradigmatic state — existing assumptions, constraints, infrastructure |
| `τ`    | Trajectory — the mechanism of change                                           |
| `S₁`   | Reachable paradigmatic state                                                   |

`Φ` is **derived**, not stored: `F.Φ = AffordanceSet F.S₁ = { G | G.S₀ = F.S₁ }` — the set of all futures reachable from `S₁`. This matches the paper’s definition Φ : S₁ → 𝒫(F) and eliminates the universe mismatch present in v0.1.

---

## Operators

Four primitive operations over futures:

```
A >>= B    sequential    A's S₁ becomes B's S₀
A ⊗ B      parallel      both proceed; outputs combined
A | B      fork          branch point — one path realized
A ⊕ B      merge         two independent futures reconverge
```

---

## Laws Under Investigation

**Identity**

```
F >>= Id = F
Id >>= F = F
```

Where `Id` is the null future — a transition that changes nothing.

**Associativity**

```
(A >>= B) >>= C  =  A >>= (B >>= C)
```

*Status: **Proved — five independent theorems, all substantive.***

- **`Laws.seqBind_assoc`**: unconditional for all `ComposableFuture` via `List.append_assoc`
- **`Effect.EffectfulFuture.seq_assoc`**: value-less indexed futures
- **`Effect.EffectfulComputation.bind_assoc`**: indexed monad with values
- **`Indexed.IndexedFuture.assoc`**: graded monad (indexed by `TrajectoryType`)
- **`Stateless.assoc_stateless`**: stateless subtype (specialization)

`Trajectory` carries `path : List ParadigmaticState`; `seqBind` concatenates paths;
associativity follows from `List.append_assoc`. No `sorry`. (ADR-0002, 2026-05-13)

**Commutativity of parallel**

```
A ⊗ B ≠ B ⊗ A   (in general)
```

_Status: **Structurally witnessed; strict ≠ conditional.**_

- **Structural witness** (`Laws.parTensor_component_order`): proved — the component order is opposite in `A ⊗ B` vs `B ⊗ A`.
- **Key reduction** (`Laws.parTensor_comm_implies_prod_comm`): proved — if `parTensor` were commutative then all type products would commute.
- **Conditional existential** (`Laws.parTensor_not_comm_of_type_ne`): proved — given `(A×B) ≠ (B×A)`, specific non-commuting futures exist.
- **Unconditional** `∃ F G, parTensor F G ≠ parTensor G F`: **open** — requires `Prod.type_inj` (type-constructor injectivity), which is sound but not an explicit Lean 4 axiom. See `docs/adr/0003-noncommutativity-strategy.md`.

**Closure**

```
∀ A, B ∈ F :  A >>= B ∈ F
```

Any composition of valid futures is itself a valid future.

---

## Structural Targets

| Structure        | Condition                          | Status                  |
| ---------------- | ---------------------------------- | ----------------------- |
| Category         | Identity + associativity + closure | Plausible               |
| Monoid           | Category + single object           | Under investigation     |
| Monad            | Monoid + `return` + associativity  | Requires Phase 2        |
| Fibered category | Path-dependent `τ`                 | If associativity breaks |

---

## Relationship to Existing Formalisms

| Formalism                      | Role in this theory                                    |
| ------------------------------ | ------------------------------------------------------ | ------ |
| Category theory                | Backbone — objects, morphisms, composition             |
| Process algebra (CSP/CCS)      | Formal semantics for `⊗`, `                            | `, `⊕` |
| Modal / temporal logic (CTL\*) | Grounding `S₁` as a distribution over reachable states |
| Coalgebra                      | State-transition structure per future                  |
| Affordance theory              | Formal definition of `Φ`                               |
| Dependent type theory          | `Φ` as a dependent type over `S₁`                      |

---

## Formalization Roadmap

```
Phase 0   Define F precisely — prove identity law
Phase 1   Prove closure under >>= and ⊗
Phase 2   Settle associativity
          ├── holds     → Category, pursue monad
          └── breaks    → Fibered category / indexed morphisms
Phase 3   Probabilistic extension — Kleisli / Markov kernels
Phase 4   Formalize Φ as dependent type / effect system
Phase 5   Mechanized proof — Lean 4 or Agda
```

---

## Publication Track

```
Foundational audit (this repo)
       ↓
Zenodo preprint                     ← doi.org/10.5281/zenodo.19433811 (v0.1, April 6)
       ↓
Positioning paper (Level 1)         ← ✅ COMPLETE (paper/composable-future-level1.tex)
- Propose F = (S₀, τ, S₁, Φ)
- Map to existing formalisms
- State open problems explicitly
- 8 pages, 16 priors, PDF compiled
       ↓
arXiv submission (math.CT / cs.LO)  ← pending endorsement
       ↓
Peer-reviewed submission
       ↓
Full formalization paper (Phase 2–5 complete)
```

---

## Foundational Audit

Before the positioning paper, a structured audit of the five adjacent literatures:

| Domain                                        | Source                      |
| --------------------------------------------- | --------------------------- |
| 1. Category theory applied to complex systems | arXiv math.CT, cs.LO        |
| 2. Formal models of paradigm change           | PhilPapers, Google Scholar  |
| 3. Process algebra and concurrent systems     | ACM DL, arXiv cs.LO         |
| 4. Affordance theory — formal treatments      | Google Scholar, PsycINFO    |
| 5. Futures studies formalization              | Google Scholar, arXiv cs.AI |

Each domain file produces:

- A list of relevant papers with relevance notes
- A one-paragraph synthesis of what exists
- A one-sentence gap statement
- A confidence level: gap confirmed / partial / unclear

The `gap-summary.md` aggregates all five into the composite gap statement that opens the positioning paper.

### Running the Audit Search

First install dependencies: `uv sync` (or `pip install -e .`)

```bash
uv run search.py all     # search all 5 domains
uv run search.py 3       # single domain
```

### Refinement Passes

```bash
uv run refinement.py list          # show defined refinements per domain
uv run refinement.py 4 --seeds    # add manual seeds only
uv run refinement.py 4 --queries  # run refined queries only
uv run refinement.py 4            # both
```

Results are written to `audit/domain-N-*.md`. Synthesis sections are filled manually after reading.

---

## Repo Structure

```
composable-future/
├── README.md
├── TODO.md              # 5-phase development roadmap
├── CONTRIBUTING.md      # How to contribute (audit scripts, Lean proofs)
├── search.py            # initial audit search — run first
├── refinement.py        # merge refined queries + manual seeds
├── audit/
│   ├── domain-1-category-theory.md
│   ├── domain-2-paradigm-change.md
│   ├── domain-3-process-algebra.md
│   ├── domain-4-affordance-theory.md
│   ├── domain-5-futures-formalization.md
│   └── gap-summary.md
├── docs/
│   ├── constraints.md       # Project constraint inventory
│   └── adr/
│       ├── 0001-record-proof-decisions.md
│       ├── 0002-trajectory-enrichment.md    # Accepted (2026-05-13)
│       ├── 0003-noncommutativity-strategy.md  # Accepted — Revised (2026-05-08)
│       └── 0004-pmf-mathlib-upgrade.md       # Accepted (2026-05-07)
├── lean/                # Lean 4 formalization (Phases 1–4 complete)
│   ├── lakefile.lean        # Lean 4 project configuration
│   ├── ComposableFuture.lean
│   └── Core/
│       ├── Future.lean          # Types + AffordanceSet (v0.2: Φ derived)
│       ├── Operators.lean       # >>=, ⊗, |, ⊕ operators
│       ├── Laws.lean            # Identity, closure, associativity, non-commutativity
│       ├── Stateless.lean       # Stateless-case associativity (Phase 2)
│       ├── Indexed.lean         # Indexed/graded monad (Phase 2)
│       ├── WeakAssoc.lean       # Weak associativity theorems (Phase 2)
│       ├── Probabilistic.lean   # Kleisli/Markov kernels over Mathlib PMF (Phase 3)
│       ├── Affordance.lean      # AffordanceDescriptor witnesses + OP2/OP4 (Phase 4)
│       └── Effect.lean          # Indexed monad + effect system (Phase 4)
├── paper/               # Publication materials
│   ├── composable-future-level1.tex    # 8-page positioning paper
│   ├── composable-future-level1.pdf    # Compiled PDF (236 KB)
│   └── references.bib                  # 16 confirmed priors
└── proofs/              # Informal proof attempts and notes
    ├── notes.md             # Running proof notes (P3.2 Furter mapping; OP1/OP2 resolutions)
    ├── stateless-case.md    # Restricted domain analysis
    └── attempt-associativity.md  # Failed attempts and insights
```

---

## How to Contribute

### Audit Contributions

- **⚠️ Phase 0 audit synthesis is COMPLETE** - do not run audit scripts
- Read and extend existing synthesis in `audit/domain-N-*.md` files
- Add new domains or literature updates in separate directories
- See `CONTRIBUTING.md` for detailed guidelines on preserving completed work

### Lean Formalization

Install elan (Lean toolchain manager):

| Platform      | Command                                                                                 |
| ------------- | --------------------------------------------------------------------------------------- |
| Linux / macOS | `curl -sSf https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh \| sh` |
| Windows       | Download installer from https://github.com/leanprover/elan/releases                     |

After install, restart your terminal (or `source ~/.bashrc` on Linux) so `lake` is in PATH.

- Build project: `cd lean && lake build` — should report **0 errors, 0 warnings, 0 sorry**
- The codebase is sorry-free; all Phase 1–4 theorems are proved
- ADR-0002 (trajectory enrichment) is complete; next open work: OP3 equivalence relation design
- Add proof attempts and notes to `proofs/notes.md`
- Follow naming conventions in `CONTRIBUTING.md`

### Proof Attempts

- Document dead ends in `proofs/attempt-associativity.md`
- Explore restricted cases in `proofs/stateless-case.md`
- Test conjectures and provide counterexamples

---

## Current State

| Domain | Papers | Refinement run | Synthesis filled |
| ------ | ------ | -------------- | ---------------- |
| 1      | 26     | ✓              | ✅ Complete      |
| 2      | 37     | ✓              | ✅ Complete      |
| 3      | 32     | ✓              | ✅ Complete      |
| 4      | 28     | ✓ seeds        | ✅ Complete      |
| 5      | 43     | ✓              | ✅ Complete      |

**Phase 0 audit synthesis COMPLETE** — all 5 domains analyzed, gaps confirmed, open problems mapped.

---

## What's Next

**Phases 0–4 are complete.** Phase 5 is in progress. The build is at 0 `sorry`, 0 warnings.

### Phase 5 progress

| ADR      | Task                                                              | Status                             |
| -------- | ----------------------------------------------------------------- | ---------------------------------- |
| ADR-0004 | Upgrade placeholder `PMF` to Mathlib’s real `PMF`                 | ✅ done (2026-05-07)               |
| ADR-0003 | Non-commutativity of ⊗                                            | 🟡 conditional result (2026-05-08) |
| ADR-0002 | Add `path` field to `Trajectory`; prove substantive associativity | ✅ done (2026-05-13)               |

### Immediate Next Steps

1. **arXiv submission** — Find math.CT or cs.LO endorser (submission ID 7444737, endorsement code NBFD6A)
2. **ADR-0003 gap** — Close the unconditional `∃ F G, parTensor F G ≠ parTensor G F`
   - Three forward paths documented in `docs/adr/0003-noncommutativity-strategy.md`
   - Candidate approach: `FutureIso` (SMC isomorphism) to prove commutativity-up-to-iso instead
3. **OP3** — Commit to an equivalence relation design (bisimulation vs. SMC isomorphism) and implement

---

## Open Problems

**OP1: Associativity under path-dependence** ✅ **RESOLVED** (ADR-0002, 2026-05-13)

- `Laws.seqBind_assoc`: unconditional, all `ComposableFuture`, via `List.append_assoc`
- `Effect.EffectfulFuture.seq_assoc` / `EffectfulComputation.bind_assoc`: indexed monad variants
- `Indexed.IndexedFuture.assoc`: graded monad variant
- `Stateless.assoc_stateless`: stateless subtype variant

**OP2: Is Φ well-defined before S₁ is realized?** ✅ **RESOLVED** (v0.2)

- `AffordanceSet S := setOf fun F => F.S₀ = S` is defined for every S by set comprehension
- `affordanceSet_nonempty`: always non-empty (contains `idFuture S`)
- `affordanceSet_contains_id`: identity future is always in the affordance set

**OP4: Does composition of affordance sets Φ ∘ Φ' hold?** ✅ **RESOLVED** (v0.2)

- `seqBind_Φ_eq`: `(F >>= G).Φ = G.Φ` (proved by `rfl`)
- `seqBind_mem_affordanceSet`: sequential composition is closed in `AffordanceSet F.S₀`
- `composeSequential_mem` / `composeParallel_mem`: descriptor-based witnesses

**Remaining open problems:**

3. **Non-commutativity (strict)** — unconditional `∃ F G, parTensor F G ≠ parTensor G F` requires `Prod.type_inj`. Conditional result proved; three forward paths in ADR-0003.
4. **Equivalence relation** — what is the correct equivalence between futures — bisimulation, SMC isomorphism? (Phase 5)
5. **Completeness** — are all paradigmatic futures reachable by finite composition? (Phase 5)

See `audit/gap-summary.md` for detailed problem statements and `proofs/notes.md` for internal open problems (OP8–OP17).

---

## Citation

```bibtex
@misc{sucandra2026composable,
  author    = {Sucandra, I Made Agus Kresna},
  title     = {Composable Future: Toward an Algebraic Theory
               of Paradigmatic Transitions},
  year      = {2026},
  month     = {April},
  version   = {0.1},
  doi       = {10.5281/zenodo.19433811},
  url       = {https://doi.org/10.5281/zenodo.19433811},
  note      = {Preprint. Zenodo.}
}
```

---

## License

Theory and audit materials: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/)  
Code: MIT

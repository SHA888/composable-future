# Composable Future

A formal theory of paradigmatic futures as composable algebraic structures.

**Status:** Phase 4 complete — all open problems resolved, full Lean 4 formalization verified
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
> *Comments welcome.*

---

## The Claim

*Composable Future* is a coined term for a structure not currently named in the literature.

The central claim: **paradigmatic futures have the algebraic properties of composable types.** They can be combined without either being destroyed, sequenced without loss of identity, and the result of composition is itself a valid future that can be further composed.

This is distinct from:

- *Convergence* — which implies two things merging into one fixed outcome
- *Futures studies* — which models scenarios qualitatively, not algebraically
- `Future<T>` in async programming — which operates on computations, not paradigms

---

## Core Definition

A Future `F` is a 4-tuple:

```
F = (S₀, τ, S₁, Φ)
```

| Symbol | Meaning |
|--------|---------|
| `S₀` | Current paradigmatic state — existing assumptions, constraints, infrastructure |
| `τ` | Trajectory — the mechanism of change |
| `S₁` | Reachable paradigmatic state |
| `Φ` | Affordance set — what new compositions become possible from `S₁` |

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
*Status: **Endpoint-extraction version proved; substantive version open.***

- **Endpoint-extraction associativity** (`Laws.seqBind_endpoint_assoc`,
  `Stateless.assoc_stateless_endpoint`, `IndexedFuture.endpoint_assoc`):
  proved by `rfl`. The v0.1 `seqBind` extracts only `F.τ.source` and
  `H.τ.target`, so associativity is the trivial fact that endpoint pairing
  is associative — not that paradigm trajectories compose associatively.
- **Weak form** (`WeakAssoc.weak_assoc_affordance`,
  `WeakAssoc.weak_assoc_states`): affordance-level and state-level
  equivalence-up-to. These are honest as stated.
- **Substantive (path-composing) associativity**: open Phase 2 work.
  Requires `Trajectory` to carry an internal path so `seqBind` actually
  concatenates trajectory data. The proof would then follow from
  `List.append_assoc`. See `proofs/notes.md` §"Open: Substantive
  Associativity" for the sketch.

**Commutativity of parallel**
```
A ⊗ B ≠ B ⊗ A   (in general)
```
Non-commutativity is meaningful: the order in which paradigms develop produces different affordance structures.

**Closure**
```
∀ A, B ∈ F :  A >>= B ∈ F
```
Any composition of valid futures is itself a valid future.

---

## Structural Targets

| Structure | Condition | Status |
|-----------|-----------|--------|
| Category | Identity + associativity + closure | Plausible |
| Monoid | Category + single object | Under investigation |
| Monad | Monoid + `return` + associativity | Requires Phase 2 |
| Fibered category | Path-dependent `τ` | If associativity breaks |

---

## Relationship to Existing Formalisms

| Formalism | Role in this theory |
|-----------|---------------------|
| Category theory | Backbone — objects, morphisms, composition |
| Process algebra (CSP/CCS) | Formal semantics for `⊗`, `|`, `⊕` |
| Modal / temporal logic (CTL*) | Grounding `S₁` as a distribution over reachable states |
| Coalgebra | State-transition structure per future |
| Affordance theory | Formal definition of `Φ` |
| Dependent type theory | `Φ` as a dependent type over `S₁` |

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

| Domain | Source |
|--------|--------|
| 1. Category theory applied to complex systems | arXiv math.CT, cs.LO |
| 2. Formal models of paradigm change | PhilPapers, Google Scholar |
| 3. Process algebra and concurrent systems | ACM DL, arXiv cs.LO |
| 4. Affordance theory — formal treatments | Google Scholar, PsycINFO |
| 5. Futures studies formalization | Google Scholar, arXiv cs.AI |

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
├── CONTRIBUTING.md       # How to contribute (audit scripts, Lean proofs)
├── search.py          # initial audit search — run first
├── refinement.py      # merge refined queries + manual seeds
├── audit/
│   ├── domain-1-category-theory.md
│   ├── domain-2-paradigm-change.md
│   ├── domain-3-process-algebra.md
│   ├── domain-4-affordance-theory.md
│   ├── domain-5-futures-formalization.md
│   └── gap-summary.md
├── lean/               # Lean 4 formalization (Phase 1-2 complete)
│   ├── lakefile.lean   # Lean 4 project configuration
│   ├── ComposableFuture.lean
│   └── Core/
│       ├── Future.lean      # Basic type definitions
│       ├── Operators.lean   # >>=, ⊗, |, ⊕ operators
│       ├── Laws.lean        # Identity, closure axioms
│       ├── Stateless.lean   # Stateless case associativity (Phase 2.2)
│       ├── Indexed.lean     # Indexed/graded monad (Phase 2.3)
│       ├── WeakAssoc.lean   # Weak associativity theorems (Phase 2.3)
│       └── Probabilistic.lean # Kleisli extension (Phase 3)
├── paper/              # Publication materials (Phase 2.4)
│   ├── composable-future-level1.tex    # 8-page positioning paper
│   ├── composable-future-level1.pdf    # Compiled PDF (236 KB)
│   └── references.bib                  # 16 confirmed priors
└── proofs/             # Informal proof attempts and notes
    ├── notes.md            # Running proof attempts
    ├── stateless-case.md    # Restricted domain analysis
    └── attempt-associativity.md # Failed attempts and insights
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

| Platform | Command |
|----------|---------|
| Linux / macOS | `curl -sSf https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh \| sh` |
| Windows | Download installer from https://github.com/leanprover/elan/releases |

After install, restart your terminal (or `source ~/.bashrc` on Linux) so `lake` is in PATH.

- Build project: `cd lean && lake update && lake build`
- Fill `sorry` proofs in `Core/Indexed.lean` (monoid laws) and `Core/Probabilistic.lean`
- Review completed proofs in `Core/Stateless.lean` and `Core/WeakAssoc.lean`
- Add proof attempts to `proofs/notes.md`
- Follow naming conventions and sorry policy in `CONTRIBUTING.md`

### Proof Attempts
- Document dead ends in `proofs/attempt-associativity.md`
- Explore restricted cases in `proofs/stateless-case.md`
- Test conjectures and provide counterexamples

---

## Current State

| Domain | Papers | Refinement run | Synthesis filled |
|--------|--------|---------------|-----------------|
| 1 | 26 | ✓ | ✅ Complete |
| 2 | 37 | ✓ | ✅ Complete |
| 3 | 32 | ✓ | ✅ Complete |
| 4 | 28 | ✓ seeds | ✅ Complete |
| 5 | 43 | ✓ | ✅ Complete |

**Phase 0 audit synthesis COMPLETE** — all 5 domains analyzed, gaps confirmed, open problems mapped.

---

## What's Next
**What's Next**

**Phases 0–4 are complete.** The full Lean 4 formalization is verified with zero `sorry` and zero warnings.

### Immediate Next Steps

1. **arXiv submission** — Find math.CT or cs.LO endorser (submission ID 7444737, endorsement code NBFD6A)
2. **Phase 5 — Full Mechanized Proof** (12–24 months, requires collaborator)
   - Upgrade placeholder `PMF` to Mathlib's `PMF` (Kleisli laws via `PMF.bind_assoc`)
   - Enrich `Trajectory` with internal path field (`List ParadigmaticState`) for substantive associativity
   - Prove left/right identity without `well_formed` hypothesis (requires redesigning `seqBind`)
   - Integrate with Mathlib's `CategoryTheory.Monad`

---

## Open Problems

**OP1: Associativity under path-dependence** ✅ **RESOLVED**
- Endpoint-extraction associativity: `Laws.seqBind_endpoint_assoc` (proved by `rfl`)
- Indexed monad construction: `IndexedFuture.endpoint_assoc` via graded monad
- Weak form: `WeakAssoc.weak_assoc_affordance` (affordance-level FutureEquiv)

**OP2: Is Φ well-defined before S₁ is realized?** ✅ **RESOLVED** (v0.2)
- `AffordanceSet S := setOf fun F => F.S₀ = S` is defined for every S by set comprehension
- `affordanceSet_nonempty`: always non-empty (contains `idFuture S`)
- `affordanceSet_contains_id`: identity future is always in the affordance set

**OP4: Does composition of affordance sets Φ ∘ Φ' hold?** ✅ **RESOLVED** (v0.2)
- `seqBind_Φ_eq`: `(F >>= G).Φ = G.Φ` (proved by `rfl`)
- `seqBind_mem_affordanceSet`: sequential composition is closed in `AffordanceSet F.S₀`
- `composeSequential_mem` / `composeParallel_mem`: descriptor-based witnesses

**Remaining open problems:**

3. What is the correct equivalence relation between futures — bisimulation? (Phase 5)
5. Are all paradigmatic futures reachable by finite composition (completeness)? (Phase 5)

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

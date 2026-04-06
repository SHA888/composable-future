# Composable Future

A formal theory of paradigmatic futures as composable algebraic structures.

**Status:** Foundational audit in progress — pre-publication  
**Track:** Theory (public) + Applied formalization (private)

---

## Preprint

> **Composable Future: Toward an Algebraic Theory of Paradigmatic Transitions**  
> I Made Agus Kresna Sucandra — Fakultas Kedokteran, Universitas Udayana  
> Version 0.1 — April 5, 2026  
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
*Status: open.* Likely breaks under path-dependent `τ` — the critical question of the theory.

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
Positioning paper
- Propose F = (S₀, τ, S₁, Φ)
- Map to existing formalisms
- State open problems explicitly
- 8–12 pages
       ↓
Zenodo preprint                     ← doi.org/10.5281/zenodo.19433811
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
├── search.py          # initial audit search — run first
├── refinement.py      # merge refined queries + manual seeds
└── audit/
    ├── domain-1-category-theory.md
    ├── domain-2-paradigm-change.md
    ├── domain-3-process-algebra.md
    ├── domain-4-affordance-theory.md
    ├── domain-5-futures-formalization.md
    └── gap-summary.md
```

---

## Current State

| Domain | Papers | Refinement run | Synthesis filled |
|--------|--------|---------------|-----------------|
| 1 | 26 | — | — |
| 2 | 37 | — | — |
| 3 | 32 | — | — |
| 4 | 28 | ✓ seeds | — |
| 5 | 43 | — | — |

---

## What's Next

The tooling is complete. The work is now manual — reading in priority order and filling synthesis sections.

Start with these seven in sequence, everything else waits:
```
1. D5 #35  Credible Futures (Iacona & Iaquinto, 2021)
2. D1 #2   Composable Uncertainty in SMCs (Furter et al., 2025)
3. D2 #30  Formalized Conceptual Spaces (Bechberger & Kühnberger, 2018)
4. D3 #24  Span(Graph) process algebra (Katis et al., 2009)
5. D2 #13  Are Programming Paradigms Paradigms? (Kiasari, 2025)
6. D1 #25  Semantic marriage of monads and effects (Orchard et al., 2014)
7. D4 #25  Chemero (2003) — manual seed, no network needed
```

---

## Open Problems

1. Does associativity hold for `>>=` when `τ` is path-dependent?
2. Is `Φ` well-defined before `S₁` is realized?
3. What is the correct equivalence relation between futures — bisimulation?
4. Does composition of affordance sets `Φ ∘ Φ'` hold?
5. Are all paradigmatic futures reachable by finite composition (completeness)?

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

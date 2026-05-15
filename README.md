# Composable Future

A formal theory of paradigmatic futures as composable algebraic structures.

**Status:** Phase 5 — ADR-0005 ✅ (state-anchored 4-tuple, Option B); 0 errors, 1 documented Phase-4 `sorry` (`parTensor_comm_iso.phi`), no others; ADR-0004 ✅ ADR-0003 🟡 ADR-0002 ✅ OP3 ✅
**Track:** Theory (public) + Applied formalization (private)
**Latest:** Level 1 positioning paper (8 pages) — Zenodo v0.1 live; v0.2 in preparation

---

## Preprint

> **Composable Future: Toward an Algebraic Theory of Paradigmatic Transitions**
> I Made Agus Kresna Sucandra — Fakultas Kedokteran, Universitas Udayana
> Version 0.1 — April 6, 2026
>
> 📄 [doi.org/10.5281/zenodo.19433811](https://doi.org/10.5281/zenodo.19433811)
>
> _Comments welcome. v0.2 in preparation — addresses eight identified divergences between preprint and Lean formalization._

---

## The Claim

_Composable Future_ is a coined term for a structure not currently named in the literature.

The central claim: **paradigmatic futures have the algebraic properties of composable types.** They can be combined without either being destroyed, sequenced without loss of identity, and the result of composition is itself a valid future that can be further composed.

A falsifiable test distinguishing genuine paradigm shifts from rebranded compositions: if a claimed "new paradigm" can be expressed as a finite term in the pre-existing operator set without loss, it is a composition. If expression requires a new operator that did not previously exist, it is an extension. Real shifts: backprop (1986), attention mechanism (2017), score-matching (2020). Rebranded compositions: most "new paradigms" including current "Agentic AI" (LLM + tool-calling + retrieval + control flow).

This is distinct from:

- _Convergence_ — which implies two things merging into one fixed outcome
- _Futures studies_ — which models scenarios qualitatively, not algebraically
- `Future<T>` in async programming — which operates on computations, not paradigms

---

## Core Definition

A Future `F` is a 4-tuple:

```
F = (S₀, τ, S₁, Φ)
```

| Symbol | Meaning                                                                                     |
| ------ | ------------------------------------------------------------------------------------------- |
| `S₀`   | Current paradigmatic state — existing assumptions, constraints, infrastructure              |
| `τ`    | Trajectory — mechanism of change; carries `path : List ParadigmaticState` (ADR-0002)        |
| `S₁`   | Reachable paradigmatic state                                                                |
| `Φ`    | Affordance set — futures compositionally accessible from `S₁` (stored field, ADR-0005)      |

**ADR-0005 (Done, 2026-05-15 — state-anchored):** `Φ` is a stored field. The
literal `Set ComposableFuture` was kernel-rejected (strict positivity:
`Set T = T → Prop` is a negative occurrence), so `Φ : Set ParadigmaticState`
stores the affordance *anchor states*; the paper's `𝒫(F)` is recovered by the
projection `afforded F := {G | G.S₀ ∈ F.Φ}`, proved content-equivalent to
`AffordanceSet F.S₁` for well-formed futures (`afforded_eq_affordanceSet`).
Option B preserved: `idFuture S` carries `Φ = {S}`, so
`afforded (idFuture S) = AffordanceSet S` — the null future preserves all
affordances accessible from S because a transition that changes nothing changes
nothing about what is accessible. The terminate operator (Paper 2, unary) is
what genuinely zeros affordances, distinguished from identity by its resource
signature under Coecke–Fritz–Spekkens enrichment.

**v0.2 derived-Φ (superseded):** The interim 3-tuple derivation resolved a universe mismatch but
created a paper/Lean theory split. ADR-0005's state-anchored 4-tuple closes that split.
See `docs/adr/0005-restore-4tuple.md`.

---

## Operators

Four primitive operations over futures (Paper 1 scope):

```
A >>= B    sequential    A's S₁ becomes B's S₀; result carries Φ^B
A ⊗ B      parallel      both proceed; result carries Φ^A × Φ^B
A | B      fork          branch point — one path realized; result carries Φ^A ⊔ Φ^B
A ⊕ B      merge         two independent futures reconverge (symmetric case only)
```

**Scope note:** A fifth unary operator — terminate/prune — exists in the informal algebra but is
deferred to Paper 2, where it becomes substantive under resource enrichment (Landauer erasure,
irreversibility). Paper 1's merge covers the symmetric case only; absorptive merge (asymmetric
resource transfer + source termination) is a Paper 2 question.

---

## Laws Under Investigation

**Identity**

```
F >>= Id = F    and    Id >>= F = F
```

Where `Id_S` is the null future at S — a transition that changes nothing and preserves all
affordances accessible from S. Identity holds for well-formed futures (`F.τ.source = F.S₀`,
`F.τ.target = F.S₁`, `F.Φ = {F.S₁}` — equivalently `afforded F = AffordanceSet F.S₁`).
`right_identity` is substantive in the Φ conjunct (`#print` confirms it uses
`hF.2.2`, not `rfl`/`Subsingleton`; depends only on `propext`).

**Remark (revision of preprint Remark 4.1):** The affordance set of `F >>= Id_S₁` equals `F.Φ`,
not ∅. The null future preserves affordances; it does not eliminate them. Termination —
the operation that genuinely zeros affordances — is the terminate operator of Paper 2.

**Associativity**

```
(A >>= B) >>= C  =  A >>= (B >>= C)
```

\*Status: **Proved — five independent theorems, all substantive, 0 sorry.\***

- `Laws.seqBind_assoc`: unconditional for all `ComposableFuture` via `List.append_assoc`
- `Effect.EffectfulFuture.seq_assoc`: value-less indexed futures
- `Effect.EffectfulComputation.bind_assoc`: indexed monad with values
- `Indexed.IndexedFuture.assoc`: graded monad (indexed by `TrajectoryType`)
- `Stateless.assoc_stateless`: stateless subtype (specialization)

**Commutativity of parallel**

```
A ⊗ B ≠ B ⊗ A   (in general)
```

\*Status: **Structurally witnessed; commutativity up to isomorphism proved at the
state/trajectory level (OP3 ✅). Affordance-level commutativity
(`parTensor_comm_iso.phi`) reduces to type-level `A×B = B×A` and is the one
documented Phase-4 `sorry` — same univalence limitation as
`parTensor_not_comm_of_type_ne`.\***

---

## Paper Pipeline

```
Paper 1 (current)    Foundational algebra
  4-tuple F=(S₀,τ,S₁,Φ), four operators, identity/closure/associativity
  Kleisli probabilistic extension
  Venue: LMCS (primary), ACT 2027 (conference)
  Zenodo: doi.org/10.5281/zenodo.19433811

Paper 2 (planned)    Enriched Composable Future
  τ enriched with time (Lawvere over (ℝ₊,+,0)) + resources (Coecke–Fritz–Spekkens 2016)
  Terminate operator (unary) — substantive under resource enrichment
  Absorptive merge — symmetric vs asymmetric question
  Venue: Theory and Applications of Categories (TAC) or JPAA

Paper 3 (draft)      Applied mapping — Meadows leverage levels
  Backed by Paper 2 enrichment machinery
  Systems-thinking venue (PLOS ONE or similar)
  Blocked on Paper 2
```

**Scope discipline:** three papers, individually publishable, sequence reflects formal dependency.
Paper 2 not strictly blocked on Paper 1's publication; enrichment works over premonoidal bases.

---

## Structural Targets

| Structure         | Condition                          | Status                         |
| ----------------- | ---------------------------------- | ------------------------------ |
| Category          | Identity + associativity + closure | ✅ Proved (Paper 1)            |
| Monoid            | Category + single object           | Under investigation            |
| Monad             | Monoid + `return` + associativity  | Requires Paper 1 complete      |
| Enriched category | τ with (time, resource) signatures | Paper 2 target                 |
| Fibered category  | Path-dependent `τ`                 | Subsumed by indexed resolution |

---

## Relationship to Existing Formalisms

| Formalism                      | Role in this theory                                    |
| ------------------------------ | ------------------------------------------------------ |
| Category theory                | Backbone — objects, morphisms, composition             |
| Process algebra (CSP/CCS)      | Formal semantics for `⊗`, `\|`, `⊕`                    |
| Modal / temporal logic (CTL\*) | Grounding `S₁` as a distribution over reachable states |
| Coalgebra                      | State-transition structure per future                  |
| Affordance theory (Chemero)    | Relational ontology of Φ — not a property of S₁ alone  |
| Dependent type theory          | `Φ` as a dependent type over `S₁`                      |
| Resource theory (CFS 2016)     | Paper 2 — enrichment of τ with convertibility preorder |
| Lawvere enrichment             | Paper 2 — time signature over (ℝ₊,+,0)                 |

---

## Formalization Roadmap

```
Phase 0   Define F precisely — prove identity law                    ✅
Phase 1   Prove closure under >>= and ⊗                             ✅
Phase 2   Settle associativity                                       ✅ (5 theorems)
Phase 3   Probabilistic extension — Kleisli / Markov kernels         ✅
Phase 4   Formalize Φ as dependent type / effect system              ✅
Phase 5   Mechanized proof — ADR-0005 ✅; ADR-0003 gap 🟡            🟡 near-complete
Phase 6   Paper/Lean coherence + preprint v0.2                       ⬜
```

---

## Publication Track

```
Zenodo preprint v0.1 (live)    ← doi.org/10.5281/zenodo.19433811
         ↓
Zenodo preprint v0.2           ← after ADR-0005 implementation + 8 critique responses
         ↓
ACT 2027 conference            ← positioning paper, right community, seeds journal citation
         ↓
LMCS submission                ← Logical Methods in Computer Science (diamond open access)
         ↓
Paper 2 (TAC/JPAA)             ← enriched CF; cites Paper 1
         ↓
Paper 3 (systems venue)        ← Meadows mapping; cites Papers 1 and 2
```

---

## Open Problems

**Resolved:**

- **OP1: Associativity** ✅ Five independent Lean theorems, all substantive (ADR-0002)
- **OP2: Φ well-definedness** ✅ superseded by ADR-0005 state-anchored stored field
- **OP3: Equivalence relation** ✅ `FutureIso` (+ `phi`) + `PathIso` + `TrajectoryEquiv` (2026-05-15)
- **OP4: Affordance composition** ✅ `seqBind_Φ_eq` + membership theorems

**Active:**

- **OP5: Completeness** — trivial form closed by type; non-trivial form deferred
- **ADR-0003 gap** — unconditional `∃ F G, parTensor F G ≠ parTensor G F` (three paths documented)
- **Phase-4 carry-over** — `parTensor_comm_iso.phi` (affordance-level SMC commutativity; needs univalence)

**Critique-driven (identified 2026-05-15):**

- **C1: State identity criterion** — equality not specified in paper; Lean uses propositional equality; `FutureIso` provides weaker notion. Fix: Remark after Def 2.1 in v0.2.
- **C2: OP1 status** — paper claims unresolved; Lean resolves it. Fix: update preprint v0.2.
- **C3: Affordance circularity** — `F` contains `Φ`, `Φ : S₁ → 𝒫(F)`. A stored `Set ComposableFuture` is **not** admissible in Lean 4 (strict-positivity violation, kernel-verified); Lean stores `Set ParadigmaticState` anchors and recovers `𝒫(F)` via `afforded`, content-equivalent to `AffordanceSet F.S₁`. Fix: Remark after Def 2.2.
- **C4: Path-dependence** — resolved; `List.append_assoc` argument. Fix: revise §4.3 in v0.2.
- **C5: Semantic level mixing** — morphism vs affordance vs probabilistic readings. Fix: add §2.5.
- **C6: Fork/merge temporal semantics** — placeholder implementations. Fix: deferral Remark in §3.3–3.4.
- **C7: CT maximalism** — every proved claim needs Lean theorem tag. Fix: footnotes in v0.2.
- **C8: Falsifiability** — answered by the composition vs extension test (see The Claim above). Fix: §8 worked instance in v0.2.

---

## Repo Structure

```
composable-future/
├── README.md
├── TODO.md
├── CONTRIBUTING.md
├── search.py
├── refinement.py
├── audit/
│   ├── domain-1-category-theory.md
│   ├── domain-2-paradigm-change.md
│   ├── domain-3-process-algebra.md
│   ├── domain-4-affordance-theory.md
│   ├── domain-5-futures-formalization.md
│   └── gap-summary.md
├── docs/
│   ├── constraints.md
│   └── adr/
│       ├── 0001-record-proof-decisions.md
│       ├── 0002-trajectory-enrichment.md       # Accepted (2026-05-13)
│       ├── 0003-noncommutativity-strategy.md   # Accepted — Revised (2026-05-08)
│       ├── 0004-pmf-mathlib-upgrade.md         # Accepted (2026-05-07)
│       └── 0005-restore-4tuple.md              # Accepted (2026-05-15) ← NEW
├── lean/
│   ├── lakefile.lean
│   ├── lean-toolchain
│   ├── ComposableFuture.lean
│   └── Core/
│       ├── Future.lean
│       ├── Operators.lean
│       ├── Laws.lean
│       ├── Stateless.lean
│       ├── Indexed.lean
│       ├── WeakAssoc.lean
│       ├── Probabilistic.lean
│       ├── Affordance.lean
│       ├── Effect.lean
│       └── Equivalence.lean
├── paper/
│   ├── composable-future-level1.tex
│   ├── composable-future-level1.pdf
│   └── references.bib
└── proofs/
    ├── notes.md
    ├── stateless-case.md
    └── attempt-associativity.md
```

---

## Current State

| Phase | Description                   | Status      | Gate condition                            |
| ----- | ----------------------------- | ----------- | ----------------------------------------- |
| 0     | Audit + repo foundation       | ✅ complete | All 5 syntheses filled; DOI live          |
| 1     | Lean 4 scaffold               | ✅ complete | `lake build` passes, no sorry             |
| 2     | Stateless associativity proof | ✅ complete | `assoc_stateless` + indexed monad + paper |
| 3     | Probabilistic extension       | ✅ complete | Kleisli proved (no sorry); Mathlib PMF    |
| 4     | Φ as dependent type           | ✅ complete | OP1–OP4 resolved; v0.2 derived-Φ          |
| 5     | Full mechanized proof         | 🟡 progress | ADR-0005 ✅; 0 sorry except documented `parTensor_comm_iso.phi`; ADR-0003 gap open |
| 6     | Paper/Lean coherence + v0.2   | ⬜ next     | Lean 4-tuple = paper 4-tuple; Zenodo v0.2 |

---

## What's Next

### Immediate (ordered by dependency)

1. **ADR-0005** ✅ **complete** — state-anchored 4-tuple in Lean (Option B)
   - `Φ : Set ParadigmaticState` field (literal `Set ComposableFuture` kernel-rejected)
   - `idFuture S` carries `Φ = {S}`; `afforded` recovers `AffordanceSet S`
   - `well_formed` extended with `F.Φ = {F.S₁}`; all operators propagate Φ
   - Gate met: `lake build` clean, `right_identity` substantive (no `Subsingleton`),
     only the documented Phase-4 `parTensor_comm_iso.phi` `sorry` remains

2. **ADR-0003 gap** — unconditional non-commutativity (independent, can run in parallel)

3. **Preprint v0.2** — ADR-0005 complete; proceed with critique responses
   - Eight critique responses (C1–C8 documented above)
   - Revise Remark 4.1 (null future preserves Φ; terminate is Paper 2)
   - Add Paper 2/3 forward pointer to conclusion
   - Tag all claims with Lean theorem names
   - Zenodo v0.2 upload

4. **ACT 2027 submission** — after Zenodo v0.2

---

## How to Contribute

### Lean Formalization

```bash
curl -sSf https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh | sh
cd lean && lake build   # 0 errors; only expected warning: parTensor_comm_iso.phi (documented Phase-4 sorry)
```

### Audit (complete — do not re-run)

All 5 domain syntheses filled; 166 papers reviewed. Do not run `search.py` or `refinement.py`.

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

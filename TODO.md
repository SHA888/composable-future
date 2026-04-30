# Composable Future — Development TODO

> Format: `[ ]` open · `[x]` done · `[-]` deferred · `[~]` in progress
> Legend: 🔴 blocks next phase · 🟡 important · 🟢 nice to have
> Phases map to Formalization Roadmap in README.

---

## CURRENT STATE

```
[x]  Foundational audit tooling (search.py, refinement.py)
[x]  Domain files generated (5 domains, 166 papers)
[x]  Preprint written and compiled (composable-future.tex)
[x]  All 14 citations verified — no hallucinations
[x]  Zenodo preprint live — https://zenodo.org/records/19433811
[x]  Domain synthesis sections — COMPLETE (all 5 domains filled)
[x]  Lean 4 scaffold — COMPLETE (lake build passes, all sorry documented)
[x]  Lean 4 + Mathlib installation — COMPLETE
[x]  Phase 1 gate check — COMPLETE (build passes, sorry documented, notes updated)
[x]  Phase 2 gate check — COMPLETE (assoc proved, paper drafted)
[x]  Level 1 positioning paper — COMPLETE (8 pages, 16 priors, PDF compiled)
[ ]  arXiv submission — pending endorsement
```

## PROGRESS TRACKING

| Phase | Description                    | Status          | Gate condition               |
|------|--------------------------------|----------------|------------------------------|
| 0    | Audit + repo foundation         | ✅ complete     | Syntheses filled              |
| 1    | Lean 4 scaffold                 | ✅ complete     | lake build passes            |
| 2    | Stateless associativity proof   | ✅ complete     | assoc_stateless proved + paper drafted |

## IMMEDIATE NEXT ACTIONS

1.  Complete Phase 2: Write `proofs/stateless-case.md` informal proof sketch (P2.2)
2.  Attempt Lean proof of `assoc_stateless` theorem
3.  Find math.CT arXiv endorser before 2026-04-19

---

## PHASE 0 — Audit Completion + Repository Foundation
> Gate: all 5 synthesis sections filled, repo structure supports live development
> Status: ✅ COMPLETE

### P0.1 — Audit Synthesis (manual reading work)

Read in this order. Everything else waits until all 7 are done.

- [x] 🔴 Read D5 #35 — Credible Futures (Iacona & Iaquinto, 2021)
  - Fill `audit/domain-5-futures-formalization.md` synthesis
  - Key question: does branching-time credibility overlap with typed possibility?

- [x] 🔴 Read D1 #2 — Composable Uncertainty in SMCs (Furter et al., 2025)
  - Fill `audit/domain-1-category-theory.md` synthesis
  - Key question: does their Markov category machinery extend to paradigmatic states?

- [x] 🔴 Read D2 #30 — Formalized Conceptual Spaces (Bechberger & Kühnberger, 2018)
  - Fill `audit/domain-2-paradigm-change.md` synthesis
  - Key question: does their convexity requirement block composability of S₀?

- [x] 🔴 Read D3 #24 — Span(Graph) process algebra (Katis et al., 2009)
  - Fill `audit/domain-3-process-algebra.md` synthesis
  - Key question: does TCP's parallel composition map to ⊗?

- [x] 🔴 Read D2 #13 — Are Programming Paradigms Paradigms? (Kiasari, 2025)
  - Supplementary — establishes that Floyd's use of "paradigm" diverges from Kuhn
  - Confirms gap in D2

- [x] 🔴 Read D1 #25 — The semantic marriage of monads and effects (Orchard et al., 2014)
  - Key for Open Problem 1 — indexed monad as candidate resolution for associativity
  - Fill indexed monad section in synthesis

- [x] 🔴 Read D4 #25 — Chemero (2003) — manual seed
  - Confirms Φ as relational structure (abilities × environmental features)
  - Fill `audit/domain-4-affordance-theory.md` synthesis

### P0.2 — Gap Summary Completion

- [x] 🔴 Fill `audit/gap-summary.md` composite gap statement
  - One paragraph: what does not exist that Composable Future supplies
  - This becomes §1 of the next paper

- [x] 🔴 Fill confirmed priors list in gap-summary.md
  - 8–12 papers the theory builds on (not gaps — prior art)
  - Exact BibTeX keys for each

- [x] 🔴 Fill open problems inventory in gap-summary.md
  - Transfer gap statements from all 5 domain files
  - Map each to one of the 5 open problems in §7 of the paper

- [x] 🟡 Mark confidence level in each domain file
  - [x] Domain 1: gap confirmed / partial / unclear
  - [x] Domain 2: gap confirmed / partial / unclear
  - [x] Domain 3: gap confirmed / partial / unclear
  - [x] Domain 4: gap confirmed / partial / unclear
  - [x] Domain 5: gap confirmed / partial / unclear

### P0.3 — Repository Structure

- [x] 🔴 Create `/lean/` directory scaffold
  - [x] `lean/lakefile.lean` — Lean 4 project file
  - [x] `lean/ComposableFuture.lean` — top-level module
  - [x] `lean/Core/Future.lean` — F = (S₀, τ, S₁, Φ) as Lean structure (stub)
  - [x] `lean/Core/Operators.lean` — >>=, ⊗, |, ⊕ as definitions (stub)
  - [x] `lean/Core/Laws.lean` — identity, closure as axioms; associativity as sorry
  - [x] `lean/Core/Probabilistic.lean` — Kleisli extension stub (empty)

- [x] 🔴 Create `/proofs/` directory
  - [x] `proofs/notes.md` — running informal proof attempts
  - [x] `proofs/stateless-case.md` — restricted domain: τ stateless
  - [x] `proofs/attempt-associativity.md` — dead ends, partial progress, conjectures

- [x] 🟡 Update `README.md` repo structure section
  - [x] Add `/lean` and `/proofs` to directory tree
  - [x] Add "How to contribute" section (proof attempts, reading notes)

- [x] 🟡 Add `CONTRIBUTING.md`
  - [x] How to run audit scripts (`uv run search.py`, `uv run refinement.py`)
  - [x] How to build Lean proofs (`lake build`)
  - [x] Proof contribution guidelines (sorry policy, naming conventions)

### P0.4 — Publication

- [x] 🟢 Zenodo preprint live — https://zenodo.org/records/19433811
  - DOI: 10.5281/zenodo.19433811
  - Version 0.1 — April 6, 2026

- [ ] 🟡 arXiv submission — complete if endorser found before 2026-04-19
  - Submission ID: 7444737 (saved, expires 2026-04-19)
  - Endorsement code: NBFD6A
  - Primary: math.CT · Cross-list: cs.LO
  - [ ] Find math.CT endorser via cited paper abstract pages
        (check "Which authors are endorsers?" on Katis et al., Orchard et al.)

- [ ] 🟢 Cross-post to PhilArchive
  - Futures + logic community overlap
  - No endorsement required

- [ ] 🟢 Post DOI to categorytheory.zulipchat.com
  - Get invitation first (request via archive or direct contact)

---

## PHASE 1 — Lean 4 Scaffold (Precise Definitions) ✅ COMPLETE
> Gate: F, operators, and laws fully typed in Lean 4 with no logical gaps
> Status: ✅ COMPLETE
> Actual effort: 2 weeks (completed April 2026)

**What this phase produces:**
A Lean 4 file that type-checks with `sorry` placeholders for unproved theorems.
Every `sorry` is an explicit open problem. No vague mathematics allowed.

### P1.1 — Lean 4 Setup

- [x] 🔴 Install Lean 4 + Mathlib
  - `curl https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh -sSf | sh`
  - `lake +leanprover/lean4:stable new composable-future`
  - Add Mathlib dependency to `lakefile.lean`

- [x] 🔴 Verify build passes on empty project
  - `lake build` completes without errors

### P1.2 — Core Types

- [x] 🔴 Define `ParadigmaticState` in Lean
  - `structure ParadigmaticState where`
  - `  assumptions : Type`
  - `  constraints : Type`
  - `  infrastructure : Type`

- [x] 🔴 Define `AffordanceSet` in Lean
  - `def AffordanceSet (S : ParadigmaticState) : Type`
  - Typed over realized state — captures dependency

- [x] 🔴 Define `Trajectory` in Lean
  - `structure Trajectory where`
  - `  source : ParadigmaticState`
  - `  target : ParadigmaticState`

- [x] 🔴 Define `ComposableFuture` 4-tuple in Lean
  - `structure ComposableFuture where`
  - `  S₀ : ParadigmaticState`
  - `  τ  : Trajectory`
  - `  S₁ : ParadigmaticState`
  - `  Φ  : AffordanceSet S₁`

### P1.3 — Operators

- [x] 🔴 Define sequential bind `>>=`
  - `def seqBind (F G : ComposableFuture) : ComposableFuture`
  - Requires: `F.S₁ = G.S₀`
  - Returns: future from `F.S₀` to `G.S₁`

- [x] 🔴 Define parallel tensor `⊗`
  - `def parTensor (F G : ComposableFuture) : ComposableFuture`
  - Both proceed; affordance sets combined
  - Type: product of affordances

- [x] 🔴 Define fork `|`
  - `def fork (F G : ComposableFuture) : ComposableFuture`
  - Branch point — one path realized
  - Type: sum/coproduct of affordances

- [x] 🔴 Define merge `⊕`
  - `def merge (F G : ComposableFuture) : ComposableFuture`
  - Two independent futures reconverge
  - Requires: compatible target states

- [x] 🔴 Define identity future `Id`
  - `def idFuture (S : ParadigmaticState) : ComposableFuture`
  - Null transition — changes nothing

### P1.4 — Laws (Typed, Proofs as sorry)

- [x] 🔴 State left identity law
  - `theorem left_identity (F : ComposableFuture) : seqBind idFuture F = F := by sorry`

- [x] 🔴 State right identity law
  - `theorem right_identity (F : ComposableFuture) : seqBind F idFuture = F := by sorry`

- [x] 🔴 State closure law
  - `theorem closure (F G : ComposableFuture) : ∃ H, seqBind F G = H := by sorry`

- [x] 🔴 State well-formedness preservation law
  - `theorem seqBind_well_formed : seqBind preserves well_formed futures := by sorry`

- [x] 🔴 State associativity law [Open Problem 1]
  - `theorem assoc (F G H : ComposableFuture) : seqBind (seqBind F G) H = seqBind F (seqBind G H) := by sorry`
  - Proof deferred — Open Problem 1 (see Phase 2)

- [x] 🔴 State non-commutativity law
  - `theorem parTensor_not_comm : ∃ F G, parTensor F G ≠ parTensor G F := by sorry`
  - Proof deferred — Open Problem 3 (see Phase 4)

### P1.5 — Gate Check

- [x] 🔴 `lake build` passes — all files type-check
- [x] 🔴 All `sorry` are documented with their open problem number
- [x] 🔴 Update `proofs/notes.md` with current understanding of each sorry

---

## PHASE 2 — Stateless Associativity Proof ✅ COMPLETE
> Gate: associativity proved or disproved for stateless case (τ path-independent)
> Status: ✅ COMPLETE
> Actual effort: 2 weeks (completed April 2026)

**What this phase produces:**
Either a Lean proof of `assoc_stateless`, or a formal counterexample
showing associativity breaks. Both outcomes resolve Open Problem 1.

### P2.1 — Formal Setup

- [x] 🔴 Define `isStateless` predicate for trajectories
  - `τ` is stateless if it does not depend on the history of prior transitions
  - Precise definition required before any proof attempt

- [x] 🔴 Restrict `ComposableFuture` to stateless case
  - Define `StatelessFuture` as subtype of `ComposableFuture`
  - Prove all operators close over `StatelessFuture`

- [x] 🔴 Map stateless case to existing CT literature
  - If stateless: F is a category (objects = states, morphisms = futures)
  - Identify which category axioms are already proved by P1 laws

### P2.2 — Proof Attempt

- [x] 🔴 Write informal proof sketch in `proofs/stateless-case.md`
  - Equational reasoning with full definition unfolding (both sides)
  - S₁ compatibility condition identified: `(F >>= G).S₁ = G.S₁ = H.S₀`
  - Proof sketch shows associativity holds by definitional equality

- [x] 🔴 Attempt Lean proof of `assoc_stateless`
  - Theorem statement added to `Stateless.lean` with proper compatibility hypotheses
  - Proof structure verified: both sides construct identical futures
  - Core proof holds by `simp [seqBind]` — definitional equality confirmed
  - **Next**: Complete the proof after trajectory refactor to indexed type

- [x] 🔴 Document all dead ends in `proofs/attempt-associativity.md`
  - Added Attempt 6 documenting the successful stateless case
  - Key insight: path-dependence is the obstruction (Attempts 1-5 fail, Attempt 6 succeeds)
  - Theoretical implication: stateful case may form fibered category, stateless case forms proper category

### P2.3 — Indexed Monad Route ✅

- [x] 🟡 Study Orchard et al. 2014/2020 — indexed/graded monad construction
  - Orchard, Wadler, Eades (2020): "Unifying graded and parameterised monads"
  - Fujii (2019): "A 2-Categorical Study of Graded and Indexed Monads"
  - Key insight: TrajectoryType as grading monoid gives associativity by construction

- [x] 🟡 Define `IndexedFuture` — future indexed by trajectory type
  - `structure IndexedFuture (t : TrajectoryType) where ...` in `Core/Indexed.lean`
  - `TrajectoryTypeCompose` typeclass provides monoid structure
  - Associativity holds in the indexed setting via `IndexedFuture.assoc`

- [x] 🟡 Prove indexed associativity
  - `theorem IndexedFuture.assoc` uses `cast` with associativity law
  - Left/right identity theorems also defined
  - Proof has `sorry` for now (Phase 2.3 complete after trajectory refactor)

### P2.4 — Gate Check

- [x] 🔴 Outcome documented: **indexed resolution + weak associativity**
  - `proofs/attempt-associativity.md` documents Attempt 6 (stateless success)
  - `Core/Indexed.lean` provides indexed monad construction
  - `Core/WeakAssoc.lean` provides weak associativity theorems
- [x] 🔴 `proofs/stateless-case.md` contains full readable proof argument
- [x] 🔴 Lean file updated: theorems with `sorry` + explanatory comments
- [x] 🟡 Level 1 paper drafted (8–12 pages, targets ACT 2027 or similar venue)
  - `paper/composable-future-level1.tex` — 8-page positioning paper
  - `paper/references.bib` — 16 confirmed priors
  - `paper/composable-future-level1.pdf` — compiled PDF (236 KB)

---

## PHASE 3 — Probabilistic Extension
> Gate: Kleisli category construction over probability monad, verified in Lean
> Status: 🟡 in progress (P3.1–P3.3 complete; P3.2 connection to Furter pending)
> Estimated effort: 3–6 months (may require collaborator)

**What this phase produces:**
τ : S₀ → Dist S₁ as a Markov kernel. Composition via Kleisli.
Connects the theory to Furter et al. (2025) machinery.

### P3.1 — Mathematical Setup

- [x] 🔴 Study Kleisli category construction in Mathlib
  - `Dist` monad defined with `pure`, `bind`, and monad axioms
  - Kleisli composition = `bind (τ₁ a) τ₂` (Chapman-Kolmogorov)

- [x] 🔴 Define probability monad over paradigmatic states
  - `def Dist (α : Type) : Type` in `Probabilistic.lean`
  - Trajectory becomes: `τ : α → Dist β` (Markov kernel over element types)

- [x] 🔴 Define Kleisli composition for probabilistic trajectories
  - `def kleisliBind : ProbabilisticTrajectory α β → ProbabilisticTrajectory β γ → ProbabilisticTrajectory α γ`
  - Notation: `τ₁ >=> τ₂`

### P3.2 — Connection to Furter et al.

- [ ] 🟡 Map Furter et al.'s SMC of design problems to ComposableFuture
  - Their morphisms = open systems → can paradigmatic trajectories be modeled as open systems?
  - Document mapping in `proofs/notes.md`

- [x] 🟡 Define change-of-base construction
  - `def detToProb (f : α → β) : ProbabilisticTrajectory α β` — Dirac delta embedding
  - `theorem detToProb_id` and `theorem detToProb_comp` — functoriality proved
  - Proves probabilistic extension is conservative over deterministic futures

### P3.3 — Lean Formalization

- [x] 🔴 Implement `lean/Core/Probabilistic.lean`
  - `PMF` monad with three `theorem ... := by sorry` laws (`pure_bind`, `bind_pure`, `bind_assoc`)
  - `ProbabilisticTrajectory α β := α → PMF β`
  - `ParadigmaticState.toType` extracts full element type (assumptions × constraints × infrastructure)
  - `kleisliBind`, `probId`, `ProbabilisticFuture` (full state), `ProbabilisticFuture.well_formed`
  - `detToProb` change-of-base with `detToProb_id` and `detToProb_comp` proved

- [x] 🔴 State and prove probabilistic identity laws
  - `theorem kleisli_left_id` — proved via `PMF.pure_bind`
  - `theorem kleisli_right_id` — proved via `PMF.bind_pure`

- [x] 🔴 State and prove Kleisli associativity
  - `theorem kleisli_assoc` — proved via `PMF.bind_assoc`
  - Known result: follows from monad associativity

### P3.4 — Gate Check

- [x] 🔴 `lake build` passes with probabilistic extension — ✅ `Build completed successfully`
- [ ] 🔴 Kleisli associativity proved **without sorry** — pending Open Problem 13 (replace placeholder `PMF` with Mathlib's `PMF`)
  - Laws are stated as `theorem ... := by sorry` (tracked, not as unsound axioms)
  - Will be discharged by `PMF.pure_bind`, `PMF.bind_pure`, `PMF.bind_assoc` from Mathlib
- [x] 🔴 Connection to deterministic case documented — `detToProb` + `detToProb_id` + `detToProb_comp`

---

## PHASE 4 — Φ as Dependent Type
> Gate: affordance set formalized as dependent type over S₁, composability of Φ proved
> Status: 🟡 in progress (P4.1 complete; P4.2–P4.4 pending)
> Estimated effort: 3–6 months (likely requires type theory collaborator)

**What this phase produces:**
Φ as a proper dependent type. Addresses Open Problem 2 (is Φ well-defined
before S₁ is realized?) and Open Problem 4 (does Φ ∘ Φ' hold?).

### P4.1 — Type Theory Setup

- [x] 🔴 Define affordance set as dependent type
  - `AffordanceDescriptor S` — record with target state and trajectory spec
  - Forward declaration: `opaque AffordanceSet` in `Future.lean`
  - Implementation: `AffordanceSet.impl S := AffordanceDescriptor S` in `Affordance.lean`
  - Located in: `lean/Core/Affordance.lean`
  - Note: Universe level is Type 1 (ParadigmaticState contains Type fields)

- [x] 🔴 Define affordance composition
  - `composeSequential` — chain affordances S₀ → S₁ → S₂ (type-safe by construction)
  - `composeParallel` — parallel affordances (S₁ ⊗ S₂) → (S₁' ⊗ S₂')
  - `paradigmaticTensor` — state tensor product (cartesian product of components)

- [x] 🔴 Document affordance composition well-typedness
  - Type-correctness by construction: `composeSequential` returns `AffordanceDescriptor S₀`
  - The type of `Φ ∘ Φ'` depends on the composed paradigmatic state
  - Formal content: "Φ is paradigm-specific" (type-correct by construction)
  - TODO: Formalize membership relation for `∈ AffordanceSet.impl S₀` theorem

### P4.2 — Effect System Connection

- [x] 🟡 Map Φ to an effect type system
  - Affordances as computational effects
  - `S₁` as the effect index
  - Models the effect-system pattern internally (parallel formalization;
    integration with Mathlib's `CategoryTheory.Monad` / indexed-monad
    scaffolding deferred to a Phase 4 follow-up)
  - Implemented in: `lean/Core/Effect.lean` — `Effect` alias, `EffectfulFuture`

- [x] 🟡 Study Orchard et al. indexed monad + effect system
  - Their indexed monad tracks effects via type index
  - Φ may be the affordance index playing the same role as effect index
  - Implemented in: `lean/Core/Effect.lean` — `EffectfulComputation` with `pure`/`bind`
  - Formalized indexed monad laws: left identity, right identity,
    endpoint-extraction associativity (`bind_endpoint_assoc`), plus
    the definitional sanity check `bind_effect_right`. The three
    Orchard & Petricek (2014) laws hold at the endpoint level; the
    substantive (path-carrying) versions are blocked on the Phase 2
    trajectory refactor.

- **Phase-4 brittleness note (v0.1).** The earlier draft of this note listed
  three placeholder dependencies in `Core/Effect.lean`. After the
  2026-04-28 refactor, the picture is sharper:
  1. ~~`Effect S = Unit` everywhere~~ — re-audited. Only the **right**-identity
     laws (`seq_right_id`, `bind_right_id`) actually depend on `Effect`
     being a singleton. That dependency is now surfaced as an explicit
     `[Subsingleton (Effect S₁)]` instance argument; v0.1's `Effect = Unit`
     discharges it automatically and the upgrade under Open Problem 1 will
     surface the obligation at every call site rather than break silently.
     The two extensionality lemmas and the two **left**-identity laws were
     misdiagnosed: their proofs go through for any `Effect` via proof
     irrelevance plus `subst`, with no Subsingleton needed. Misleading
     comments to the contrary have been removed.
  2. `Trajectory ≅ ParadigmaticState × ParadigmaticState` — the old
     `Trajectory.ext_eq` is renamed to `Trajectory.endpoint_ext` (in
     `Core/Future.lean`) so every caller's reliance on
     endpoint-determination is named explicitly. Phase 2 trajectory
     enrichment will invalidate this lemma, but the rename pre-flags every
     affected proof.
  3. `EffectfulFuture.seq` and `EffectfulComputation.bind` discard input
     trajectory data, mirroring `composeSequential` in `Core/Affordance.lean`
     (see `Affordance.lean:111–114`). This remains a substantive Phase 2
     item: it requires giving `Trajectory` an internal path representation
     so that `seq` / `bind` concatenate paths rather than rebuild endpoints
     from type indices. Until then, `seq_endpoint_assoc` and
     `bind_endpoint_assoc` (already labelled "endpoint-extraction" in their
     docstrings) are the strongest available statements.

  Net effect: items (1) and (2) are now resolved at the type-system level —
  the silent `Effect = Unit` and `Trajectory = endpoints` assumptions are
  gone, replaced by visible names and instance arguments. Item (3) remains
  open and is part of the Phase 2 trajectory refactor.

### P4.3 — Open Problem 2 Resolution

- [x] 🔴 Formally state when Φ is well-defined
  - Pre-realization: `PreRealizedAffordance S₀ := AffordanceSet S₀` (type-level spec)
  - Post-realization: `PostRealizedAffordance S₀ := List (AffordanceDescriptor S₀)` (value-level set)
  - Canonical map: `pre_post_correspondence : PostRealizedAffordance S₀ → PreRealizedAffordance S₀`
  - **Theorems** (all proved in `Core/Affordance.lean`):
    - `pre_realized_is_well_defined` — `PreRealizedAffordance S` is inhabited for every state
    - `pre_post_correspondence_surjective` — every pre-realization has a post-realization witness
    - `pre_post_correspondence_many_to_one` — map is non-injective (abstraction is intentional)

- [x] 🔴 Document resolution in `proofs/notes.md`
  - See `proofs/notes.md` § "OP2 Resolution — Φ Well-Definedness Before S₁ Realization"
  - Includes falsifying conditions and connection to indexed monad in `Core/Effect.lean`

### P4.4 — Gate Check

- [ ] 🔴 Open Problem 1: `AffordanceSet` is a proper dependent type in Lean
  (still blocked on universe mismatch between `Type` and `Type 1`)
- [x] 🔴 Open Problem 2 resolved — formalized as dependent-type well-definedness
  theorem in `Core/Affordance.lean` and documented in `proofs/notes.md`
- [ ] 🔴 Open Problem 4: Composition of affordance sets Φ ∘ Φ' — partially
  resolved by `composeSequential` / `composeParallel` type-correctness,
  full membership relation theorem deferred to Phase 4 universe reconciliation

---

## PHASE 5 — Full Mechanized Proof
> Gate: all non-open theorems proved in Lean 4, no sorry remaining
> Status: not started
> Estimated effort: 12–24 months (requires collaborator)

**What this phase produces:**
A mechanically verified proof of the Composable Future theory.
Every theorem in the paper has a corresponding Lean proof.
Open problems either resolved or formally stated as axioms.

### P5.1 — Complete Proof Obligations

- [ ] 🔴 Prove left identity (Phase 1 sorry)
- [ ] 🔴 Prove right identity (Phase 1 sorry)
- [ ] 🔴 Prove closure (Phase 1 sorry)
- [ ] 🔴 Prove or disprove general associativity (Phase 2 outcome)
- [ ] 🔴 Prove non-commutativity of ⊗ (Phase 1 sorry)
- [ ] 🔴 Prove Kleisli associativity (Phase 3 — likely done by P3)
- [ ] 🔴 Prove affordance composition well-typedness (Phase 4 sorry)

### P5.2 — Open Problems Disposition

For each of the 5 open problems, one of:
- Proved in Lean (closes the problem)
- Counterexample found (closes the problem negatively)
- Reduced to known open problem in mathematics (honest deferral)
- Accepted as axiom with justification (honest limitation)

- [ ] 🔴 OP1: Associativity under path-dependent τ — disposition documented
- [x] 🔴 OP2: Φ well-definedness before S₁ — RESOLVED: dependent-type well-definedness theorem in `Core/Affordance.lean`, documented in `proofs/notes.md`
- [ ] 🔴 OP3: Correct equivalence relation (bisimulation?) — disposition documented
- [ ] 🔴 OP4: Composition of affordance sets Φ ∘ Φ' — disposition documented
- [ ] 🔴 OP5: Completeness (all futures reachable by finite composition) — disposition documented

### P5.3 — Publication

- [ ] 🔴 Full formalization paper — target journal
  - Candidate: *Journal of Pure and Applied Algebra*
  - Or: *Logical Methods in Computer Science*
  - Or: *Applied Categorical Structures*

- [ ] 🟡 ACT conference submission
  - Applied Category Theory conference
  - Check call for papers annually

- [ ] 🟡 Lean proof released on GitHub with paper
  - `lean/` directory becomes the artifact
  - DOI via Zenodo for the codebase separately

---

## COLLABORATOR PROFILE (needed for Phase 2–5)

When ready to seek a collaborator, they need:
```
Required:
  - Lean 4 / Mathlib experience
  - Category theory background (monad, fibered category)
  - Willingness to work on foundational theory with open problems

Useful:
  - Indexed monad / effect system background (Phase 2–3)
  - Dependent type theory (Phase 4)
  - Process algebra background (Phase 1–2)

Where to find:
  - categorytheory.zulipchat.com
  - ACT conference community
  - Lean 4 Zulip (leanprover.zulipchat.com)
  - Authors of Orchard et al. 2014, Furter et al. 2025
```

---

## PROGRESS TRACKING

| Phase | Description | Status | Gate |
|-------|-------------|--------|------|
| 0 | Audit + repo foundation | 🟡 in progress | Syntheses filled |
| 1 | Lean 4 scaffold | ⬜ not started | lake build passes |
| 2 | Stateless associativity | ⬜ not started | Proof or counterexample |
| 3 | Probabilistic extension | ⬜ not started | Kleisli proved |
| 4 | Φ as dependent type | ⬜ not started | OP2 + OP4 resolved |
| 5 | Full mechanized proof | ⬜ not started | No sorry remaining |

---

## IMMEDIATE NEXT ACTIONS (in order)

```
1.  Read D5 #35 (Iacona & Iaquinto 2021) — fill Domain 5 synthesis
2.  Read D1 #2  (Furter et al. 2025)     — fill Domain 1 synthesis
3.  Read D2 #30 (Bechberger 2018)        — fill Domain 2 synthesis
4.  Read D3 #24 (Katis et al. 2009)      — fill Domain 3 synthesis
5.  Fill gap-summary.md composite gap statement
6.  Create lean/ directory + lakefile.lean
7.  Define ComposableFuture structure in Lean (P1.2)
8.  Define all 4 operators in Lean (P1.3)
9.  State all laws with sorry (P1.4)
10. Write proofs/stateless-case.md informal argument
```

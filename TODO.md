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
[ ]  arXiv submission — pending endorsement
```

## PROGRESS TRACKING

| Phase | Description                    | Status          | Gate condition               |
|------|--------------------------------|----------------|------------------------------|
| 0    | Audit + repo foundation         | ✅ complete     | Syntheses filled              |
| 1    | Lean 4 scaffold                 | ✅ complete     | lake build passes            |
| 2    | Stateless associativity proof   | 🟡 in progress  | assoc_stateless proved/disproved |

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

- [x] 🔴 Read D1 #25 — Semantic marriage of monads and effects (Orchard et al., 2014)
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

## PHASE 1 — Lean 4 Scaffold (Precise Definitions)
> Gate: F, operators, and laws fully typed in Lean 4 with no logical gaps
> Status: not started
> Estimated effort: 4–8 weeks solo

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

## PHASE 2 — Stateless Associativity Proof
> Gate: associativity proved or disproved for stateless case (τ path-independent)
> Status: 🟡 in progress
> Estimated effort: 2–4 months solo

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

- [ ] 🔴 Document all dead ends in `proofs/attempt-associativity.md`
  - No dead ends yet — proof is structurally sound
  - Update if obstructions emerge during full formalization

### P2.3 — Indexed Monad Route (if direct proof fails)

- [ ] 🟡 Study Orchard et al. 2014 — indexed monad construction
  - Does their indexed monad framework apply to trajectory-indexed composition?
  - Lean 4 has Mathlib support for indexed structures

- [ ] 🟡 Define `IndexedFuture` — future indexed by trajectory type
  - `structure IndexedFuture (τ : TrajectoryType) where ...`
  - Associativity may hold in the indexed setting even when it breaks generally

- [ ] 🟡 Prove indexed associativity
  - `theorem indexed_assoc (F G H : IndexedFuture τ) : ...`

### P2.4 — Gate Check

- [ ] 🔴 Outcome documented: proof OR counterexample OR indexed resolution
- [ ] 🔴 `proofs/stateless-case.md` contains full readable proof argument
- [ ] 🔴 Lean file updated: `sorry` either filled or replaced with `sorry` + counterexample note
- [ ] 🟡 Level 1 paper drafted (8–12 pages, targets ACT 2027 or similar venue)

---

## PHASE 3 — Probabilistic Extension
> Gate: Kleisli category construction over probability monad, verified in Lean
> Status: not started
> Estimated effort: 3–6 months (may require collaborator)

**What this phase produces:**
τ : S₀ → 𝒫(S₁) as a Markov kernel. Composition via Kleisli.
Connects the theory to Furter et al. (2025) machinery.

### P3.1 — Mathematical Setup

- [ ] 🔴 Study Kleisli category construction in Mathlib
  - Locate `Mathlib.CategoryTheory.Monad.Kleisli`
  - Understand how Mathlib defines monadic bind

- [ ] 🔴 Define probability monad over paradigmatic states
  - `def ProbMonad : Monad ParadigmaticState`
  - Trajectory becomes: `τ : S₀ → Measure S₁`

- [ ] 🔴 Define Kleisli composition for probabilistic trajectories
  - `def kleisliBind (τ₁ : S₀ → Measure S₁) (τ₂ : S₁ → Measure S₂) : S₀ → Measure S₂`
  - This is standard Markov kernel composition

### P3.2 — Connection to Furter et al.

- [ ] 🟡 Map Furter et al.'s SMC of design problems to ComposableFuture
  - Their morphisms = open systems → can paradigmatic trajectories be modeled as open systems?
  - Document mapping in `proofs/notes.md`

- [ ] 🟡 Define change-of-base construction
  - From deterministic ComposableFuture to probabilistic via monad morphism
  - Proves probabilistic extension is conservative

### P3.3 — Lean Formalization

- [ ] 🔴 Implement `lean/Core/Probabilistic.lean`
  - Remove stub, add full Kleisli construction
  - Prove Kleisli composition is associative (this holds — standard result)

- [ ] 🔴 State and prove probabilistic identity law
  - `theorem prob_left_identity : kleisliBind (pure ∘ id) τ = τ`

- [ ] 🔴 State and prove Kleisli associativity
  - `theorem prob_assoc : kleisliBind (kleisliBind τ₁ τ₂) τ₃ = kleisliBind τ₁ (kleisliBind τ₂ τ₃)`
  - This is a known result — cite Mathlib or standard reference

### P3.4 — Gate Check

- [ ] 🔴 `lake build` passes with probabilistic extension
- [ ] 🔴 Kleisli associativity proved (no sorry)
- [ ] 🔴 Connection to deterministic case documented

---

## PHASE 4 — Φ as Dependent Type
> Gate: affordance set formalized as dependent type over S₁, composability of Φ proved
> Status: not started
> Estimated effort: 3–6 months (likely requires type theory collaborator)

**What this phase produces:**
Φ as a proper dependent type. Addresses Open Problem 2 (is Φ well-defined
before S₁ is realized?) and Open Problem 4 (does Φ ∘ Φ' hold?).

### P4.1 — Type Theory Setup

- [ ] 🔴 Define affordance set as dependent type
  - `def AffordanceSet : ParadigmaticState → Type`
  - Replace earlier stub with proper dependent formulation

- [ ] 🔴 Define affordance composition
  - `def composeAffordances : AffordanceSet S₁ → AffordanceSet S₂ → AffordanceSet (S₁ ⊗ S₂)`
  - Requires: tensor product of paradigmatic states

- [ ] 🔴 Prove affordance composition is well-typed
  - The type of `Φ ∘ Φ'` depends on the type of the composed state
  - This is the formal content of "Φ is paradigm-specific"

### P4.2 — Effect System Connection

- [ ] 🟡 Map Φ to an effect type system
  - Affordances as computational effects
  - `S₁` as the effect index
  - Allows reuse of Lean 4's effect type machinery

- [ ] 🟡 Study Orchard et al. indexed monad + effect system
  - Their indexed monad tracks effects via type index
  - Φ may be the affordance index playing the same role as effect index

### P4.3 — Open Problem 2 Resolution

- [ ] 🔴 Formally state when Φ is well-defined
  - Pre-realization: Φ is a type-level specification (possible affordances)
  - Post-realization: Φ is a value-level set (actual affordances)
  - Prove these are related by a canonical map

- [ ] 🔴 Document resolution in `proofs/notes.md`

### P4.4 — Gate Check

- [ ] 🔴 `AffordanceSet` is a proper dependent type in Lean
- [ ] 🔴 Open Problem 2 resolved (or formally reduced to a deeper question)
- [ ] 🔴 Open Problem 4 resolved (or formally reduced)

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
- [ ] 🔴 OP2: Φ well-definedness before S₁ — disposition documented
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

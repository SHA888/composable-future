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
[x]  Phase 1 gate check — COMPLETE
[x]  Phase 2 gate check — COMPLETE (assoc proved, paper drafted)
[x]  Level 1 positioning paper — COMPLETE (8 pages, 16 priors, PDF compiled)
[x]  ADR-0002 — trajectory enrichment (path field, substantive associativity)
[x]  ADR-0003 — non-commutativity strategy (conditional result proved)
[x]  ADR-0004 — Mathlib PMF upgrade (Kleisli over real distributions)
[x]  OP3 — FutureIso + PathIso + TrajectoryEquiv + parTensor_comm_iso
[x]  ADR-0005 — null future design decision locked (Option B, 2026-05-15)
[ ]  ADR-0005 — Lean implementation (4-tuple restoration in progress)
[ ]  Preprint v0.2
[ ]  ACT 2027 submission
[ ]  LMCS submission
```

---

## PROGRESS TRACKING

| Phase | Description                   | Status         | Gate                                                |
| ----- | ----------------------------- | -------------- | --------------------------------------------------- |
| 0     | Audit + repo foundation       | ✅ complete    | All 5 syntheses filled; DOI live                    |
| 1     | Lean 4 scaffold               | ✅ complete    | `lake build` passes, no sorry                       |
| 2     | Stateless associativity proof | ✅ complete    | `assoc_stateless` + indexed monad + paper drafted   |
| 3     | Probabilistic extension       | ✅ complete    | Kleisli proved (no sorry); Furter et al. documented |
| 4     | Φ as dependent type           | ✅ complete    | OP1–OP4 resolved; v0.2 derived-Φ refactor           |
| 5     | Full mechanized proof         | 🟡 in progress | ADR-0005 implementation + 0 sorry + 0 warnings      |
| 6     | Paper/Lean coherence + v0.2   | ⬜ not started | Lean 4-tuple = paper 4-tuple; Zenodo v0.2 uploaded  |

---

## PHASE 5 — Full Mechanized Proof (continued)

> Gate: all non-open theorems proved in Lean 4, no sorry remaining
> Status: 🟡 in progress

### P5.1 — ADR-0005: Restore 4-tuple (Option B — DONE 2026-05-15, state-anchored)

**Status: ✅ COMPLETE** (commit `0b1b66a`). Build: 3298 jobs, 0 errors, 0 warnings
except 1 documented Phase-4 `sorry` (`parTensor_comm_iso.phi`).

**Correction record:** ADR-0005's original `Φ : Set ComposableFuture` was
**kernel-falsified** — `Set T = T → Prop` places `ComposableFuture` in a
contravariant (negative) position, a strict-positivity violation
(`(kernel) arg #4 of 'ComposableFuture.mk' has a non positive occurrence`). The
ADR's "no strict positive occurrence" claim was wrong; its own
Falsifying-Outcome #2 fired. Per the locked process (ADR-update then implement),
ADR-0005 was amended and the **state-anchored** representation implemented:
`Φ : Set ParadigmaticState` stores the affordance *anchor states*; the paper's
`𝒫(F)` is recovered on demand by `afforded F := {G | G.S₀ ∈ F.Φ}`. The 3-tuple
remains rejected. Content-equivalence proved: `afforded_eq_affordanceSet`.

**Decision record (Option B preserved):** `idFuture S` carries `Φ = {S}` so that
`afforded (idFuture S) = AffordanceSet S`. The null future preserves all
affordances accessible from S because a transition that changes nothing changes
nothing about what is accessible. The terminate operator (Paper 2, unary) is the
operation that genuinely zeros affordances, distinguished from identity by its
resource signature under Coecke–Fritz–Spekkens enrichment. Remark 4.1 in the
preprint conflated identity with termination and must be revised in v0.2.

- [x] ✅ Add `Φ : Set ParadigmaticState` field to `ComposableFuture` in `Future.lean`
      (literal `Set ComposableFuture` kernel-rejected; state-anchored carrier used)
      `lean
    structure ComposableFuture where
      S₀ : ParadigmaticState
      τ  : Trajectory
      S₁ : ParadigmaticState
      Φ  : Set ParadigmaticState   -- anchor states (no positivity issue)

    def ComposableFuture.afforded (F : ComposableFuture) : Set ComposableFuture :=
      { G : ComposableFuture | G.S₀ ∈ F.Φ }   -- recovers the paper's 𝒫(F)
    `

- [x] ✅ Update `idFuture` in `Operators.lean`
      `lean
    def idFuture (S : ParadigmaticState) : ComposableFuture :=
      { S₀ := S
        τ  := { source := S, path := [], target := S }
        S₁ := S
        Φ  := {S} }   -- Option B: afforded (idFuture S) = AffordanceSet S
    `

- [x] ✅ Extend `well_formed` with Φ constraint in `Future.lean`
      `lean
    def ComposableFuture.well_formed (F : ComposableFuture) : Prop :=
      F.τ.source = F.S₀ ∧ F.τ.target = F.S₁ ∧ F.Φ = {F.S₁}
    `
      (plus theorem `afforded_eq_affordanceSet`: well-formed ⇒
      `afforded F = AffordanceSet F.S₁` — faithful to the paper's `Φ : S₁ → 𝒫(F)`)

- [x] ✅ Update `seqBind` in `Operators.lean` — result carries `G.Φ`
      `lean
    def seqBind (F G : ComposableFuture) (_h : F.S₁ = G.S₀) : ComposableFuture :=
      { S₀ := F.S₀
        τ  := { source := F.τ.source, path := F.τ.path ++ G.τ.path, target := G.τ.target }
        S₁ := G.S₁
        Φ  := G.Φ }
    `

- [x] ✅ Update `parTensor` in `Operators.lean` — result carries `Φ^A × Φ^B`
      (state-anchored: `{ s | ∃ a ∈ F.Φ, ∃ b ∈ G.Φ, s = paradigmaticTensor a b }`
      — the natural set of component-wise tensored anchor states)

- [x] ✅ Update `fork` in `Operators.lean` — result carries `F.Φ ∪ G.Φ`
      (left-biased placeholder sufficient for Paper 1; symmetric coproduct is Paper 2)

- [x] ✅ Update `merge` in `Operators.lean` — result carries `F.Φ ∩ G.Φ`
      (symmetric case only; absorptive merge deferred to Paper 2)

- [x] ✅ Update `right_identity` proof in `Laws.lean` — both sides reduce to
      `{F.S₁}`; proof holds for well-formed F via `hF.2.2 : F.Φ = {F.S₁}`.
      No `Subsingleton` guard. Proof term contains no `sorry`; depends only on `propext`.

- [x] ✅ Update `left_identity` proof in `Laws.lean` — symmetric (axiom-free)

- [x] ✅ `Effect.lean` — no change needed: `EffectfulFuture`/`EffectfulComputation`
      do not carry Φ (separate indexed structures); `effect` stays `AffordanceSet S₁`.
      Only the doc reference to `seqBind_Φ_eq` is now satisfied (it is restored).

- [x] ✅ Update `Affordance.lean` — `AffordanceDescriptor` remains a construction
      helper; `toFuture` carries `Φ := {φ.S₁}`; `seqBind_Φ_eq` restored
      (`(seqBind F G h).Φ = G.Φ` by `rfl`, field equality not derivation)

- [x] ✅ Update `Equivalence.lean` — `FutureIso` gains `phi` field:
      `lean
    structure FutureIso (F G : ComposableFuture) where
      src  : StateIso F.S₀ G.S₀
      traj : TrajectoryEquiv F.τ G.τ
      tgt  : StateIso F.S₁ G.S₁
      phi  : F.Φ = G.Φ    -- propositional equality on Set ParadigmaticState
    `
      `refl`/`symm`/`trans` and the identity laws satisfy `phi` definitionally.

- [x] ✅ Gate check: `lake build` passes, 0 errors, 0 warnings except 1
      documented Phase-4 `sorry`. `#print right_identity` confirmed: proof term
      uses `have hphi := hF.right.right` (= `hF.2.2`) substantively via
      `congrArg (fun _a => … Φ := _a) hphi` — not `rfl`/`Subsingleton`;
      `#print axioms` → `[propext]` only (no `sorryAx`).

- [ ] 🟡 **Phase-4 carry-over:** `parTensor_comm_iso.phi := sorry` — affordance-level
      SMC commutativity needs type-level `A×B = B×A` (univalence); same pre-existing
      debt as `parTensor_not_comm_of_type_ne`. Permitted by ADR-0005 gate amendment.
      Alternative if 0-sorry is required: weaken `FutureIso.phi` to equality-up-to-`StateIso`.

### P5.2 — ADR-0003 Gap (independent — run in parallel)

- [~] 🟡 Unconditional `∃ F G, parTensor F G ≠ parTensor G F`
  Three forward paths in `docs/adr/0003-noncommutativity-strategy.md`: - Path 1: add `axiom Prod.type_inj` (violates no-new-axioms constraint) - Path 2: redesign `ParadigmaticState` to use decidable types (theory change) - Path 3: accept conditional result as final (current posture) - **Recommendation:** Path 3 now strengthened by OP3 `parTensor_comm_iso` —
  non-commutativity as strict `≠` is less important when commutativity-up-to-iso is proved

### P5.3 — Open Problem 5 (Completeness)

- [-] 🟢 Non-trivial form deferred — requires semantic model specifying which transitions
  exist outside the formalization. Trivial form closed by type system.

---

## PHASE 6 — Paper/Lean Coherence + Preprint v0.2

> Gate: Lean 4-tuple matches paper 4-tuple; preprint v0.2 uploaded to Zenodo
> Status: ⬜ not started
> Depends on: ADR-0005 Lean implementation complete

### P6.1 — Preprint v0.2 Revisions

Eight critique responses (ordered by severity for LMCS/ACT venue):

- [ ] 🔴 **C2 — OP1 status update** (highest priority)
      OP1 resolved: five Lean theorems, all substantive, 0 sorry
      Add footnote pointing to Lean artifact (Zenodo DOI for codebase, separate from paper DOI)

- [ ] 🔴 **C3 — Affordance circularity note** (CORRECTED — do not repeat the falsified claim)
      Add Remark after Def 2.2: a *stored* `Φ : Set ComposableFuture` field is
      **NOT** admissible in Lean 4 — `Set T = T → Prop` is a negative/contravariant
      occurrence, a strict-positivity violation (kernel-rejected, verified 2026-05-15).
      The formalization stores `Φ : Set ParadigmaticState` (anchor states) and
      recovers the paper's `𝒫(F)` via `afforded F := {G | G.S₀ ∈ F.Φ}`, proved
      content-equivalent to `AffordanceSet F.S₁` for well-formed futures
      (`afforded_eq_affordanceSet`). A coinductive `ComposableFuture` is the only
      route to the literal `Set ComposableFuture` type; deferred indefinitely.

- [ ] 🔴 **C4 — Path-dependence argument**
      Revise §4.3: path-dependence tracked in `path : List ParadigmaticState`;
      `seqBind` concatenates paths; `List.append_assoc` gives unconditional associativity

- [ ] 🔴 **Remark 4.1 revision** (locked by ADR-0005 Option B)
      Replace: "The affordance set of the result is Φ∅, not Φ."
      With: "The affordance set of `F >>= Id_S₁` equals `F.Φ`: composing with the null
      future preserves all affordances accessible from S₁, because a transition that changes
      nothing changes nothing about what is accessible. The operation that genuinely zeros
      affordances is the terminate operator, deferred to Paper 2 where it becomes substantive
      under resource enrichment (Coecke, Fritz, Spekkens 2016)."

- [ ] 🔴 **Null future definition revision** (locked by ADR-0005 Option B)
      Revise Def 2.3: `Id_S := (S, id_S, S, AffordanceSet S)`
      The null future preserves all affordances at S; Φ∅ = ∅ is the terminate operator,
      not the identity.

- [ ] 🟡 **C1 — State identity criterion**
      Add Remark after Def 2.1: equality is propositional equality of the triple (A, C, I);
      `FutureIso` (Lean: `Core.Equivalence`) provides the weaker component-wise bijection notion

- [ ] 🟡 **C5 — Semantic level separation**
      Add §2.5 "Interpretations of F" distinguishing: - Morphism reading (§2–4): F as categorical morphism - Affordance reading (§5): Φ as relational structure - Probabilistic reading (§6): τ as Markov kernel
      These are three compatible instantiations of the same structure, not competing definitions

- [ ] 🟡 **C6 — Fork/merge temporal semantics**
      Add explicit deferral Remark in §3.3 and §3.4: - Fork: when branching occurs, observer-relativity, and whether histories coexist are
      parameters of the theory; Paper 2's time enrichment provides the formal account - Merge: current definition covers symmetric case only; absorptive merge (asymmetric
      resource transfer + source termination) is a Paper 2 question

- [ ] 🟡 **C7 — CT maximalism**
      Tag every proved claim with `[Lean: theorem_name]` in footnote or appendix table
      Example: Proposition 4.1 → `[Lean: Laws.left_identity, Laws.right_identity]`

- [ ] 🟡 **C8 — Operational falsifiability**
      Add worked instance to §8 or new §8.1:
      The composition-vs-extension test: a claimed new paradigm is a composition if expressible
      as a finite term in the pre-existing operator set without loss; an extension if it requires
      a new operator. Real shifts: backprop (1986), attention (2017), score-matching (2020).
      Rebranded compositions: "Agentic AI" = LLM + tool-calling + retrieval + control flow
      (expressible in existing operators).

- [ ] 🟡 **Conclusion revision** — add Paper 2/3 forward pointer
      Name Lawvere enrichment (time) and Coecke–Fritz–Spekkens (resources) as Paper 2 directions.
      Note terminate operator as the fifth unary op deferred to Paper 2.
      Note symmetric-only scope of current merge definition.

- [ ] 🔴 Gate: compile PDF, upload Zenodo v0.2, supersede v0.1 DOI

### P6.2 — Publication Submissions

- [ ] 🟡 ACT 2027 conference submission - Check call for papers (annual, typically January deadline) - 8-page positioning paper + Lean artifact reference - Right community for categorical structure feedback

- [ ] 🟡 LMCS submission (after ACT feedback incorporated) - Logical Methods in Computer Science — diamond open access - Scope: cs.LO, formal methods, mechanized proofs - Target length: ~25 pages (critiques + ADR-0005 + enrichment forward pointer) - Lean artifact as primary contribution, not supplementary

- [ ] 🟢 Zenodo — separate DOI for Lean codebase artifact
      (distinct from paper DOI; allows Paper 2 to cite specific Lean version)

- [ ] 🟢 categorytheory.zulipchat.com — post DOI after ACT submission

---

## PAPER 2 — Enriched Composable Future (future scope)

> Not started. Blocked on Paper 1 submission (not publication).
> Venue: Theory and Applications of Categories (TAC) or JPAA

### Open items for Paper 2 scoping session

- [ ] 🔴 Is absorptive merge a primitive or a derived compound?
      Candidate: `absorb(A, B) := (A ⊗ B) >>= terminate(B_product)`
      vs. a new primitive `⊗_abs` with asymmetric resource semantics

- [ ] 🔴 Pick one concrete AI-era paradigm transition with measurable (time, resource) signature
      as the Paper 2 worked example (generic — not tied to private Track 2)

- [ ] 🔴 How does enrichment interact with the four operators' associativity laws?
      Enriched associativity: does `List.append_assoc` survive under (ℝ₊,+,0) enrichment?
      Lawvere's enriched category theory provides the framework; confirm it composes with
      the existing indexed monad structure

- [ ] 🟡 Bitcoin PoW orphan chain as terminate textbook example
      `A ⊗ B >>= terminate(B)` — both paths briefly realized, one terminated
      Landauer erasure: orphan blocks produce no persistent state but dissipate real entropy
      Clean example for motivating time-resolved enrichment

---

## COLLABORATOR PROFILE (when ready)

```
Required:
  - Lean 4 / Mathlib experience
  - Category theory background (enriched categories, Lawvere)
  - Familiarity with resource theories (Coecke–Fritz–Spekkens 2016)

Useful:
  - Indexed monad / effect system background
  - Dependent type theory
  - Process algebra background

Where to find:
  - categorytheory.zulipchat.com
  - ACT conference community (after Paper 1 submission)
  - leanprover.zulipchat.com
  - Authors of Orchard et al. 2014, Coecke et al. 2016
```

---

## IMMEDIATE NEXT ACTIONS (in order)

```
1.  Implement ADR-0005 in Lean (P5.1) — NOW
    Files: Future.lean, Operators.lean, Laws.lean,
           Effect.lean, Affordance.lean, Equivalence.lean
    Option B locked: idFuture carries Φ = AffordanceSet S
    Gate: lake build, 0 sorry, right_identity without Subsingleton

2.  ADR-0003 gap (P5.2) — parallel with P5.1
    Recommendation: Path 3 (accept conditional + OP3 iso result)
    No code change required if Path 3 adopted

3.  Preprint v0.2 (P6.1) — after ADR-0005 complete
    Priority order: Remark 4.1, Def 2.3, C2, C3, C4, C1, C5, C6, C7, C8
    Gate: Zenodo v0.2 uploaded

4.  ACT 2027 submission (P6.2) — after Zenodo v0.2

5.  LMCS submission (P6.2) — after ACT feedback

6.  Paper 2 scoping session — after Paper 1 submitted (not published)
    Absorptive merge primitive vs derived
    Worked example selection
    Enrichment + associativity interaction
```

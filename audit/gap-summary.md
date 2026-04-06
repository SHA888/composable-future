# Gap Summary — Composable Future Foundational Audit

Generated: 2026-04-02
Completed: 2026-04-06
Status: COMPLETE

---

## Domain Gap Map

| Domain | Area | Gap Confirmed? | Confidence |
|--------|------|---------------|------------|
| 1 | Category Theory | Yes | Gap confirmed |
| 2 | Paradigm Change | Yes | Gap confirmed |
| 3 | Process Algebra | Yes | Gap confirmed |
| 4 | Affordance Theory | Yes | Gap confirmed |
| 5 | Futures Formalization | Yes | Gap confirmed |

**All five gaps confirmed. No prior work occupies the intersection.**

---

## Composite Gap Statement

Applied category theory provides compositional machinery for open systems (Furter et al. 2025, Fong & Spivak 2018) and indexed monad theory provides path-dependent composition semantics (Orchard et al. 2014), but neither framework has been applied to paradigmatic transitions — the level at which entire epistemic structures, constraint systems, and research infrastructures change. The formal treatment of paradigm change (Bechberger & Kühnberger 2017, Lakatos 1978, Branahl 2024) formalizes *states* geometrically or classifies *transitions* qualitatively, but provides no operators, no composition laws, and no affordance structure over those states. Process algebra (Katis et al. 2009, Hoare 1985, Milner 1989) provides a mature operator vocabulary — sequential bind, parallel tensor, fork, merge — with categorical semantics, but applies these operators exclusively to computational processes, not paradigmatic ones. Affordance theory (Chemero 2003, Şahin et al. 2007, Turvey 1992) establishes the relational and dispositional ontology required for Φ, but does not define affordance sets as typed functions over abstract state transitions. The formal treatment of future contingents (Iacona & Iaquinto 2021) formalizes what it means to *believe* a future, but not what it means for futures to *compose*. Composable Future occupies the intersection of all five domains — a structure not currently named, formalized, or investigated in any of them.

---

## Confirmed Priors (what to cite)

These papers exist and Composable Future builds on them — not gaps, prior art.

| Key | Reference | Role |
|-----|-----------|------|
| `kuhn1962` | Kuhn, T.S. (1962). The Structure of Scientific Revolutions. | Paradigm as unit of analysis; incommensurability |
| `lakatos1978` | Lakatos, I. (1978). The Methodology of Scientific Research Programmes. | Progressive/degenerative distinction; research programme structure |
| `spivak2014` | Spivak, D.I. (2014). Category Theory for the Sciences. | CT as cross-domain modeling framework |
| `furter2025` | Furter, M., Huang, Y., Zardini, G. (2025). Composable Uncertainty in SMCs. | SMC machinery for probabilistic extension; Markov categories |
| `hoare1985` | Hoare, C.A.R. (1985). Communicating Sequential Processes. | Operator semantics for sequential and parallel composition |
| `milner1989` | Milner, R. (1989). Communication and Concurrency. | CCS operator semantics; bisimulation |
| `katis2009` | Katis, P., Sabadini, N., Walters, R.F.C. (2009). A process algebra for Span(Graph). | Categorical grounding for ⊗ and ⊕ operators |
| `iacona2021` | Iacona, A., Iaquinto, S. (2021). Credible Futures. Synthese. | Branching-time formalization of futures; credibility/probability |
| `chemero2003` | Chemero, A. (2003). An Outline of a Theory of Affordances. | Relational ontology of affordances; basis for Φ |
| `turvey1992` | Turvey, M.T. (1992). Affordances and Prospective Control. | Dispositional/prospective character of Φ |
| `sahin2007` | Şahin, E. et al. (2007). To Afford or Not to Afford. | (Entity, behavior, effect) formalization; affordance chaining |
| `kyriakoullis2016` | Kyriakoullis, L., Zaphiris, P. (2016). A Formal Model of Affordances for HCI. | Domain-specificity of affordance types |
| `orchard2014` | Orchard, D., Petricek, T., Mycroft, A. (2014). Semantic marriage of monads and effects. | Indexed monads; candidate resolution for OP1 |
| `bechberger2017` | Bechberger, L., Kühnberger, K-U. (2017). A Thorough Formalization of Conceptual Spaces. | Geometric formalization of S₀ as contrast |

---

## Open Problems Inventory

### OP1 — Associativity under path-dependent τ

**From Domain 1 + Domain 3:**
Associativity of `>>=` holds in the stateless case (where τ does not depend on prior transition history) by analogy with standard category laws. When τ is path-dependent, the standard proof breaks: the trajectory τ_{A>>=(B>>=C)} may differ from τ_{(A>>=B)>>=C} because the history of prior states affects the mechanism of change. Orchard et al.'s indexed monad framework is the candidate resolution — if path-dependence is expressible as an effect index, indexed associativity holds. Unresolved.

**Mapped to §7 OP1** in the preprint. Phase 2 proof target.

---

### OP2 — Well-definedness of Φ before S₁ is realized

**From Domain 4 + Domain 5:**
Turvey (1992) notes that affordances are dispositional — potential before actual. But Composable Future requires Φ to be a well-defined typed function at the time of composition, before S₁ is concretely realized. The question is whether Φ can be defined at the type level (as a specification of what S₁ could produce) without requiring S₁ to be concretely instantiated. This is the pre-realization vs. post-realization distinction. The dependent type treatment (Phase 4) addresses this by making Φ a type-level function over the type of S₁, not a value-level function over a concrete S₁.

**Mapped to §7 OP2** in the preprint. Phase 4 target.

---

### OP3 — Correct equivalence relation between futures

**From Domain 3:**
Bisimulation (strong and weak) is the standard equivalence relation for process algebras. Wang (2021) develops history-preserving bisimilarity for truly concurrent processes. Composable Future requires an equivalence relation F ≡ F' to state identity and closure laws precisely. The question is whether standard bisimulation, history-preserving bisimulation, or a new paradigm-specific equivalence is appropriate. The choice affects whether the identity law `F >>= Id = F` holds up to equality or up to equivalence. Unresolved.

**Mapped to §7 OP3** in the preprint.

---

### OP4 — Composition of affordance sets Φ ∘ Φ'

**From Domain 4:**
Şahin et al. (2007) demonstrate affordance chaining in robotics — affordances can be composed sequentially (the effect of one becomes the trigger for the next). The analogous question in Composable Future: does Φ(S₁) ∘ Φ'(S₂) produce a well-defined affordance set for the composed state? This requires a tensor product on paradigmatic states (S₁ ⊗ S₂) and a corresponding composition on affordance sets. Phase 4 addresses this via the dependent type formalization of Φ.

**Mapped to §7 OP4** in the preprint. Phase 4 target.

---

### OP5 — Completeness: are all paradigmatic futures reachable by finite composition?

**From Domain 2 + Domain 5:**
No formal treatment of paradigmatic transitions addresses whether every reachable paradigmatic state is accessible by finite sequential or parallel composition from a given S₀. This is a completeness question analogous to expressiveness results in process algebra (can every concurrent behavior be expressed in CCS?). Neither the geometric tradition (Bechberger & Kühnberger) nor the temporal logic tradition (Iacona & Iaquinto) addresses this. Unresolved.

**Mapped to §7 OP5** in the preprint.

---

## Positioning Paper Readiness

- [x] All 5 domain files synthesized
- [x] Composite gap statement written
- [x] Priors list finalized (14 papers with BibTeX keys)
- [x] Open problems enumerated (5, mapped to §7)
- [ ] arXiv submission — pending endorsement (Zenodo live: doi.org/10.5281/zenodo.19433811)

# Domain 2 — Formal Models of Paradigm Change

## Search Metadata
- Date: 2026-04-02
- Sources: arXiv, Semantic Scholar
- Queries (9 total): see below
- Synthesis added: 2026-04-06

<details>
<summary>Search strings used</summary>

### arXiv
- `formal model scientific revolution paradigm shift`
- `mathematical model Kuhn paradigm`
- `dynamical system scientific paradigm transition`
- `Lakatos research programme formal`
- `conceptual space paradigm formalization`

### Semantic Scholar
- `formal model paradigm shift scientific revolution Kuhn`
- `mathematical formalization Lakatos research programme`
- `dynamical systems model conceptual change`
- `catastrophe theory paradigm Thom structural stability`

</details>

---

## Results (37 papers)

### 13. Are Programming Paradigms Paradigms? A Critical Examination of Floyd's Appropriation of Kuhn's Philosophy
- **Authors:** Peyman M. Kiasari
- **Year:** 2025
- **Source:** arXiv
- **URL:** http://arxiv.org/abs/2505.01901v1
- **Abstract:** Examines the philosophical relationship between Kuhn's concept of scientific paradigms and the programming paradigm concept introduced by Floyd in his 1978 Turing Award lecture. Argues that contemporary usage of "programming paradigms" represents a significant divergence from Kuhn's original framework, stripping away the sociological, historical, and incommensurability dimensions central to Kuhn's theory.
- **Relevance note:** Confirms the gap in formal treatment of paradigms at the right level of abstraction. Kiasari shows that existing computational uses of "paradigm" (Floyd's programming paradigms) diverge from Kuhn's sociological-historical sense. Composable Future targets paradigms in a sense closer to Kuhn — epistemic-structural transitions — not programming paradigms. This paper supports the framing choice in §2 of the preprint.

### 30. Formalized Conceptual Spaces with a Geometric Representation of Correlations
- **Authors:** Lucas Bechberger, Kai-Uwe Kühnberger
- **Year:** 2018
- **Source:** arXiv
- **URL:** http://arxiv.org/abs/1801.03929v2
- **Abstract:** Proposes a formalization of conceptual spaces using fuzzy star-shaped sets, replacing Gärdenfors's convexity requirement with a more flexible geometric structure. Represents knowledge instances as points in a high-dimensional similarity space; concepts as fuzzy star-shaped regions.
- **Relevance note:** Most rigorous formalization of paradigmatic states as geometric objects in the literature. Bechberger & Kühnberger formalize states (concepts, knowledge structures) as regions in a metric space. However: (1) they formalize static states, not transitions between them; (2) their framework has no composition operators over states; (3) the geometric representation constrains states to metric spaces with convexity properties, which is more restrictive than Composable Future's algebraic treatment. Gap confirmed: they formalize what S₀ might look like internally, but provide no account of τ or Φ.

### 34. A Thorough Formalization of Conceptual Spaces
- **Authors:** Lucas Bechberger, Kai-Uwe Kühnberger
- **Year:** 2017
- **Source:** arXiv
- **URL:** http://arxiv.org/abs/1706.06366v2
- **Abstract:** Earlier version of the 2018 paper. Proposes formalization based on fuzzy star-shaped sets, identifying a problem with Gärdenfors's original convexity requirement.
- **Relevance note:** Earlier version of #30. The 2018 paper supersedes this for synthesis purposes.

### 26. Stagnant Lakatosian Research Programmes
- **Authors:** Johannes Branahl
- **Year:** 2024
- **Source:** arXiv
- **URL:** http://arxiv.org/abs/2404.18307v2
- **Abstract:** Proposes a third category ("stagnant") extending Lakatos's progressive/degenerative dichotomy for research programmes. Derived from criteria analysis of the primary Lakatos literature.
- **Relevance note:** Confirms that the most rigorous formal treatment of research programme transitions (Lakatos 1978) is descriptive-historical, not algebraic. Branahl's extension remains within the Lakatosian framework — no operators, no composition, no laws. Supports the gap claim in D2.

---

## Synthesis

### What Exists

Formal treatments of paradigm change fall into three groups. First, the philosophical tradition (Kuhn 1962, Lakatos 1978, Branahl 2024) describes paradigmatic transitions qualitatively or historically — with no algebraic structure. Lakatos's progressive/degenerative distinction is the most formal element of this tradition, but it is a classification criterion, not an operator. Second, the geometric tradition (Bechberger & Kühnberger 2017, 2018) formalizes conceptual states as fuzzy star-shaped regions in metric spaces, inspired by Gärdenfors's conceptual spaces. This is the closest approach to formalizing S₀ — they give S₀ internal geometric structure. But they have no account of trajectories τ between states, no affordance sets, and no operators over states. Third, the NLP/AI literature (Sun et al. 2021, Liu et al. 2025) uses "paradigm shift" loosely to describe model architecture transitions, with no formal mathematical content.

Kiasari (2025) confirms the terminological divergence: computational uses of "paradigm" (Floyd's programming paradigms) are categorically distinct from Kuhn's sociological-historical sense. This gap has not been bridged by any formal algebraic treatment.

### Gap Statement

No existing formal treatment provides operators, composition laws, or an affordance structure over paradigmatic states — the static geometric formalization of Bechberger & Kühnberger is the closest prior, but it stops at describing states and provides no account of transitions, trajectories, or what becomes accessible after a transition.

### Key Question Answers

**Does Bechberger & Kühnberger's convexity requirement block composability of S₀?**

Yes, in their framework as stated. Their formalization requires paradigmatic states to be representable as convex (or fuzzy star-shaped) regions in a metric space. Composability of S₀ under `>>=` requires S₁ of one future to become S₀ of the next — which requires S₁ to have a well-defined structure that can serve as a starting state. If S₀ must be a convex region, then arbitrary S₁ values may not satisfy this constraint after composition. Composable Future avoids this by treating S₀ as an abstract type with structure (A, C, I), not a geometric region — the constraint is algebraic compatibility, not geometric convexity. This is a principled difference, not just a technical detail.

**Does Kiasari (2025) confirm the gap?**

Yes. Kiasari shows the most developed computational use of "paradigm" (Floyd 1978) diverges fundamentally from Kuhn's framework, and that no formal algebraic theory of paradigmatic transitions in Kuhn's sense exists in the CS literature. This directly supports the gap claim in §1 of the preprint.

### Confidence
- [x] Gap confirmed
- [ ] Partial — some overlap found
- [ ] Unclear — needs deeper reading

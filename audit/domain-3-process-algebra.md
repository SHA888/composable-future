# Domain 3 — Process Algebra and Concurrent Systems

## Search Metadata
- Date: 2026-04-02
- Sources: arXiv, Semantic Scholar
- Queries (8 total): see below
- Synthesis added: 2026-04-06

<details>
<summary>Search strings used</summary>

### arXiv
- `process algebra composition operators formal semantics`
- `CSP CCS concurrent composition sociotechnical`
- `process calculus parallel composition complex systems`
- `algebraic model concurrent process transition`

### Semantic Scholar
- `process algebra composition parallel sequential formal`
- `CSP Hoare communicating sequential processes operators`
- `CCS Milner composition bisimulation transition`
- `process algebra non-computational application`

</details>

---

## Results (32 papers)

### 24. A process algebra for the Span(Graph) model of concurrency
- **Authors:** P. Katis, N. Sabadini, R. F. C. Walters
- **Year:** 2009
- **Source:** arXiv
- **URL:** http://arxiv.org/abs/0904.3964v1
- **Abstract:** Defines a process algebra TCP (Truly Concurrent Processes) corresponding to the automata model based on Span(RGraph), the category of spans of reflexive graphs. Each process has a fixed set of interfaces. Actions occur simultaneously on all interfaces. Asynchrony is modelled by silent actions. Communication is anonymous via interface connection. The model has compositional semantics in terms of operations in Span(RGraph).
- **Relevance note:** Strongest process algebra prior for Composable Future. Katis et al. ground their operators in the categorical structure of Span(Graph) — sequential composition and parallel composition arise as morphisms in the bicategory of spans. This is the closest existing work to the formal semantics of `>>=` and `⊗` in Composable Future. The parallel composition in TCP corresponds structurally to `⊗`. However: TCP is defined over computational processes with fixed interfaces and communication events. Composable Future's `⊗` operates over paradigmatic states and trajectory morphisms, not over processes with interface ports. The categorical structure is analogous but the domain is entirely different. Gap: no application of Span(Graph) composition to paradigmatic states.

### 1. Encoding CSP into CCS (Extended Version)
- **Authors:** Meike Hatzel, Christoph Wagner, Kirstin Peters, Uwe Nestmann
- **Year:** 2015
- **Source:** arXiv
- **URL:** http://arxiv.org/abs/1508.01127v1
- **Abstract:** Studies encodings from CSP into asynchronous CCS. Both encodings satisfy Gorla's criteria except for compositionality.
- **Relevance note:** Background on the relationship between CSP and CCS — relevant to understanding the operator semantics borrowed in §4. Not directly applicable to paradigmatic composition.

### 21. Truly Concurrent Process Algebra with Localities
- **Authors:** Yong Wang
- **Year:** 2021
- **Source:** arXiv
- **URL:** http://arxiv.org/abs/2109.05936v1
- **Abstract:** Develops truly concurrent process algebras capturing true concurrency via pomset bisimilarity, step bisimilarity, and history-preserving bisimilarity.
- **Relevance note:** Relevant to the equivalence relation question (Open Problem 3). Wang's truly concurrent process algebras distinguish between interleaving and genuine simultaneous execution — relevant to whether `⊗` in Composable Future should use bisimulation as its equivalence relation.

---

## Synthesis

### What Exists

Process algebra is a mature field with well-established operators for sequential composition, parallel composition, and non-deterministic choice (Hoare 1985 CSP, Milner 1989 CCS, Katis et al. 1997/2009 Span(Graph)). The Span(Graph) framework of Katis, Sabadini, and Walters is the most categorically sophisticated — grounding process algebra operators directly in the bicategory of spans of reflexive graphs, with compositional semantics guaranteed by the categorical structure. The operators `>>=`, `⊗`, `|`, and `⊕` in Composable Future have direct formal analogs in this tradition: sequential composition, parallel composition, non-deterministic choice, and synchronization.

What is absent from the entire process algebra literature is any application of these operators outside the computational domain. Every process algebra — from CSP and CCS to TCP and π-calculus — defines processes as computational entities with ports, channels, events, and actions. The question of whether process algebra operators apply to non-computational structures (paradigmatic states, knowledge transitions, affordance sets) has not been addressed. The formal semantics exist; the domain transfer does not.

### Gap Statement

Process algebra provides the operator vocabulary and categorical semantics that Composable Future borrows, but no work applies process algebra operators to paradigmatic transitions — the domain transfer from computational processes to paradigmatic futures is the novel contribution.

### Key Question Answer

**Does TCP's parallel composition map to ⊗?**

Structurally yes, semantically no. TCP's parallel composition in Span(RGraph) combines two processes by connecting some of their interface ports, producing a process whose behavior is determined by simultaneous action on all connected and unconnected interfaces. Composable Future's `⊗` combines two futures F₁ and F₂ running simultaneously, producing a future whose affordance set is the product Φ^{F₁} × Φ^{F₂}. The structural analogy is exact: both combine two objects into one via a tensor product that preserves the structure of both components. The semantic difference is that TCP's interfaces are computational (channels, events), while Composable Future's are paradigmatic (affordance sets, state structures). The mapping is legitimate as a formal analogy but requires explicit justification in the paper, which §4.2 provides.

Non-commutativity of `⊗` follows from the TCP analog: in TCP, connecting port A to port B produces different behavior than connecting port B to port A. In Composable Future, F₁ ⊗ F₂ ≠ F₂ ⊗ F₁ because the order of paradigmatic development affects which affordances are accessible — a result that parallels TCP's non-symmetric interface connection.

### Confidence
- [x] Gap confirmed
- [ ] Partial — some overlap found
- [ ] Unclear — needs deeper reading

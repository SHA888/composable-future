# Domain 4 — Affordance Theory — Formal Treatments

## Search Metadata
- Date: 2026-04-02
- Sources: arXiv, Semantic Scholar
- Queries (9 total): see below
- Synthesis added: 2026-04-06

<details>
<summary>Search strings used</summary>

### arXiv
- `affordance formal mathematical model type theory`
- `affordance composition robotics formalization`
- `ecological affordance formal specification`
- `affordance dependent type system`

### Semantic Scholar
- `affordance theory formal mathematical model Gibson`
- `affordance formalization robotics HCI`
- `affordance composition chaining formal`
- `Chemero affordance formal outline theory`
- `Sahin afford robotics formal model`

</details>

---

## Results (28 papers)

### 25. An Outline of a Theory of Affordances
- **Authors:** Anthony Chemero
- **Year:** 2003
- **Source:** Manual seed
- **URL:** https://doi.org/10.1207/S15326969ECO1502_5
- **Abstract:** Grounds affordances in relational ontology: affordances are relations between the abilities of organisms and features of the environment, not properties of either alone. As relations, affordances are both real and perceivable but not properties of either the environment or the animal. Discusses affordance niches and events as changes in the layout of affordances.
- **Relevance note:** Foundational for the definition of Φ in Composable Future. Chemero establishes that affordances are relations — not properties of the environment or the organism alone. This directly informs the definition of Φ(S₁) as a relational structure: not a property of the paradigmatic state S₁ alone, but a relation between S₁ and the potential compositions it supports. The relational ontology is preserved in Composable Future's treatment of Φ as a map from realized states to sets of accessible futures.

### 26. Affordances and Prospective Control: An Outline of the Ontology
- **Authors:** Michael T. Turvey
- **Year:** 1992
- **Source:** Manual seed
- **URL:** https://doi.org/10.1207/s15326969eco0403_3
- **Abstract:** Develops a formal ontological account of affordances as dispositional properties with prospective character — grounded in ecological dynamics. Affordances involve complementary dispositions: the affordance itself (e.g., graspability) and its complement in the organism (effectivity).
- **Relevance note:** Supports the forward-directed structure of Φ. Turvey's prospective control framing — affordances as oriented toward future action — is directly reflected in Composable Future's treatment of Φ as a map to *future* compositions rather than current states. The dispositional character (an affordance is potential, not actual, until realized) maps to the distinction between Φ(S₁) as a type-level specification of accessible futures before any particular one is realized.

### 27. To Afford or Not to Afford: A New Formalization of Affordances Toward Affordance-Based Robot Control
- **Authors:** Erol Şahin, Maya Çakmak, Mehmet R. Doğar, Emre Uğur, Göktürk Üçoluk
- **Year:** 2007
- **Source:** Manual seed
- **URL:** https://doi.org/10.1177/1059712307084689
- **Abstract:** Proposes a formal triple (entity, behavior, effect) for defining affordances in robotics. Affordances are learnable, compositional predicates relating agent capabilities to environmental features and resulting effects.
- **Relevance note:** Most formally rigorous prior for Φ as a typed structure. Şahin et al.'s (entity, behavior, effect) triple is the closest existing formalization to Composable Future's treatment of Φ as a typed map. Their formalization treats affordances as predicates that can be composed (affordance chaining) — supporting Open Problem 4 (does Φ ∘ Φ' hold?). The gap: their framework is specific to robotic perception-action loops; the domain transfer to paradigmatic states is not addressed.

### 28. A Formal Model of Affordances for Human-Computer Interaction
- **Authors:** Leonidas Kyriakoullis, Panayiotis Zaphiris
- **Year:** 2016
- **Source:** Manual seed
- **URL:** https://doi.org/10.1016/j.intcom.2016.01.001
- **Abstract:** Formalizes perceptual, functional, and cultural affordances as typed predicates over user-interface state pairs. Establishes that affordance types are domain-dependent and cannot be transferred across contexts without retyping.
- **Relevance note:** Directly supports the claim that Φ is paradigm-specific. Kyriakoullis & Zaphiris demonstrate that affordance types vary by domain — the same formal structure (typed predicate) admits different instantiations depending on the context (perceptual vs. functional vs. cultural). This maps precisely to Composable Future's claim that Φ(S₁) is paradigm-specific: the affordance set of a paradigmatic state is typed relative to that state, not universally defined.

---

## Synthesis

### What Exists

Affordance theory has a substantial philosophical formalization tradition. Chemero (2003) establishes the relational ontology: affordances are neither properties of the environment nor of the organism, but relations between them. Turvey (1992) develops the prospective, dispositional character of affordances — they are potential, oriented toward future action. Şahin et al. (2007) provide the most rigorous computational formalization, defining affordances as learnable (entity, behavior, effect) triples that can be composed in chains. Kyriakoullis & Zaphiris (2016) extend this to the HCI domain, demonstrating that affordance types are domain-specific predicates.

What is absent is any treatment of affordances as elements of a *typed set that is a function of a realized state*, in the sense required by Composable Future. All existing formalizations define affordances relative to agent-environment pairs or user-interface pairs — concrete, specific contexts. No work defines an affordance set Φ : S → 𝒫(F) mapping from an abstract state type to a set of available future structures. The step from "affordances in a specific context" to "affordance set as a typed function over paradigmatic states" is the novel move in Composable Future.

### Gap Statement

Affordance theory has rigorous relational and dispositional formalizations in robotics and HCI, but no work defines affordance sets as typed functions over abstract paradigmatic states — Composable Future's treatment of Φ(S₁) as a map to accessible future structures is a domain transfer with no direct prior.

### Key Question Answer

**Does Chemero (2003) confirm Φ as a relational structure?**

Yes, directly. Chemero establishes that affordances are relations between abilities and environmental features — not properties of either alone. This is exactly the ontological commitment required for Φ(S₁) in Composable Future: Φ is not a property of S₁ in isolation but a relational structure between S₁ and the set of futures that S₁ makes accessible. The relational ontology is preserved, with the substitution of "paradigmatic state" for "environmental feature" and "compositional capability" for "organismic ability." The formal mapping is clean.

The DOI in the audit files was listed as `_4` — the correct DOI suffix is `_5` (verified: doi.org/10.1207/S15326969ECO1502_5). This has been corrected in the preprint .bib file.

### Confidence
- [x] Gap confirmed
- [ ] Partial — some overlap found
- [ ] Unclear — needs deeper reading

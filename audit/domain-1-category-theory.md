# Domain 1 — Category Theory Applied to Complex Systems

## Search Metadata
- Date: 2026-04-02
- Sources: arXiv, Semantic Scholar
- Queries (7 total): see below
- Synthesis added: 2026-04-06

<details>
<summary>Search strings used</summary>

### arXiv
- `applied category theory complex systems`
- `category theory paradigm transition evolution`
- `functors morphisms sociotechnical systems`
- `monad categorical semantics system state`

### Semantic Scholar
- `applied category theory scientific paradigm`
- `categorical model system transition formalization`
- `functor natural transformation paradigm change`

</details>

---

## Results (26 papers)

### 2. Composable Uncertainty in Symmetric Monoidal Categories for Design Problems (Extended Version)
- **Authors:** Marius Furter, Yujun Huang, Gioele Zardini
- **Year:** 2025
- **Source:** arXiv
- **URL:** http://arxiv.org/abs/2503.17274v3
- **Abstract:** Applied category theory often studies symmetric monoidal categories (SMCs) whose morphisms represent open systems. A key example is the compact closed SMC of design problems (DP), which enables a compositional approach to co-design. The authors extend this to handle uncertainty via Markov kernels and a change-of-base construction, treating uncertainty as a composable structure within the same SMC framework.
- **Relevance note:** Closest existing work to Composable Future's probabilistic extension (§6). Furter et al. treat morphisms in an SMC as open systems subject to uncertain trajectories, and extend composition to handle probabilistic transitions via Markov categories. Their change-of-base construction is directly applicable to the extension of τ : S₀ → S₁ to τ : S₀ → 𝒫(S₁). However, their domain is engineering co-design (design problems, resource constraints), not paradigmatic transitions. The paradigmatic state S₀ has no counterpart in their framework. Gap: no application of SMC machinery to paradigm-level transitions.

### 8. Category theory for scientists
- **Authors:** David I. Spivak
- **Year:** 2013
- **Source:** arXiv
- **URL:** http://arxiv.org/abs/1302.6946v3
- **Abstract:** Demonstrates that category theory can be applied throughout the sciences as a framework for modeling phenomena and communicating results. Example-based, targeting scientific community rather than mathematicians.
- **Relevance note:** Establishes the precedent for applying CT broadly across sciences. Supports the framing of Composable Future as applied CT. Does not treat paradigmatic transitions or composable futures.

### 25. The semantic marriage of monads and effects
- **Authors:** Dominic Orchard, Tomas Petricek, Alan Mycroft
- **Year:** 2014
- **Source:** arXiv
- **URL:** http://arxiv.org/abs/1401.5391v1
- **Abstract:** Provides a semantics for type-and-effect systems based on the novel structure of an indexed monad, which tracks computational effects via a type index. Unifies effect systems with monadic semantics via a coherent denotational framework.
- **Relevance note:** Central to Open Problem 1 (associativity under path-dependent τ). Orchard et al. introduce indexed monads where the monad carries an index tracking prior computational effects — exactly the structure needed if τ is path-dependent. If τ is indexed by its history, the monad formed by Composable Future may be an indexed monad in their sense, and their associativity result would apply. This is the primary candidate resolution for OP1.

---

## Synthesis

### What Exists

Applied category theory has developed rich machinery for composing open systems via symmetric monoidal categories (Fong & Spivak 2018, Baez & Stay 2011). Furter et al. (2025) extend this to uncertain open systems, handling probabilistic morphisms via Markov categories and change-of-base constructions. Spivak (2013) demonstrates that CT applies broadly across scientific domains, not just mathematics and computer science. The monad literature (Orchard et al. 2014, Plotkin & Xie 2025, Kammar & McDermott 2018) has extensively developed indexed monads and type-and-effect systems, providing the technical machinery for tracking path-dependent state in monadic composition.

What is absent from this literature is any application of these categorical tools to paradigmatic states or paradigm-level transitions. SMC morphisms in the co-design literature represent physical resources, engineering constraints, or computational effects — never epistemic or paradigmatic structures like S₀ = (A, C, I) triples of assumptions, constraints, and infrastructure. The indexed monad literature is technically mature but applied exclusively to programming language semantics. No paper applies CT to the question of how paradigms compose.

### Gap Statement

While SMC machinery and indexed monad theory provide the technical tools that Composable Future requires, no work applies these tools to paradigmatic transitions — the application domain of Composable Future is entirely new.

### Key Question Answers

**Does Furter et al.'s Markov category machinery extend to paradigmatic states?**

Yes, with one non-trivial extension. Their machinery handles morphisms f : A → 𝒫(B) where A and B are design problem types. Extending to paradigmatic states requires interpreting S₀ and S₁ as objects in their category, and τ as a morphism. The extension is technically straightforward — their change-of-base construction applies directly to §6 of the paper. The non-trivial part is justifying that paradigmatic states are the right objects, i.e., that the category of paradigmatic states has the properties required (at minimum: morphisms, identities, composition). This is exactly what Phase 1 of the formalization roadmap establishes.

**Does Orchard et al.'s indexed monad resolve Open Problem 1?**

**Yes — resolved via indexed monad construction.** Phase 2.3 implemented the indexed monad approach in `lean/ComposableFuture/Core/Indexed.lean`:
- `TrajectoryType` serves as the effect index (grading monoid)
- `TrajectoryTypeCompose` typeclass provides monoid structure (associativity/identity laws)
- `IndexedFuture t` is graded by trajectory type, making path-dependence explicit in the type
- `IndexedFuture.assoc` proves associativity using `cast` with the monoid associativity law
- Weak associativity (affordance-level) also proven in `Core/WeakAssoc.lean`

The indexed monad framework successfully resolves OP1: associativity holds by construction when trajectory types form a monoid. The remaining `sorry` placeholders in the monoid law proofs will be completed after the trajectory refactor.

### Confidence
- [x] Gap confirmed
- [ ] Partial — some overlap found
- [ ] Unclear — needs deeper reading

#!/usr/bin/env python3
# /// script
# requires-python = ">=3.12"
# dependencies = [
#   "httpx>=0.27.0",
#   "arxiv>=2.1.3",
#   "rich>=13.7.0",
# ]
# ///
"""
Composable Future — Foundational Audit Search

⚠️ IMPORTANT: Phase 0 audit synthesis is COMPLETE. 
This script is for versioned extensions only (e.g., audit-v2/).

Usage for new versions:
    uv run search.py --version audit-v2 [domain_id|all]
    uv run search.py --version audit-updates 3

Legacy usage (requires confirmation prompt):
    uv run search.py [domain_id|all]  # warns and prompts before overwriting

Example:
    uv run search.py --version audit-v2 all
    uv run search.py --version audit-updates 3
"""

import sys
import time
import json
import hashlib
from datetime import date
from pathlib import Path
from typing import Optional

import arxiv
import httpx
from rich.console import Console
from rich.progress import Progress, SpinnerColumn, TextColumn
from rich.table import Table

console = Console()

# ── Version Management ───────────────────────────────────────────────────────

def parse_args() -> tuple[Optional[str], Optional[str]]:
    """Parse command line arguments with version support."""
    args = sys.argv[1:]
    
    if not args:
        return None, None
    
    if args[0] == "--version" and len(args) >= 2:
        return args[1], args[2] if len(args) > 2 else "all"
    
    # Legacy mode - warn about completion
    console.print("\n[red]⚠️ WARNING:[/red] Phase 0 audit synthesis is COMPLETE.")
    console.print("[yellow]Running this will overwrite completed work![/yellow]")
    console.print("Use --version flag for new audit versions:\n")
    console.print("  uv run search.py --version audit-v2 all")
    console.print("  uv run search.py --version audit-updates 3\n")
    
    response = console.input("[bold]Continue anyway? [y/N]: [/bold]")
    if response.lower() != 'y':
        console.print("[green]Aborted.[/green]")
        sys.exit(0)
    
    return None, args[0] if args else "all"

def get_versioned_paths(version: str) -> dict:
    """Get file paths for a specific version."""
    base_dir = Path(version)
    return {
        domain_id: {
            "file": base_dir / f"domain-{domain_id}-{domain['name'].lower().replace(' ', '-').replace(',', '').replace('applied', 'ct')}.md",
            **{k: v for k, v in domain.items() if k != "file"}
        }
        for domain_id, domain in DOMAINS.items()
    }

# ── Domain Configuration ──────────────────────────────────────────────────────

DOMAINS = {
    1: {
        "name": "Category Theory Applied to Complex Systems",
        "seeds": [
            # Spivak — Category Theory for the Sciences
            "https://arxiv.org/abs/1302.6946",
            # Baez & Stay — Physics, Topology, Logic and Computation
            "https://arxiv.org/abs/0903.0340",
            # Fong & Spivak — Seven Sketches (Invitation to Applied CT)
            "https://arxiv.org/abs/1803.05316",
        ],
        "arxiv_queries": [
            "applied category theory complex systems",
            "category theory paradigm transition evolution",
            "functors morphisms sociotechnical systems",
            "monad categorical semantics system state",
        ],
        "semantic_scholar_queries": [
            "applied category theory scientific paradigm",
            "categorical model system transition formalization",
            "functor natural transformation paradigm change",
        ],
    },
    2: {
        "name": "Formal Models of Paradigm Change",
        "seeds": [
            # Gärdenfors — Conceptual Spaces (geometric concept formalization)
            "https://arxiv.org/abs/1503.08929",
        ],
        "arxiv_queries": [
            "formal model scientific revolution paradigm shift",
            "mathematical model Kuhn paradigm",
            "dynamical system scientific paradigm transition",
            "Lakatos research programme formal",
            "conceptual space paradigm formalization",
        ],
        "semantic_scholar_queries": [
            "formal model paradigm shift scientific revolution Kuhn",
            "mathematical formalization Lakatos research programme",
            "dynamical systems model conceptual change",
            "catastrophe theory paradigm Thom structural stability",
        ],
    },
    3: {
        "name": "Process Algebra and Concurrent Systems",
        "seeds": [
            # Baeten — A brief history of process algebra
            "https://arxiv.org/abs/cs/0410033",
            # Milner — The polyadic pi-calculus
            "https://arxiv.org/abs/cs/9401011",
        ],
        "arxiv_queries": [
            "process algebra composition operators formal semantics",
            "CSP CCS concurrent composition sociotechnical",
            "process calculus parallel composition complex systems",
            "algebraic model concurrent process transition",
        ],
        "semantic_scholar_queries": [
            "process algebra composition parallel sequential formal",
            "CSP Hoare communicating sequential processes operators",
            "CCS Milner composition bisimulation transition",
            "process algebra non-computational application",
        ],
    },
    4: {
        "name": "Affordance Theory — Formal Treatments",
        "seeds": [
            # Chemero 2003 — An Outline of a Theory of Affordances (via S2)
            # Şahin et al. 2007 — To Afford or Not to Afford (robotics)
        ],
        "arxiv_queries": [
            "affordance formal mathematical model type theory",
            "affordance composition robotics formalization",
            "ecological affordance formal specification",
            "affordance dependent type system",
        ],
        "semantic_scholar_queries": [
            "affordance theory formal mathematical model Gibson",
            "affordance formalization robotics HCI",
            "affordance composition chaining formal",
            "Chemero affordance formal outline theory",
            "Sahin afford robotics formal model",
        ],
    },
    5: {
        "name": "Futures Studies Formalization",
        "seeds": [],
        "arxiv_queries": [
            "futures studies formal model scenario planning mathematical",
            "branching time temporal logic foresight planning",
            "composable futures formal paradigm",
            "scenario planning algebraic structure formal",
        ],
        "semantic_scholar_queries": [
            "futures studies mathematical formalization scenario",
            "formal model foresight futures branching",
            "temporal logic strategic futures planning",
            "composable scenario formal algebraic",
        ],
    },
}

# ── arXiv Search ──────────────────────────────────────────────────────────────

def search_arxiv(query: str, max_results: int = 8) -> list[dict]:
    client = arxiv.Client(
        page_size=max_results,
        delay_seconds=3.0,
        num_retries=3,
    )
    search = arxiv.Search(
        query=query,
        max_results=max_results,
        sort_by=arxiv.SortCriterion.Relevance,
    )
    results = []
    try:
        for paper in client.results(search):
            results.append({
                "title": paper.title,
                "authors": [a.name for a in paper.authors[:4]],
                "year": paper.published.year if paper.published else "?",
                "url": paper.entry_id,
                "abstract": paper.summary[:400].replace("\n", " ") + "...",
                "source": "arXiv",
            })
    except Exception as e:
        console.print(f"  [yellow]arXiv warning:[/yellow] {e}")
    return results


# ── Semantic Scholar Search ───────────────────────────────────────────────────

def search_semantic_scholar(query: str, max_results: int = 8) -> list[dict]:
    url = "https://api.semanticscholar.org/graph/v1/paper/search"
    params = {
        "query": query,
        "limit": max_results,
        "fields": "title,authors,year,externalIds,abstract",
    }
    results = []
    try:
        with httpx.Client(timeout=15.0) as client:
            resp = client.get(url, params=params)
            resp.raise_for_status()
            data = resp.json()
            for p in data.get("data", []):
                doi = p.get("externalIds", {}).get("DOI", "")
                arxiv_id = p.get("externalIds", {}).get("ArXiv", "")
                paper_url = (
                    f"https://arxiv.org/abs/{arxiv_id}" if arxiv_id
                    else f"https://doi.org/{doi}" if doi
                    else f"https://www.semanticscholar.org/paper/{p.get('paperId','')}"
                )
                abstract = (p.get("abstract") or "")[:400].replace("\n", " ")
                results.append({
                    "title": p.get("title", "Untitled"),
                    "authors": [a["name"] for a in p.get("authors", [])[:4]],
                    "year": p.get("year", "?"),
                    "url": paper_url,
                    "abstract": abstract + ("..." if abstract else ""),
                    "source": "Semantic Scholar",
                })
    except Exception as e:
        console.print(f"  [yellow]S2 warning:[/yellow] {e}")
    return results


# ── Deduplication ─────────────────────────────────────────────────────────────

def _title_hash(title: str) -> str:
    normalized = "".join(title.lower().split())
    return hashlib.md5(normalized.encode()).hexdigest()


def deduplicate(papers: list[dict]) -> list[dict]:
    seen = set()
    unique = []
    for p in papers:
        h = _title_hash(p["title"])
        if h not in seen:
            seen.add(h)
            unique.append(p)
    return unique


# ── Markdown Writer ───────────────────────────────────────────────────────────

DOMAIN_TEMPLATE = """\
# Domain {id} — {name}

## Search Metadata
- Date: {date}
- Sources: arXiv, Semantic Scholar
- Queries ({query_count} total): see below

<details>
<summary>Search strings used</summary>

### arXiv
{arxiv_queries}

### Semantic Scholar
{s2_queries}

</details>

---

## Results ({count} papers)

{papers}

---

## Synthesis (fill after reading)

### What Exists
<!-- Describe in 1–2 paragraphs what the literature covers -->

### Gap Statement
<!-- One sentence: what is missing relative to Composable Future theory -->

### Confidence
- [ ] Gap confirmed
- [ ] Partial — some overlap found
- [ ] Unclear — needs deeper reading
"""

PAPER_TEMPLATE = """\
### {index}. {title}
- **Authors:** {authors}
- **Year:** {year}
- **Source:** {source}
- **URL:** {url}
- **Abstract:** {abstract}
- **Relevance note:** <!-- fill manually -->

"""


def format_papers(papers: list[dict]) -> str:
    if not papers:
        return "_No results found. Check search strings or run manually._\n"
    return "".join(
        PAPER_TEMPLATE.format(
            index=i + 1,
            title=p["title"],
            authors=", ".join(p["authors"]) or "Unknown",
            year=p["year"],
            source=p["source"],
            url=p["url"],
            abstract=p["abstract"] or "_No abstract available._",
        )
        for i, p in enumerate(papers)
    )


def write_domain_file(domain_id: int, papers: list[dict], version: Optional[str] = None) -> None:
    if version:
        versioned_domains = get_versioned_paths(version)
        domain = versioned_domains[domain_id]
        path = domain["file"]
    else:
        domain = DOMAINS[domain_id]
        path = Path(domain["file"])
    
    path.parent.mkdir(parents=True, exist_ok=True)

    arxiv_q_list = "\n".join(f"- `{q}`" for q in domain["arxiv_queries"])
    s2_q_list = "\n".join(f"- `{q}`" for q in domain["semantic_scholar_queries"])

    heading = f"# Domain {domain_id} \u2014 {domain['name']}"
    if version:
        heading += f"\n\n> Version: {version}"

    content = DOMAIN_TEMPLATE.format(
        id=domain_id,
        name=domain["name"],
        date=date.today().isoformat(),
        query_count=len(domain["arxiv_queries"]) + len(domain["semantic_scholar_queries"]),
        arxiv_queries=arxiv_q_list,
        s2_queries=s2_q_list,
        count=len(papers),
        papers=format_papers(papers),
    )

    if version:
        content = content.replace(f"# Domain {domain_id} \u2014 {domain['name']}", heading, 1)
    
    path.write_text(content, encoding="utf-8")
    console.print(f"  [green]Written:[/green] {path} ({len(papers)} papers)")


# ── Gap Summary Writer ────────────────────────────────────────────────────────

GAP_SUMMARY_TEMPLATE = """\
# Gap Summary — Composable Future Foundational Audit

Generated: {date}
Status: IN PROGRESS — fill after reading all domain files

---

## Domain Gap Map

| Domain | Area | Gap Confirmed? | Confidence |
|--------|------|---------------|------------|
| 1 | Category Theory | TBD | — |
| 2 | Paradigm Change | TBD | — |
| 3 | Process Algebra | TBD | — |
| 4 | Affordance Theory | TBD | — |
| 5 | Futures Formalization | TBD | — |

---

## Composite Gap Statement

<!-- Fill after all domains are read.
     This becomes the opening paragraph of the positioning paper. -->

---

## Confirmed Priors (what to cite)

<!-- List the 8–12 papers that constitute the theoretical prior.
     These are papers that exist and that Composable Future builds on — not gaps. -->

---

## Open Problems Inventory

<!-- Transfer gap statements from each domain file here.
     These become the explicit open problems in the positioning paper. -->

1.
2.
3.
4.
5.

---

## Positioning Paper Readiness

- [ ] All 5 domain files synthesized
- [ ] Composite gap statement written
- [ ] Priors list finalized
- [ ] Open problems enumerated
- [ ] arXiv submission ready
"""


def write_gap_summary(version: Optional[str] = None) -> None:
    if version:
        path = Path(version) / "gap-summary.md"
        template = GAP_SUMMARY_TEMPLATE.replace("Gap Summary — Composable Future Foundational Audit", 
                                                 f"Gap Summary — Composable Future Foundational Audit ({version})")
    else:
        path = Path("audit/gap-summary.md")
        template = GAP_SUMMARY_TEMPLATE
    
    content = template.format(date=date.today().isoformat())
    path.write_text(content, encoding="utf-8")
    console.print(f"  [green]Written:[/green] {path}")


# ── Main ──────────────────────────────────────────────────────────────────────

def run_domain(domain_id: int, version: Optional[str] = None) -> None:
    if version:
        versioned_domains = get_versioned_paths(version)
        domain = versioned_domains[domain_id]
    else:
        domain = DOMAINS[domain_id]
    
    console.rule(f"[bold]Domain {domain_id} — {domain['name']}[/bold]")
    if version:
        console.print(f"[dim]Version: {version}[/dim]")
    all_papers: list[dict] = []

    with Progress(
        SpinnerColumn(),
        TextColumn("[progress.description]{task.description}"),
        console=console,
    ) as progress:

        # arXiv
        for query in domain["arxiv_queries"]:
            task = progress.add_task(f"arXiv: {query[:60]}...", total=None)
            results = search_arxiv(query)
            all_papers.extend(results)
            progress.update(task, description=f"arXiv: {query[:60]} [{len(results)} results]")
            time.sleep(3)  # arXiv rate limit

        # Semantic Scholar
        for query in domain["semantic_scholar_queries"]:
            task = progress.add_task(f"S2: {query[:60]}...", total=None)
            results = search_semantic_scholar(query)
            all_papers.extend(results)
            progress.update(task, description=f"S2: {query[:60]} [{len(results)} results]")
            time.sleep(1)  # S2 rate limit

    deduped = deduplicate(all_papers)
    console.print(f"  Raw: {len(all_papers)} → Deduplicated: {len(deduped)}")
    write_domain_file(domain_id, deduped, version)


def main() -> None:
    version, target = parse_args()
    
    if not version and not target:
        console.print("[red]Error:[/red] No arguments provided")
        console.print("Usage:")
        console.print("  uv run search.py --version audit-v2 [domain_id|all]")
        console.print("  uv run search.py --version audit-updates 3")
        sys.exit(1)

    console.print("\n[bold cyan]Composable Future — Foundational Audit Search[/bold cyan]\n")
    if version:
        console.print(f"[dim]Version: {version}[/dim]\n")

    if target == "all":
        for domain_id in DOMAINS:
            run_domain(domain_id, version)
        if version:
            write_gap_summary(version)
    elif target.isdigit() and int(target) in DOMAINS:
        run_domain(int(target), version)
    else:
        console.print(f"[red]Unknown target:[/red] {target}")
        console.print(f"Valid: all | {' | '.join(str(k) for k in DOMAINS)}")
        sys.exit(1)

    if version:
        console.print(f"\n[bold green]Done.[/bold green] Open {version}/ files and fill synthesis sections manually.\n")
    else:
        console.print("\n[bold green]Done.[/bold green] Open audit/ files and fill synthesis sections manually.\n")


if __name__ == "__main__":
    main()

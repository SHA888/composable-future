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
Composable Future — Audit Refinement
Merges additional queries and manual seeds into existing domain files.
Never overwrites existing content or relevance notes.

Usage:
    uv run refinement.py <domain_id>              # queries + seeds
    uv run refinement.py <domain_id> --seeds      # manual seeds only
    uv run refinement.py <domain_id> --queries    # refined queries only
    uv run refinement.py list                     # show all refinements defined
"""

import re
import sys
import time
import hashlib
from pathlib import Path
from datetime import date

import arxiv
import httpx
from rich.console import Console
from rich.table import Table
from rich.progress import Progress, SpinnerColumn, TextColumn

console = Console()

# ── Refinement Config ─────────────────────────────────────────────────────────
# Add new domains here as you identify gaps from the first search pass.

REFINEMENTS: dict[int, dict] = {
    1: {
        "additional_arxiv_queries": [],
        "additional_semantic_scholar_queries": [
            "applied category theory paradigm shift sociotechnical transition",
            "categorical model scientific knowledge change formalization",
        ],
        "manual_seeds": [],
    },
    2: {
        "additional_arxiv_queries": [
            "Gardenfors conceptual space geometric knowledge representation",
        ],
        "additional_semantic_scholar_queries": [
            "conceptual space geometry knowledge representation Gardenfors formalization",
            "catastrophe theory Thom morphogenesis paradigm formal",
        ],
        "manual_seeds": [],
    },
    3: {
        "additional_arxiv_queries": [],
        "additional_semantic_scholar_queries": [
            "process algebra application beyond software formal model",
        ],
        "manual_seeds": [],
    },
    4: {
        "additional_arxiv_queries": [
            "Gibson ecological affordance perception action formal",
            "affordance relational philosophical formal ontology",
        ],
        "additional_semantic_scholar_queries": [
            "Gibson ecological affordance perception action",
            "Chemero affordance relational theory",
            "affordance formalization philosophical ontology",
            "Turvey affordance prospective control ontology",
        ],
        "manual_seeds": [
            {
                "title": "An Outline of a Theory of Affordances",
                "authors": ["Anthony Chemero"],
                "year": 2003,
                "url": "https://doi.org/10.1207/S15326969ECO1502_4",
                "abstract": (
                    "Grounds affordances in relational ontology: affordances are relations "
                    "between the abilities of organisms and features of the environment, "
                    "not properties of either alone. Closest philosophical precursor to "
                    "formalizing Φ as a relational type."
                ),
                "source": "Manual seed",
            },
            {
                "title": "Affordances and Prospective Control: An Outline of the Ontology",
                "authors": ["Michael T. Turvey"],
                "year": 1992,
                "url": "https://doi.org/10.1207/s15326969eco0403_3",
                "abstract": (
                    "Develops a formal ontological account of affordances as dispositional "
                    "properties grounded in ecological dynamics and prospective control of "
                    "action. Relevant to defining Φ as a forward-directed typed structure."
                ),
                "source": "Manual seed",
            },
            {
                "title": "To Afford or Not to Afford: A New Formalization of Affordances Toward Affordance-Based Robot Control",
                "authors": ["Erol Şahin", "Maya Çakmak", "Mehmet R. Doğar", "Emre Uğur", "Göktürk Üçoluk"],
                "year": 2007,
                "url": "https://doi.org/10.1177/1059712307084689",
                "abstract": (
                    "Proposes a formal triple (entity, behavior, effect) definition of "
                    "affordances for robotics. Treats affordances as learnable, compositional "
                    "predicates. Most rigorous existing formalization — directly informs "
                    "how Φ can be typed and composed."
                ),
                "source": "Manual seed",
            },
            {
                "title": "A Formal Model of Affordances for Human-Computer Interaction",
                "authors": ["Leonidas Kyriakoullis", "Panayiotis Zaphiris"],
                "year": 2016,
                "url": "https://doi.org/10.1016/j.intcom.2016.01.001",
                "abstract": (
                    "Formalizes affordances in HCI: perceptual, functional, and cultural "
                    "affordances as typed predicates over user-interface state pairs. "
                    "Establishes that affordance types are domain-dependent — relevant to "
                    "the claim that Φ is paradigm-specific."
                ),
                "source": "Manual seed",
            },
        ],
    },
    5: {
        "additional_arxiv_queries": [],
        "additional_semantic_scholar_queries": [
            "branching time future contingents formal logic Iacona",
            "formal scenario generation exhaustive futures model",
        ],
        "manual_seeds": [],
    },
}

# ── Shared utils (duplicated from search.py to keep scripts independent) ──────

def _title_hash(title: str) -> str:
    normalized = "".join(title.lower().split())
    return hashlib.md5(normalized.encode()).hexdigest()


def deduplicate(papers: list[dict]) -> list[dict]:
    seen: set[str] = set()
    unique = []
    for p in papers:
        h = _title_hash(p["title"])
        if h not in seen:
            seen.add(h)
            unique.append(p)
    return unique


def search_arxiv(query: str, max_results: int = 8) -> list[dict]:
    client = arxiv.Client(page_size=max_results, delay_seconds=3.0, num_retries=3)
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
                "source": "arXiv (refinement)",
            })
    except Exception as e:
        console.print(f"  [yellow]arXiv warning:[/yellow] {e}")
    return results


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
                    else f"https://www.semanticscholar.org/paper/{p.get('paperId', '')}"
                )
                abstract = (p.get("abstract") or "")[:400].replace("\n", " ")
                results.append({
                    "title": p.get("title", "Untitled"),
                    "authors": [a["name"] for a in p.get("authors", [])[:4]],
                    "year": p.get("year", "?"),
                    "url": paper_url,
                    "abstract": abstract + ("..." if abstract else ""),
                    "source": "Semantic Scholar (refinement)",
                })
    except Exception as e:
        console.print(f"  [yellow]S2 warning:[/yellow] {e}")
    return results


# ── Markdown merge ────────────────────────────────────────────────────────────

def extract_known_hashes(filepath: Path) -> set[str]:
    """Parse existing domain file to get title hashes of already-listed papers."""
    if not filepath.exists():
        console.print(f"  [red]File not found:[/red] {filepath}")
        return set()
    content = filepath.read_text(encoding="utf-8")
    titles = re.findall(r"^### \d+\. (.+)$", content, re.MULTILINE)
    return {_title_hash(t) for t in titles}


def extract_current_count(content: str) -> int:
    m = re.search(r"## Results \((\d+) papers\)", content)
    return int(m.group(1)) if m else 0


PAPER_TEMPLATE = """\
### {index}. {title}
- **Authors:** {authors}
- **Year:** {year}
- **Source:** {source}
- **URL:** {url}
- **Abstract:** {abstract}
- **Relevance note:** <!-- fill manually -->

"""


def format_new_papers(papers: list[dict], start_index: int) -> str:
    return "".join(
        PAPER_TEMPLATE.format(
            index=start_index + i,
            title=p["title"],
            authors=", ".join(p["authors"]) or "Unknown",
            year=p["year"],
            source=p["source"],
            url=p["url"],
            abstract=p["abstract"] or "_No abstract available._",
        )
        for i, p in enumerate(papers)
    )


def merge_into_file(filepath: Path, new_papers: list[dict], tag: str) -> None:
    """Append new papers to existing domain file without touching existing content."""
    content = filepath.read_text(encoding="utf-8")
    current_count = extract_current_count(content)
    new_count = current_count + len(new_papers)

    # Update paper count line
    content = re.sub(
        r"## Results \(\d+ papers\)",
        f"## Results ({new_count} papers)",
        content,
    )

    # Find insertion point: just before the `---\n\n## Synthesis` block
    synthesis_marker = "\n---\n\n## Synthesis"
    insert_at = content.find(synthesis_marker)
    if insert_at == -1:
        # Fallback: append at end
        insert_at = len(content)

    # Build refinement block
    block = (
        f"\n\n<!-- Refinement added {date.today().isoformat()} — {tag} -->\n\n"
        + format_new_papers(new_papers, start_index=current_count + 1)
    )

    content = content[:insert_at] + block + content[insert_at:]
    filepath.write_text(content, encoding="utf-8")


# ── Core logic ────────────────────────────────────────────────────────────────

def get_domain_file(domain_id: int) -> Path:
    files = {
        1: "audit/domain-1-category-theory.md",
        2: "audit/domain-2-paradigm-change.md",
        3: "audit/domain-3-process-algebra.md",
        4: "audit/domain-4-affordance-theory.md",
        5: "audit/domain-5-futures-formalization.md",
    }
    return Path(files[domain_id])


def run_refinement(domain_id: int, do_queries: bool = True, do_seeds: bool = True) -> None:
    if domain_id not in REFINEMENTS:
        console.print(f"[red]No refinement config for domain {domain_id}[/red]")
        return

    ref = REFINEMENTS[domain_id]
    filepath = get_domain_file(domain_id)

    if not filepath.exists():
        console.print(f"[red]Domain file not found:[/red] {filepath}")
        console.print("Run search.py first to generate the base file.")
        return

    console.rule(f"[bold]Refining Domain {domain_id}[/bold]")
    known_hashes = extract_known_hashes(filepath)
    console.print(f"  Existing papers: {len(known_hashes)}")

    all_new: list[dict] = []

    # ── Refined queries ───────────────────────────────────────────────────────
    if do_queries:
        arXiv_queries = ref.get("additional_arxiv_queries", [])
        s2_queries = ref.get("additional_semantic_scholar_queries", [])

        if not arXiv_queries and not s2_queries:
            console.print("  [dim]No additional queries defined for this domain.[/dim]")
        else:
            with Progress(
                SpinnerColumn(),
                TextColumn("[progress.description]{task.description}"),
                console=console,
            ) as progress:
                for query in arXiv_queries:
                    task = progress.add_task(f"arXiv: {query[:55]}...", total=None)
                    results = search_arxiv(query)
                    all_new.extend(results)
                    progress.update(task, description=f"arXiv: {query[:55]} [{len(results)}]")
                    time.sleep(3)

                for query in s2_queries:
                    task = progress.add_task(f"S2: {query[:55]}...", total=None)
                    results = search_semantic_scholar(query)
                    all_new.extend(results)
                    progress.update(task, description=f"S2: {query[:55]} [{len(results)}]")
                    time.sleep(1)

    # ── Manual seeds ──────────────────────────────────────────────────────────
    if do_seeds:
        seeds = ref.get("manual_seeds", [])
        if seeds:
            console.print(f"  Adding {len(seeds)} manual seed(s)")
            all_new.extend(seeds)
        else:
            console.print("  [dim]No manual seeds defined for this domain.[/dim]")

    if not all_new:
        console.print("  [yellow]Nothing to add.[/yellow]")
        return

    # Deduplicate within new batch
    all_new = deduplicate(all_new)

    # Filter against already-known papers
    truly_new = [p for p in all_new if _title_hash(p["title"]) not in known_hashes]
    skipped = len(all_new) - len(truly_new)

    console.print(
        f"  Found: {len(all_new)} | Already present: {skipped} | New: {len(truly_new)}"
    )

    if not truly_new:
        console.print("  [green]No new papers to add — file already up to date.[/green]")
        return

    tag = " + ".join(filter(None, [
        "queries" if do_queries else "",
        "seeds" if do_seeds else "",
    ]))
    merge_into_file(filepath, truly_new, tag)
    console.print(f"  [green]Merged {len(truly_new)} new paper(s) into {filepath}[/green]")


def list_refinements() -> None:
    table = Table(title="Defined Refinements", show_lines=True)
    table.add_column("Domain", style="cyan")
    table.add_column("Additional arXiv queries")
    table.add_column("Additional S2 queries")
    table.add_column("Manual seeds")

    for domain_id, ref in REFINEMENTS.items():
        table.add_row(
            str(domain_id),
            str(len(ref.get("additional_arxiv_queries", []))),
            str(len(ref.get("additional_semantic_scholar_queries", []))),
            str(len(ref.get("manual_seeds", []))),
        )
    console.print(table)


# ── CLI ───────────────────────────────────────────────────────────────────────

def main() -> None:
    args = sys.argv[1:]

    if not args or args[0] == "list":
        list_refinements()
        return

    domain_str = args[0]
    flags = set(args[1:])

    if not domain_str.isdigit():
        console.print(f"[red]Expected domain id (integer) or 'list', got:[/red] {domain_str}")
        sys.exit(1)

    domain_id = int(domain_str)

    do_queries = "--queries" in flags or "--seeds" not in flags
    do_seeds = "--seeds" in flags or "--queries" not in flags

    console.print(f"\n[bold cyan]Composable Future — Audit Refinement[/bold cyan]")
    console.print(f"Domain: {domain_id} | Queries: {do_queries} | Seeds: {do_seeds}\n")

    run_refinement(domain_id, do_queries=do_queries, do_seeds=do_seeds)

    console.print("\n[bold green]Done.[/bold green] Fill in relevance notes in the updated domain file.\n")


if __name__ == "__main__":
    main()

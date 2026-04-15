# Contributing to Composable Future

This document provides guidelines for contributing to the Composable Future project, which combines theoretical work on paradigmatic transitions with formal verification in Lean 4.

## Overview

The project has two main contribution tracks:
1. **Audit Track**: Literature review and gap analysis
2. **Formalization Track**: Lean 4 proofs and mechanization

## Audit Track Contributions

### Running Audit Scripts

**⚠️ IMPORTANT**: Phase 0 audit synthesis is COMPLETE. Do not run audit scripts as they will overwrite the manually filled synthesis sections.

The audit tooling is documented for reference and potential Phase 5 extensions, but should NOT be run on the main domain files.

If you need to extend the audit (e.g., for new domains or updated literature):
1. Create a new branch
2. Work in a separate directory (e.g., `audit-v2/`)
3. Do not modify the existing `audit/` directory

The current audit files contain completed manual synthesis that should be preserved.

### Working with Existing Audit Files

The audit synthesis in `audit/domain-N-*.md` files is **COMPLETE**. These files contain:

- ✅ Manual synthesis sections filled based on targeted reading
- ✅ Gap statements confirmed across all 5 domains  
- ✅ Key question answers with literature citations
- ✅ Confidence assessments and open problem mapping

**Do NOT modify these files** unless you have a specific reason to update the synthesis based on new literature.

### Extending the Audit (Future Work)

If you want to contribute to audit expansion (Phase 5+):

1. **New Domains**: Create additional domain files (e.g., `domain-6-*.md`)
2. **Literature Updates**: Work in a separate directory like `audit-updates/`
3. **Cross-disciplinary Connections**: Add bridge analyses between existing domains

Always preserve the completed Phase 0 synthesis as the foundation.

## Formalization Track Contributions

### Python Setup (for audit tooling)

The audit scripts require Python 3.12+ and `uv`:

```bash
# Install dependencies
uv sync

# Or with pip
pip install -e .
```

### Lean 4 Setup

**Linux / macOS**
```bash
curl -sSf https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh | sh
source ~/.bashrc   # or restart terminal — adds ~/.elan/bin to PATH
```

**Windows**
Download and run the installer from https://github.com/leanprover/elan/releases  
(adds `lake` to PATH automatically via the installer)

**All platforms — build the project**
```bash
cd lean
lake update   # fetch dependencies (one-time)
lake build
```

> **Note:** elan manages Lean toolchain versions. The correct Lean version is pinned in `lean/lean-toolchain` and will be downloaded automatically on first `lake build`.

### Proof Development Guidelines

#### Naming Conventions
- Types: `PascalCase` (e.g., `ParadigmaticState`)
- Functions: `camelCase` (e.g., `seqBind`)
- Theorems: `snake_case` (e.g., `left_identity`)
- Namespaces: `PascalCase` (e.g., `ComposableFuture`)

#### Sorry Policy
- Use `sorry` only for genuinely unproved statements
- Each `sorry` must have a comment explaining:
  - What needs to be proved
  - Which open problem it corresponds to (OP1-OP5)
  - Current approach or obstacle

#### File Organization
- `Core/Future.lean`: Basic type definitions
- `Core/Operators.lean`: Operator definitions with minimal sorry
- `Core/Laws.lean`: Identity, closure axioms
- `Core/Stateless.lean`: Stateless case formalization and associativity proof (Phase 2.2)
- `Core/Indexed.lean`: Indexed/graded monad construction for general case (Phase 2.3)
- `Core/WeakAssoc.lean`: Weak associativity theorems for path-dependent case (Phase 2.3)
- `Core/Probabilistic.lean`: Kleisli extension for probabilistic trajectories (Phase 3)

### Proof Attempts

Document all proof work in the `proofs/` directory:

#### `proofs/notes.md`
- Current understanding of each open problem
- Partial results and conjectures
- Next steps for each problem

#### `proofs/stateless-case.md`
- Analysis of restricted domain where τ is stateless
- Formal definition attempts
- Proof sketches for associativity in this case

#### `proofs/attempt-associativity.md`
- Failed proof attempts with detailed analysis
- Obstructions identified
- Alternative approaches considered

## Code Style

### Lean Code
```lean
/-- Brief description of the definition -/
theorem theorem_name (params) : conclusion :=
  by
    -- proof steps
    sorry
```

### Markdown Files
- Use ATX headings (`#`, `##`, `###`)
- Code blocks with language specification
- Internal links: `[text](#section-heading)`
- External links with proper formatting

## Review Process

### Audit Contributions
1. Verify search results are current
2. Check synthesis sections accurately reflect literature
3. Ensure gap statements are precise and well-supported
4. Validate that open problems are correctly mapped

### Formalization Contributions
1. Run `lake build` to ensure code compiles
2. Check that all sorry have explanatory comments
3. Verify naming conventions are followed
4. Test that proofs don't introduce circular dependencies

## Submitting Contributions

### Small Changes
- Use the GitHub web interface for minor edits
- Include clear commit messages
- Reference relevant issues or TODO items

### Larger Changes
1. Fork the repository
2. Create a feature branch
3. Make changes with atomic commits
4. Ensure all tests pass (`lake build`)
5. Submit a pull request with:
   - Clear description of changes
   - How they address specific TODO items
   - Any open questions or limitations

## Getting Help

### Questions About Theory
- Check existing audit files for context
- Review `proofs/notes.md` for current understanding
- Open an issue with specific theoretical questions

### Questions About Formalization
- Consult Lean 4 documentation
- Check Mathlib for similar constructions
- Open issues with Lean code examples

### Tooling Issues
- Verify uv and Lean installations
- Check that all dependencies are current
- Report bugs with error messages and system info

## Community Guidelines

- Be constructive in feedback
- Acknowledge the interdisciplinary nature of the work
- Respect both theoretical and formalization expertise
- Help maintain the connection between audit findings and formalization
- Document insights that bridge the gap between domains

## Recognition

Contributors will be acknowledged in:
- README.md contributors section
- Formal publications based on the work
- Zenodo archive versions
- Conference presentations (if applicable)

Thank you for contributing to the Composable Future project!

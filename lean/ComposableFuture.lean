import ComposableFuture.Core.Future
import ComposableFuture.Core.Operators
import ComposableFuture.Core.Laws
import ComposableFuture.Core.Stateless
import ComposableFuture.Core.Indexed
import ComposableFuture.Core.WeakAssoc
import ComposableFuture.Core.Probabilistic
import ComposableFuture.Core.Affordance
import ComposableFuture.Core.Effect

/-!
# Composable Future Theory

This module contains the formalization of the Composable Future theory in Lean 4.
The theory defines composable futures as 4-tuples F = (S₀, τ, S₁, Φ) where:
- S₀, S₁ are paradigmatic states
- τ is a trajectory from S₀ to S₁  
- Φ is an affordance set over S₁

The main components are:
- Core.Future: Basic type definitions
- Core.Operators: Sequential, parallel, and branching operators
- Core.Laws: Identity, closure, and associativity laws
- Core.Stateless: Stateless case formalization and category theory mapping
- Core.Indexed: Indexed/graded monad construction for general case (Orchard, Petricek, Mycroft 2014; Orchard, Wadler, Eades 2020)
- Core.WeakAssoc: Weak associativity theorems for path-dependent case
- Core.Probabilistic: Kleisli extension for probabilistic trajectories
- Core.Affordance: Φ as dependent type, affordance composition (Phase 4)

## Note on Open Problem Numbering

The Lean code uses internal OP numbering (proofs/notes.md):
- OP1-OP12: Core definitions and laws
- OP13-OP16: Probabilistic extension
- OP17: Indexed monad identity affordance

This differs from the paper's §7 OP numbering (gap-summary.md):
- OP1 = Associativity (resolved via indexed monad)
- OP2 = Φ well-definedness, OP3 = Equivalence, etc.

The mapping is documented in proofs/notes.md under each open problem.
-/

namespace ComposableFuture

end ComposableFuture

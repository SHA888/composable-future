import ComposableFuture.Core.Future
import ComposableFuture.Core.Operators
import ComposableFuture.Core.Laws
import ComposableFuture.Core.Probabilistic

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
- Core.Probabilistic: Kleisli extension for probabilistic trajectories
-/

namespace ComposableFuture

end ComposableFuture

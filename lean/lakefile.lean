import Lake
open Lake DSL

package «composable-future» {
  -- add package configuration options here
}

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"@"v4.12.0"

@[default_target]
lean_lib «ComposableFuture» {
  -- add any library configuration options here
}

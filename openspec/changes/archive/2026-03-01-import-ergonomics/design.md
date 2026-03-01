## Context

The project uses `bartering.v1` as the protobuf package, which generates Go package `barteringv1` and Connect subpackage `barteringv1connect`. Every Go file that handles RPCs imports both and prefixes every type reference with these 12–18 character names. Currently only three files use them (`main.go`, `health.go`, `health_test.go`), but as services grow (trades, users, vault, library sync), the verbosity compounds. On the frontend, TypeScript destructured imports avoid the prefix problem, but relative paths like `../../../gen/bartering/v1/health_pb.js` will deepen as the route tree grows.

The proto package name itself (`bartering.v1`) is correct — it's the wire identity, follows Buf conventions, and should not change. The issue is purely how consuming code references generated types.

## Goals / Non-Goals

**Goals:**
- Establish `pb` and `rpc` as the standard Go import aliases for `barteringv1` and `barteringv1connect` across all existing and future Go files
- Add a `$gen` SvelteKit path alias so frontend imports use `$gen/bartering/v1/...` instead of relative paths
- Update all existing Go source files and frontend imports to use the new conventions

**Non-Goals:**
- Renaming the proto package, Go module path, Buf module, or database names
- Changing any wire-format behavior — all HTTP paths, service names, and protocol details remain identical
- Refactoring handler logic or test structure — this is purely an import cosmetic change
- Adding linter rules to enforce alias conventions (can follow up later)

## Decisions

### 1. Alias `barteringv1` as `pb` in Go imports

```go
// Before
barteringv1 "github.com/jack-fin/bartering-games/backend/gen/bartering/v1"

// After
pb "github.com/jack-fin/bartering-games/backend/gen/bartering/v1"
```

`pb` is the dominant convention in the Go protobuf ecosystem. Google's own examples, the `protocolbuffers/go` repo, and most Connect-Go projects use `pb` as the alias for generated protobuf packages. It's short, universally recognized, and unambiguous — when a Go developer sees `pb.SomeType`, they know it's a protobuf message.

**Alternative considered:** A domain-specific alias like `bv1` or `barter`. These save fewer characters than `pb` and aren't recognizable conventions. A Go developer new to the project would have to look up what `bv1` means. `pb` is self-documenting.

### 2. Alias `barteringv1connect` as `rpc` in Go imports

```go
// Before
"github.com/jack-fin/bartering-games/backend/gen/bartering/v1/barteringv1connect"

// After
rpc "github.com/jack-fin/bartering-games/backend/gen/bartering/v1/barteringv1connect"
```

The connect package provides RPC service interfaces, client constructors, and handler constructors. `rpc` captures this role clearly. It's not as universally standardized as `pb`, but it's short and descriptive. The Connect-Go docs themselves sometimes use `<service>connect` as the alias, but that only works when there's one service in scope.

**Alternative considered:** `connect` as the alias — conflicts with the `connectrpc.com/connect` package which is also imported in handler files. `svc` — too generic, doesn't convey the RPC/generated nature. Keeping the full `barteringv1connect` — defeats the purpose.

### 3. Add `$gen` path alias in SvelteKit

```javascript
// svelte.config.js
kit: {
    adapter: adapter(),
    alias: {
        "$gen": "./gen",
        "$gen/*": "./gen/*"
    }
}
```

This follows SvelteKit's own `$lib` convention for path aliases. Frontend imports become:

```typescript
// Before
import { HealthService } from "../../../gen/bartering/v1/health_pb.js";

// After
import { HealthService } from "$gen/bartering/v1/health_pb.js";
```

The `$gen` prefix signals "this is auto-generated code" at a glance, which is useful context when reading imports. The alias is stable regardless of how deep the importing file is in the route tree.

**Alternative considered:** Moving generated code into `src/lib/gen/` so it falls under the existing `$lib` alias. This would work but muddies the boundary — `$lib` is hand-written library code, `$gen` is machine output. Keeping them conceptually separate is cleaner.

### 4. Apply to all existing files, establish as convention

The three Go files (`main.go`, `health.go`, `health_test.go`) and one TypeScript file (`api/index.ts`) all get updated. This isn't a "going forward" convention — it's applied immediately and consistently so there's no mixed-style codebase.

Future handler and test files should follow the same pattern. We're not adding a linter rule for this now (non-goal), but the existing files serve as the template.

## Risks / Trade-offs

- **`pb` collision if multiple proto packages are imported** → In the current architecture, all protos live under one package (`bartering.v1`). If a second package is ever introduced (e.g., a third-party proto dependency), the second package would need a qualified alias like `extpb`. This is the standard Go approach and doesn't invalidate using `pb` for our own types.
- **`rpc` collision with future package names** → Unlikely in practice. If it ever conflicts, the convention can evolve. The alias is a one-line change per file.
- **SvelteKit `$gen` alias not recognized by external tools** → Some editors/tools may not resolve `$gen` out of the box. SvelteKit generates the TypeScript path mappings automatically into `.svelte-kit/tsconfig.json` which `tsconfig.json` extends, so VS Code and `tsc` pick it up. This is the same mechanism `$lib` uses.

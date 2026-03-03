## Why

The architecture uses SvelteKit + Connect RPC to provide a type-safe API contract between Go and TypeScript. After fully scoping the application — particularly the WebCrypto vault and trading system — this creates unnecessary complexity: two runtimes, two Docker images, a protobuf code generation pipeline, an nginx sidecar, and a dedicated CI test job for a frontend that barely exists. The Connect-TS client existed solely to give TypeScript type-safe access to Go handlers; without it the entire proto generation chain solves a problem that no longer exists. The only genuine browser requirement is the WebCrypto vault (AES-256-GCM, PBKDF2, RSA-OAEP escrow) — a pure JS concern with zero framework dependencies that can be extracted as a small standalone TypeScript module compiled by esbuild.

## What Changes

- **Remove** SvelteKit frontend (`frontend/`) — replace with Go templ components for server-side HTML rendering
- **Remove** Connect RPC + protobuf toolchain (`proto/`, `backend/gen/`) — replace with plain Chi HTTP handlers returning HTML (templ) or JSON
- **Remove** nginx Docker image — Go binary serves HTML and static assets directly
- **Add** `vault-js/` standalone TypeScript module (esbuild -> `backend/static/vault.js`) for client-side WebCrypto encryption
- **Add** HTMX with `hx-boost` + `head-support` extension for SPA-like navigation that preserves vault key in JS memory across page transitions
- **Add** vault form interception: vault JS intercepts HTMX form submits, runs WebCrypto, stuffs results into hidden inputs — no `fetch()` in vault JS
- **Update** CI pipeline: remove pnpm/frontend, proto/buf steps; add vault-js test job; update codegen verification; simplify lint PR comment

## Capabilities

### New Capabilities
- `templ-server`: Go templ server-side HTML rendering with HTMX integration — layouts, pages, and partials rendered by the Go server
- `vault-js`: Standalone TypeScript WebCrypto module compiled by esbuild — AES-256-GCM key encryption, PBKDF2 key derivation, RSA-OAEP escrow, HTMX form interception — zero runtime dependencies

### Modified Capabilities
- `http-server`: Connect RPC mounts replaced with plain `net/http` handlers on Chi; server now renders templ HTML and serves static assets
- `docker-images`: Two-image setup (Go distroless + nginx) replaced with single Go distroless image that serves everything
- `task-runner`: Remove pnpm/frontend/proto tasks; add `generate:templ` and `build:vault` tasks
- `ci-pipeline`: Remove frontend test job and proto lint/breaking/codegen jobs; add vault-js test job; simplify lint PR comment; update codegen verification for templ + sqlc only

### Removed Capabilities
- `sveltekit-app`: SvelteKit + Svelte 5 + TypeScript frontend — entirely removed
- `connect-ts-client`: Generated TypeScript Connect RPC client — no longer needed
- `connect-go-wiring`: Connect-go server handler wiring — replaced by plain Chi handlers
- `protobuf-toolchain`: buf generate pipeline — no longer needed without Connect
- `proto-shared-types`: Shared protobuf message types (pagination, etc.) — replaced by Go structs
- `health-rpc`: Connect RPC health check — replaced by plain HTTP `/healthz` endpoint (already exists as a Chi route)

## Impact

- **Deleted directories**: `frontend/`, `proto/`, `backend/gen/`
- **New directories**: `vault-js/`, `backend/internal/components/`, `backend/static/`
- **Modified files**: `backend/cmd/server/main.go`, `Taskfile.yaml`, `backend/go.mod`, `backend/Dockerfile`, `docker-compose.yaml`, `.github/workflows/ci.yml`
- **New dependencies**: `github.com/a-h/templ` (Go), `esbuild` + `typescript` (dev, vault-js build)
- **Removed dependencies**: `connectrpc.com/connect`, `google.golang.org/protobuf`, all `@connectrpc/*` and `@bufbuild/*` npm packages, `buf` CLI, `pnpm`, `nginx`
- **No database changes** — schema.hcl, migrations, and sqlc are untouched
- **Documentation updates**: `CLAUDE.md` and `.claude/rules/` reference the current stack (SvelteKit, Connect RPC, protobuf, pnpm, buf, nginx) throughout — tech stack, repository structure, build commands, test commands, conventions, and path-scoped rules all need updating to reflect templ + HTMX + vault-js

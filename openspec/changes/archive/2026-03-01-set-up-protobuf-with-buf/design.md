## Context

The project has a monorepo with a Go backend (Chi router) and SvelteKit frontend, but no API contract layer. The `proto/bartering/v1/` directory exists with only a `.gitkeep`. The Taskfile has stub tasks for `generate:proto` and `lint:proto`. The backend currently serves plain HTTP health endpoints at `/healthz` and `/readyz`. No protobuf tooling, dependencies, or generated code exists yet.

Buf is the chosen protobuf toolchain (per CLAUDE.md). Connect-RPC is the chosen RPC framework — it produces idiomatic HTTP handlers for Go and browser-compatible clients for TypeScript, all from a single `.proto` source.

## Goals / Non-Goals

**Goals:**
- Establish the Buf module configuration so that any developer can run `buf generate` and `buf lint` from the repo.
- Produce generated Go code in `backend/gen/` and TypeScript code in `frontend/gen/`.
- Define shared proto types (common.proto) that future services will import.
- Provide a minimal health RPC service as an end-to-end smoke test of the generation pipeline.
- Wire `generate:proto` and `lint:proto` Taskfile tasks to real commands.

**Non-Goals:**
- Wiring the generated HealthService into the Chi server (separate story).
- Setting up a Connect client in the SvelteKit app.
- CI installation of `buf` (can be added to CI separately).
- gRPC-specific concerns — Connect uses HTTP/1.1+JSON by default in browsers.

## Decisions

### 1. Buf v2 configuration format

Use the Buf v2 config format (`buf.yaml` with `version: v2`). V2 uses `modules` instead of `name` and supports `buf.lock` for dependency pinning. The proto directory serves as both the Buf workspace root and module root.

**Alternatives considered:**
- Buf v1 config: Still works but deprecated. V2 is the current standard and what `buf mod init` generates.
- Buf workspace (`buf.work.yaml`): Not needed — we have a single module in `proto/`.

### 2. Plugin configuration in `buf.gen.yaml`

Use remote Buf plugins (e.g., `buf.build/protocolbuffers/go`) rather than locally-installed `protoc` plugins. This eliminates the need to install `protoc-gen-go`, `protoc-gen-connect-go`, etc. locally — `buf generate` handles plugin resolution.

Plugins and output targets:
| Plugin | Output | Purpose |
|--------|--------|---------|
| `buf.build/protocolbuffers/go` | `backend/gen` | Go protobuf types |
| `buf.build/connectrpc/go` | `backend/gen` | Go Connect service interfaces |
| `buf.build/bufbuild/es` | `frontend/gen` | TypeScript protobuf types |
| `buf.build/connectrpc/es` | `frontend/gen` | TypeScript Connect service clients |

**Alternatives considered:**
- Local protoc plugins: Requires each developer to install matching plugin versions. Buf remote plugins are version-pinned and reproducible.
- `protoc` directly: Buf wraps protoc and adds linting, breaking change detection, and dependency management. No reason to use raw protoc.

### 3. Proto package naming: `bartering.v1`

All protos live under `bartering/v1/` with package `bartering.v1`. This matches the directory structure convention per Buf's `DIRECTORY_SAME_PACKAGE` lint rule. The `v1` suffix supports future breaking API versions (`v2`, etc.) without reorganizing existing protos.

### 4. Common types in `common.proto`

Define shared messages in `common.proto` rather than inlining them in each service proto. This avoids duplication and ensures consistent pagination, timestamp handling, etc. across services.

Initial types:
- `PaginationRequest` (page_token, page_size)
- `PaginationResponse` (next_page_token, total_count)

Keep it minimal — add types as they're needed by real services, not speculatively.

### 5. Health service design

A simple unary RPC with `CheckRequest` (empty) → `CheckResponse` (status enum: SERVING, NOT_SERVING). This follows the pattern from `grpc.health.v1` but is our own definition under `bartering.v1`, keeping the dependency tree simple.

This service exists primarily to validate the generation pipeline end-to-end. Wiring it into the server is a follow-up story.

### 6. Generated code committed to Git

Per project conventions (CLAUDE.md), generated code in `backend/gen/` and `frontend/gen/` is committed. CI validates freshness by running `buf generate` and checking for a clean `git diff`.

### 7. Buf lint rules

Use Buf's `DEFAULT` lint category, which includes `DIRECTORY_SAME_PACKAGE`, `PACKAGE_VERSION_SUFFIX`, `FIELD_LOWER_SNAKE_CASE`, `ENUM_VALUE_PREFIX`, and others. This is industry-standard and catches common proto style issues.

### 8. Taskfile wiring

- `generate:proto`: Run `buf generate` from the `proto/` directory.
- `lint:proto`: Run `buf lint` from the `proto/` directory.

Both tasks use `dir: proto` to set the working directory.

## Risks / Trade-offs

- **Buf CLI not installed** → `buf generate` and `buf lint` will fail for developers without it. Mitigation: Document installation in the README (future story) and add to CI setup.
- **Remote plugin version drift** → If Buf updates remote plugin defaults, regenerated code could change unexpectedly. Mitigation: Pin plugin versions in `buf.gen.yaml` using `revision` fields once available, or lock via `buf.lock`.
- **Generated code conflicts in PRs** → Multiple branches modifying `.proto` files can produce merge conflicts in generated code. Mitigation: CI freshness check ensures generated code stays in sync; conflicts are resolved by re-running `buf generate` after merge.

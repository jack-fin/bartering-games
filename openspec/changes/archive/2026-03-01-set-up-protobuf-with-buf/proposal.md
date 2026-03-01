## Why

The project needs a typed API contract layer before any real feature work can begin. Protobuf + Buf + Connect provides end-to-end type safety from `.proto` definitions through Go handlers and TypeScript clients, replacing the current stub health endpoint with a generated RPC framework. Without this, every future story (auth, trades, inventory) would need to solve serialization and API contracts ad hoc.

## What Changes

- Add `buf.yaml` and `buf.gen.yaml` to `proto/` to configure the Buf module, lint rules, and code generation plugins for Go (protocolbuffers/go, connectrpc/go) and TypeScript (bufbuild/es, connectrpc/es).
- Create `proto/bartering/v1/common.proto` with shared types (timestamps, pagination request/response, etc.) used across future services.
- Create `proto/bartering/v1/health.proto` defining a minimal `HealthService` with a `Check` RPC as a smoke test for the full generation pipeline.
- Run `buf generate` to produce Go code in `backend/gen/` and TypeScript code in `frontend/gen/`, and commit the output per project conventions.
- Add required Go dependencies (`connectrpc.com/connect`, `google.golang.org/protobuf`) to `backend/go.mod`.
- Add required TypeScript dependencies (`@connectrpc/connect`, `@connectrpc/connect-web`, `@bufbuild/protobuf`) to `frontend/package.json`.
- Wire the `generate:proto` Taskfile task to run `buf generate` instead of printing a stub message.
- Wire the `lint:proto` Taskfile task to run `buf lint` instead of printing a stub message.

## Capabilities

### New Capabilities
- `protobuf-toolchain`: Buf module configuration, code generation pipeline, and proto linting for the project.
- `proto-shared-types`: Common protobuf message types (timestamps, pagination) shared across all services.
- `health-rpc`: A Connect-RPC HealthService definition and generated code, serving as the smoke test for the protobuf pipeline.

### Modified Capabilities
- `task-runner`: The `generate:proto` and `lint:proto` tasks change from stubs to real commands.

## Impact

- **New files**: `proto/buf.yaml`, `proto/buf.gen.yaml`, `proto/bartering/v1/common.proto`, `proto/bartering/v1/health.proto`, generated code in `backend/gen/` and `frontend/gen/`.
- **Modified files**: `backend/go.mod`, `backend/go.sum`, `frontend/package.json`, `frontend/pnpm-lock.yaml`, `Taskfile.yaml`.
- **New dev dependencies**: `buf` CLI must be installed locally (and in CI). Go and TypeScript protobuf runtime libraries added.
- **No breaking changes**: The existing HTTP health endpoints (`/healthz`, `/readyz`) are unaffected. The new `HealthService` RPC is additive. Wiring it into the Chi server is a separate story.

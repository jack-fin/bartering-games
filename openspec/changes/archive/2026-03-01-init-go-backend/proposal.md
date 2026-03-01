## Why

The backend directory structure exists but contains no Go code. We need to initialize the Go module, install core dependencies, and stand up a minimal running server so that subsequent stories (Connect RPC handlers, database integration, auth) have a working foundation to build on.

## What Changes

- Initialize `go.mod` with Go 1.26 for `github.com/jack-flores/bartering-games/backend`
- Add `go-chi/chi/v5` and `go-chi/cors` as dependencies
- Create `cmd/server/main.go` with:
  - Chi router with standard middleware (Logger, Recoverer, RealIP, Compress)
  - CORS middleware (configurable origins)
  - `GET /healthz` returning 200 (liveness)
  - `GET /readyz` returning 200 (readiness, placeholder for future DB/worker checks)
  - Graceful shutdown on SIGTERM/SIGINT
- Structured logging via `slog` (JSON in production, text in dev)
- Configuration from environment variables: `PORT`, `LOG_LEVEL`
- Update `Taskfile.yaml` with Go-specific tasks (`task dev:backend`, `task test:go`, `task lint:go`)

## Capabilities

### New Capabilities
- `http-server`: Core HTTP server setup — Chi router, middleware stack, health endpoints, graceful shutdown, structured logging, and environment-based configuration.

### Modified Capabilities
- `task-runner`: Adding Go-specific task definitions for dev, test, and lint workflows.

## Impact

- **New files**: `backend/go.mod`, `backend/go.sum`, `backend/cmd/server/main.go`
- **Modified files**: `Taskfile.yaml`
- **Dependencies added**: `go-chi/chi/v5`, `go-chi/cors`
- **No breaking changes** — this is greenfield initialization

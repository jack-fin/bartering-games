## Context

The monorepo scaffold (sc-40) created the `backend/` directory tree with empty subdirectories (`cmd/server/`, `internal/`, `migrations/`, `gen/`). There is no `go.mod`, no Go source files, and no runnable server. This change initializes the Go module and creates a minimal but production-shaped HTTP server that future stories will extend with Connect RPC handlers, database connections, and background workers.

## Goals / Non-Goals

**Goals:**
- A compilable, runnable Go backend that serves health endpoints
- Production-ready middleware stack (logging, recovery, compression, CORS)
- Structured logging with environment-aware output format
- Environment-based configuration (no config files)
- Graceful shutdown on signals
- Taskfile wired to real Go commands (replacing stubs)

**Non-Goals:**
- Database connectivity (future story)
- Connect RPC / protobuf handler registration (future story)
- Authentication or sessions (future story)
- Docker image / Dockerfile (future story)
- Background workers (future story)
- Real readiness checks (readyz returns 200 unconditionally for now)

## Decisions

### 1. Module path: `github.com/jack-flores/bartering-games/backend`

Standard Go convention for a monorepo subdirectory. Uses the GitHub org/repo path. The `/backend` suffix scopes the module to this directory.

### 2. Configuration via environment variables only

Using `os.Getenv` with sensible defaults — no config library needed at this stage. Variables:
- `PORT` (default: `8080`)
- `LOG_LEVEL` (default: `info`)

`DATABASE_URL` is listed in the Shortcut story but won't be used yet since there's no database integration. We'll omit it to avoid dead config — it gets added when the database story lands.

**Alternative considered**: Using a config library like `envconfig` or `viper`. Unnecessary complexity for three variables. Revisit when config grows.

### 3. `slog` for structured logging (stdlib)

Go 1.21+ ships `log/slog` in the standard library. No third-party dependency needed. JSON handler for production (`LOG_LEVEL != "debug"`), text handler for development. This aligns with the project convention of minimizing dependencies.

### 4. Chi router with middleware ordering

Middleware applied in this order:
1. `middleware.RealIP` — extract real client IP from proxy headers (must be first for accurate logging)
2. `middleware.Logger` — request/response logging (uses `slog` by default in chi v5)
3. `middleware.Recoverer` — panic recovery to 500 response
4. `middleware.Compress(5)` — gzip compression at level 5 (balanced speed/ratio)
5. `cors.Handler(...)` — CORS with configurable allowed origins

Health endpoints (`/healthz`, `/readyz`) are registered after middleware so they get logging and recovery but this is fine for health checks.

### 5. Graceful shutdown with `signal.NotifyContext`

Using `signal.NotifyContext` (Go 1.16+) to create a context canceled on SIGTERM or SIGINT. The HTTP server gets a 10-second shutdown timeout for draining in-flight requests. This is the standard Go pattern for production servers behind a load balancer.

### 6. Taskfile: wire real commands, keep stubs for unready tools

- `test:go` → `go test ./...` (real, works immediately)
- `lint:go` → remains a stub (golangci-lint not yet installed/configured)
- Add `dev:backend` → `go run ./cmd/server/` for local development

## Risks / Trade-offs

- **[Chi middleware.Logger uses stdlib log, not slog]** → Chi's built-in logger middleware doesn't use `slog`. For now this is acceptable — request logging goes to stderr via the standard logger. We can swap in a custom slog-based middleware later when we care about structured request logs. Keeping it simple for the initial setup.
- **[No config validation]** → Invalid `PORT` values will cause a runtime error at startup. Acceptable for now; we'll add validation when a config library is introduced.
- **[CORS allows all origins in dev]** → Default CORS config allows `*`. Fine for local development. Production CORS config will be tightened when deployment is configured.

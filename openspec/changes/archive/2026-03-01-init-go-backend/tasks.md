## 1. Module Initialization

- [x] 1.1 Run `go mod init github.com/jack-flores/bartering-games/backend` in `backend/` and set Go 1.26 in `go.mod`
- [x] 1.2 Add dependencies: `go-chi/chi/v5`, `go-chi/cors`

## 2. Server Implementation

- [x] 2.1 Create `backend/cmd/server/main.go` with environment-based configuration (PORT, LOG_LEVEL), slog setup (JSON for production, text for debug), Chi router with middleware stack (RealIP, Logger, Recoverer, Compress, CORS), health endpoints (GET /healthz, GET /readyz both returning 200 "ok"), and graceful shutdown on SIGTERM/SIGINT
- [x] 2.2 Verify the server compiles and runs: `cd backend && go build ./cmd/server/ && go vet ./...`

## 3. Taskfile Updates

- [x] 3.1 Wire `test:go` to `go test ./...` (replacing stub)
- [x] 3.2 Add `dev:backend` task running `go run ./cmd/server/` from `backend/`

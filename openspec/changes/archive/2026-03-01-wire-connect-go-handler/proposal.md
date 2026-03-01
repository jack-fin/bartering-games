## Why

The proto definitions, code generation pipeline, and Chi router are all in place, but nothing connects them. The generated Connect-go handler interface sits unused in `backend/gen/`, and the generated TypeScript client in `frontend/gen/` has no runtime client to call. Until these are wired together, the full proto-to-handler-to-client pipeline is unproven and no RPC-based features can be built on top of it.

## What Changes

- Implement `HealthServiceHandler` in `backend/internal/handler/` that returns `SERVING` status
- Mount the Connect handler on the Chi router via `r.Mount()` in `cmd/server/main.go`
- Replace the existing plain-HTTP `/healthz` endpoint with the Connect-based health check (the `/readyz` endpoint stays as-is for container orchestration)
- Add a Go test that calls the health endpoint via a Connect client to verify binary and JSON transports
- Create a Connect transport client in `frontend/src/lib/api/` that the SvelteKit app can use to call backend services
- Add `@connectrpc/connect` and `@connectrpc/connect-web` as frontend dependencies

## Capabilities

### New Capabilities
- `connect-go-wiring`: Mounting Connect-go service handlers on the Chi router and the handler implementation pattern
- `connect-ts-client`: Frontend Connect transport client setup for calling backend RPCs from SvelteKit

### Modified Capabilities
- `http-server`: The server now mounts Connect service handlers alongside plain routes
- `health-rpc`: The health check is now served via Connect handler, not a plain HTTP endpoint

## Impact

- **Backend**: `cmd/server/main.go` gains Connect handler mounting; new handler file in `internal/handler/`; new test file
- **Frontend**: New client setup in `src/lib/api/`; two new npm dependencies (`@connectrpc/connect`, `@connectrpc/connect-web`)
- **API**: Health check moves from `GET /healthz` to Connect's path (`/bartering.v1.HealthService/Check`), supporting both Connect binary and Connect-JSON (gRPC-Web compatible) transports. `/readyz` remains unchanged.

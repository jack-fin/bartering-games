## REMOVED Requirements

### Requirement: HealthService proto definition
**Reason**: The Connect RPC `HealthService` (Check RPC, ServingStatus enum, CheckRequest/CheckResponse messages) is removed along with the protobuf toolchain.
**Migration**: Health check is a plain HTTP `GET /healthz` endpoint returning `ok` (already exists as a Chi route, previously alongside the Connect handler).

### Requirement: Health handler returns SERVING by default
**Reason**: The `HealthHandler.Check` method and its `SERVING_STATUS_SERVING` response are removed.
**Migration**: The `/healthz` endpoint returns HTTP 200 with body `ok`. Future dependency checks (database, workers) update this endpoint directly — no RPC signature involved.

### Requirement: Generated Connect health client (TypeScript)
**Reason**: The TypeScript Connect health client in `frontend/gen/` is removed.
**Migration**: No browser-side health check needed. Docker health checks and monitoring tools consume `GET /healthz` directly.

### Requirement: Generated Connect health handler interface (Go)
**Reason**: The generated `HealthServiceHandler` interface in `backend/gen/` is removed.
**Migration**: No interface — the `/healthz` handler is a plain `http.HandlerFunc` on the Chi router.

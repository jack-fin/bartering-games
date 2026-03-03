## REMOVED Requirements

### Requirement: Connect handler mounting on Chi router
**Reason**: Connect RPC is removed. Service handlers are no longer mounted via `r.Mount(path, handler)` with generated Connect constructors.
**Migration**: Replace with plain Chi HTTP handlers that render templ HTML or return JSON. Routes are registered directly on the Chi router.

### Requirement: HealthHandler implements Connect interface
**Reason**: The `HealthHandler` struct and its `Check` method implementing the generated `HealthServiceHandler` interface are removed.
**Migration**: Health check is a plain `GET /healthz` handler returning `ok`. Delete `backend/internal/handler/health.go` and its test.

### Requirement: Connect binary and JSON protocol support
**Reason**: Connect's proto-binary and ProtoJSON serialization is removed.
**Migration**: No replacement — API endpoints use standard `text/html` (templ) or `application/json` responses. Protobuf serialization is not needed.

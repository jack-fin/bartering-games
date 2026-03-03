## REMOVED Requirements

### Requirement: Connect transport setup
**Reason**: Connect RPC is removed. The TypeScript Connect client and its transport configuration no longer exist.
**Migration**: No replacement — the Go server serves HTML directly. API interactions from the browser use HTMX form submissions or standard HTTP, not typed RPC clients.

### Requirement: Generated TypeScript Connect client stubs
**Reason**: buf codegen for TypeScript is removed along with the protobuf toolchain.
**Migration**: Delete `frontend/gen/` directory. No TypeScript API contract generation needed.

### Requirement: Health service client export
**Reason**: The Connect health client was the only RPC client. Health checks are now plain HTTP (`GET /healthz`).
**Migration**: No client-side health check needed — the health endpoint is consumed by Docker health checks and monitoring tools, not the browser.

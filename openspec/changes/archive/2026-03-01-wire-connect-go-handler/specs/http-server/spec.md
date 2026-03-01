## MODIFIED Requirements

### Requirement: Health endpoint
The server SHALL serve health checks via the Connect-based `HealthService` handler at the path returned by `NewHealthServiceHandler()`. The plain-text `GET /healthz` endpoint SHALL be removed.

#### Scenario: Health check via Connect RPC
- **WHEN** a client sends a Connect request to `/bartering.v1.HealthService/Check`
- **THEN** the server responds with a `CheckResponse` containing the current serving status

#### Scenario: Plain-text healthz is removed
- **WHEN** a client sends `GET /healthz`
- **THEN** the server responds with 404

## ADDED Requirements

### Requirement: Connect handler integration with middleware
Connect service handlers mounted via `r.Mount()` SHALL pass through the same Chi middleware stack (RealIP, Logger, Recoverer, Compress, CORS) as all other routes.

#### Scenario: Middleware applies to Connect requests
- **WHEN** a Connect RPC request is received
- **THEN** it passes through the full middleware stack before reaching the Connect handler

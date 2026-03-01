## ADDED Requirements

### Requirement: Go module initialization
The backend SHALL have a Go module at `backend/go.mod` with module path `github.com/jack-fin/bartering-games/backend` and Go version 1.26.

#### Scenario: Module is valid
- **WHEN** a developer runs `go mod verify` from the `backend/` directory
- **THEN** the command succeeds without errors

### Requirement: Chi router with standard middleware
The server SHALL use `go-chi/chi/v5` as the HTTP router with the following middleware applied in order: RealIP, Logger, Recoverer, Compress, CORS.

#### Scenario: Middleware stack is applied
- **WHEN** a request is received by the server
- **THEN** it passes through RealIP, Logger, Recoverer, Compress, and CORS middleware before reaching the handler

### Requirement: Health endpoint
The server SHALL serve health checks via the Connect-based `HealthService` handler at the path returned by `NewHealthServiceHandler()`. The plain-text `GET /healthz` endpoint SHALL be removed.

#### Scenario: Health check via Connect RPC
- **WHEN** a client sends a Connect request to `/bartering.v1.HealthService/Check`
- **THEN** the server responds with a `CheckResponse` containing the current serving status

#### Scenario: Plain-text healthz is removed
- **WHEN** a client sends `GET /healthz`
- **THEN** the server responds with 404

### Requirement: Readiness endpoint
The server SHALL expose a `GET /readyz` endpoint that returns HTTP 200 with a plain text body of `ok`.

#### Scenario: Readiness check succeeds
- **WHEN** a client sends `GET /readyz`
- **THEN** the server responds with status 200 and body `ok`

#### Scenario: Readiness is extensible
- **WHEN** future stories add database or worker health checks
- **THEN** the readiness handler can be updated to check those dependencies without changing the endpoint path or response format

### Requirement: Structured logging
The server SHALL use `log/slog` for structured logging. In production (LOG_LEVEL is not `debug`), logs SHALL be output as JSON. In development (LOG_LEVEL is `debug`), logs SHALL use text format.

#### Scenario: Production log format
- **WHEN** the server starts with `LOG_LEVEL=info`
- **THEN** log output is JSON-formatted

#### Scenario: Development log format
- **WHEN** the server starts with `LOG_LEVEL=debug`
- **THEN** log output is text-formatted

### Requirement: Environment-based configuration
The server SHALL read configuration from environment variables with these defaults:
- `PORT`: default `8080`
- `LOG_LEVEL`: default `info`

#### Scenario: Default port
- **WHEN** the server starts without `PORT` set
- **THEN** it listens on port 8080

#### Scenario: Custom port
- **WHEN** the server starts with `PORT=3000`
- **THEN** it listens on port 3000

#### Scenario: Default log level
- **WHEN** the server starts without `LOG_LEVEL` set
- **THEN** the log level is info

### Requirement: Graceful shutdown
The server SHALL shut down gracefully on SIGTERM or SIGINT, draining in-flight requests with a timeout.

#### Scenario: Clean shutdown on SIGTERM
- **WHEN** the server receives SIGTERM while handling requests
- **THEN** it stops accepting new connections, waits for in-flight requests to complete (up to the timeout), and exits cleanly

#### Scenario: Clean shutdown on SIGINT
- **WHEN** the server receives SIGINT (Ctrl+C)
- **THEN** it performs the same graceful shutdown as SIGTERM

### Requirement: CORS middleware
The server SHALL include CORS middleware configured to allow all origins by default (for local development), with support for tightening allowed origins via configuration in future.

#### Scenario: CORS headers present
- **WHEN** a client sends a preflight OPTIONS request
- **THEN** the server responds with appropriate CORS headers (Access-Control-Allow-Origin, Access-Control-Allow-Methods, Access-Control-Allow-Headers)

### Requirement: Connect handler integration with middleware
Connect service handlers mounted via `r.Mount()` SHALL pass through the same Chi middleware stack (RealIP, Logger, Recoverer, Compress, CORS) as all other routes.

#### Scenario: Middleware applies to Connect requests
- **WHEN** a Connect RPC request is received
- **THEN** it passes through the full middleware stack before reaching the Connect handler

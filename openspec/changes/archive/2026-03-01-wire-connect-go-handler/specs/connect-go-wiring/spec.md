## ADDED Requirements

### Requirement: Connect handler mounting pattern
The server SHALL mount Connect-generated service handlers on the Chi router using `r.Mount(path, handler)`, where `path` and `handler` are returned by the generated `New<Service>Handler()` function.

#### Scenario: Health service handler is mounted
- **WHEN** the server starts
- **THEN** the Chi router has the `HealthService` Connect handler mounted at the path returned by `NewHealthServiceHandler()`

#### Scenario: Future services follow the same pattern
- **WHEN** a new proto service is defined and code-generated
- **THEN** it can be mounted on the router using the same `r.Mount(path, handler)` pattern without structural changes to the server setup

### Requirement: Health handler implementation
The `backend/internal/handler/` directory SHALL contain a `health.go` file that implements the `HealthServiceHandler` interface from the generated Connect code.

#### Scenario: Handler returns SERVING status
- **WHEN** a client calls the `Check` RPC
- **THEN** the handler returns a `CheckResponse` with status `SERVING_STATUS_SERVING`

#### Scenario: Handler satisfies the interface
- **WHEN** the Go code compiles
- **THEN** the health handler struct satisfies the `barteringv1connect.HealthServiceHandler` interface

### Requirement: Connect handler test
The backend SHALL include a Go test that verifies the health Connect endpoint works using the generated Connect client.

#### Scenario: Health check via Connect client succeeds
- **WHEN** a test creates an `httptest.NewServer` with the Chi router and calls `Check` via `NewHealthServiceClient`
- **THEN** the response contains status `SERVING_STATUS_SERVING` and no error

#### Scenario: Health check via JSON codec succeeds
- **WHEN** a test calls the health endpoint using Connect-JSON (gRPC-Web compatible) transport
- **THEN** the response is valid JSON containing the serving status

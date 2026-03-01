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

### Requirement: Go import alias convention for generated protobuf code
Go source files that import the generated protobuf package (`barteringv1`) SHALL alias it as `pb`. Go source files that import the generated Connect package (`barteringv1connect`) SHALL alias it as `rpc`.

#### Scenario: Handler file uses pb alias
- **WHEN** a handler file in `backend/internal/handler/` imports `github.com/jack-fin/bartering-games/backend/gen/bartering/v1`
- **THEN** the import is aliased as `pb`
- **AND** all type references use the `pb.` prefix (e.g., `pb.CheckRequest`, `pb.CheckResponse`)

#### Scenario: Handler file uses rpc alias
- **WHEN** a handler file or test imports `github.com/jack-fin/bartering-games/backend/gen/bartering/v1/barteringv1connect`
- **THEN** the import is aliased as `rpc`
- **AND** all type references use the `rpc.` prefix (e.g., `rpc.NewHealthServiceHandler`, `rpc.NewHealthServiceClient`)

#### Scenario: Existing handler tests updated
- **WHEN** `backend/internal/handler/health_test.go` is compiled
- **THEN** it uses `pb` for protobuf types and `rpc` for Connect client/handler constructors
- **AND** all tests pass with identical behavior to before the alias change

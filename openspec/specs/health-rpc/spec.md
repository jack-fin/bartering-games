## ADDED Requirements

### Requirement: Health proto file exists
The repository SHALL contain a `proto/bartering/v1/health.proto` file with package `bartering.v1` defining a `HealthService`.

#### Scenario: Package and service declaration
- **WHEN** a developer inspects `proto/bartering/v1/health.proto`
- **THEN** it declares `package bartering.v1`, sets the Go package option, and defines a `HealthService` service

#### Scenario: Buf lint passes
- **WHEN** a developer runs `buf lint` from the `proto/` directory
- **THEN** `health.proto` passes all lint rules

### Requirement: HealthService Check RPC
The `HealthService` SHALL define a unary `Check` RPC that accepts a `CheckRequest` and returns a `CheckResponse`.

#### Scenario: Check RPC definition
- **WHEN** a developer inspects the `HealthService` definition
- **THEN** it contains `rpc Check(CheckRequest) returns (CheckResponse)`

### Requirement: CheckRequest message
The `CheckRequest` message SHALL be empty (no fields), allowing clients to call the health check without parameters.

#### Scenario: Empty request
- **WHEN** a client sends a `CheckRequest`
- **THEN** no fields are required

### Requirement: CheckResponse message
The `CheckResponse` message SHALL contain a `ServingStatus status` field indicating the health of the service.

#### Scenario: CheckResponse contains status
- **WHEN** a developer inspects the `CheckResponse` message
- **THEN** it contains a `ServingStatus status` field

### Requirement: ServingStatus enum
The `health.proto` file SHALL define a `ServingStatus` enum with values `SERVING_STATUS_UNSPECIFIED`, `SERVING_STATUS_SERVING`, and `SERVING_STATUS_NOT_SERVING`.

#### Scenario: Enum values
- **WHEN** a developer inspects the `ServingStatus` enum
- **THEN** it contains `SERVING_STATUS_UNSPECIFIED = 0`, `SERVING_STATUS_SERVING = 1`, and `SERVING_STATUS_NOT_SERVING = 2`

#### Scenario: Enum follows Buf naming conventions
- **WHEN** `buf lint` runs on `health.proto`
- **THEN** the enum values pass the `ENUM_VALUE_PREFIX` lint rule (prefixed with `SERVING_STATUS_`)

### Requirement: Generated Go Connect handler interface
After code generation, `backend/gen/` SHALL contain a Go Connect handler interface for `HealthService` that can be implemented by a handler in `backend/internal/handler/`.

#### Scenario: Go handler interface exists
- **WHEN** a developer runs `buf generate` and inspects `backend/gen/bartering/v1/`
- **THEN** a Connect-generated Go file exists with a handler interface for `HealthService`

### Requirement: Generated TypeScript Connect client
After code generation, `frontend/gen/` SHALL contain a TypeScript Connect client for `HealthService`.

#### Scenario: TypeScript client exists
- **WHEN** a developer runs `buf generate` and inspects `frontend/gen/bartering/v1/`
- **THEN** a Connect-generated TypeScript file exists with client code for `HealthService`

### Requirement: Health handler returns SERVING by default
The `HealthService` handler SHALL return `SERVING_STATUS_SERVING` when no subsystem checks are configured. Future stories will add dependency checks (database, workers) that can change the status.

#### Scenario: Default health check
- **WHEN** a client calls the `Check` RPC on a freshly started server with no dependency checks configured
- **THEN** the response status is `SERVING_STATUS_SERVING`

#### Scenario: Extensible for future dependency checks
- **WHEN** future stories add database or worker health checks
- **THEN** the handler can be updated to check those dependencies and return `SERVING_STATUS_NOT_SERVING` when they fail, without changing the RPC signature

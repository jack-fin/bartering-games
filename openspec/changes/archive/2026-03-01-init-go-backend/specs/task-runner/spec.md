## MODIFIED Requirements

### Requirement: Test tasks
The Taskfile SHALL define `test`, `test:go`, `test:ts`, `test:int`, and `test:e2e` tasks.

#### Scenario: Aggregate test task runs sub-tasks
- **WHEN** a developer runs `task test`
- **THEN** both `test:go` and `test:ts` execute

#### Scenario: Go unit tests
- **WHEN** a developer runs `task test:go`
- **THEN** `go test ./...` executes from the `backend/` directory

#### Scenario: TypeScript unit tests
- **WHEN** a developer runs `task test:ts`
- **THEN** TypeScript unit tests execute from the `frontend/` directory (or a stub message prints)

#### Scenario: Integration tests
- **WHEN** a developer runs `task test:int`
- **THEN** integration tests execute from the `backend/` directory with the integration build tag (or a stub message prints)

#### Scenario: End-to-end tests
- **WHEN** a developer runs `task test:e2e`
- **THEN** Playwright browser tests execute from the `frontend/` directory (or a stub message prints)

## ADDED Requirements

### Requirement: Backend dev task
The Taskfile SHALL define a `dev:backend` task that runs the Go backend server locally using `go run ./cmd/server/`.

#### Scenario: Dev backend starts the server
- **WHEN** a developer runs `task dev:backend`
- **THEN** the Go backend server starts on the configured port

#### Scenario: Dev backend runs from correct directory
- **WHEN** a developer runs `task dev:backend`
- **THEN** the command executes from the `backend/` directory

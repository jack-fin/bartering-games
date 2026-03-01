## ADDED Requirements

### Requirement: Taskfile exists at repo root
The repo SHALL contain a `Taskfile.yaml` at the repository root using Taskfile v3 syntax (`version: '3'`).

#### Scenario: Taskfile is valid
- **WHEN** a developer runs `task --list` from the repo root
- **THEN** all defined tasks are listed without parse errors

### Requirement: Lint task
The Taskfile SHALL define a `lint` task that runs all linters (Go, TypeScript, Proto).

#### Scenario: Lint task runs sub-linters
- **WHEN** a developer runs `task lint`
- **THEN** Go, TypeScript, and Proto linters all execute (or print stub messages if not yet configured)

### Requirement: Test tasks
The Taskfile SHALL define `test`, `test:go`, `test:ts`, `test:int`, and `test:e2e` tasks.

#### Scenario: Aggregate test task runs sub-tasks
- **WHEN** a developer runs `task test`
- **THEN** both `test:go` and `test:ts` execute

#### Scenario: Go unit tests
- **WHEN** a developer runs `task test:go`
- **THEN** Go unit tests execute from the `backend/` directory (or a stub message prints)

#### Scenario: TypeScript unit tests
- **WHEN** a developer runs `task test:ts`
- **THEN** TypeScript unit tests execute from the `frontend/` directory (or a stub message prints)

#### Scenario: Integration tests
- **WHEN** a developer runs `task test:int`
- **THEN** integration tests execute from the `backend/` directory with the integration build tag (or a stub message prints)

#### Scenario: End-to-end tests
- **WHEN** a developer runs `task test:e2e`
- **THEN** Playwright browser tests execute from the `frontend/` directory (or a stub message prints)

### Requirement: Generate tasks
The Taskfile SHALL define `generate`, `generate:proto`, and `generate:sqlc` tasks.

#### Scenario: Aggregate generate task runs sub-tasks
- **WHEN** a developer runs `task generate`
- **THEN** both `generate:proto` and `generate:sqlc` execute

#### Scenario: Proto codegen
- **WHEN** a developer runs `task generate:proto`
- **THEN** Buf generate runs (or a stub message prints)

#### Scenario: sqlc codegen
- **WHEN** a developer runs `task generate:sqlc`
- **THEN** sqlc generate runs from the `backend/` directory (or a stub message prints)

### Requirement: Migrate task
The Taskfile SHALL define a `migrate` task for running Atlas database migrations.

#### Scenario: Migrate task
- **WHEN** a developer runs `task migrate`
- **THEN** Atlas migrations run (or a stub message prints)

### Requirement: Dev task
The Taskfile SHALL define a `dev` task that starts the local development environment.

#### Scenario: Dev task
- **WHEN** a developer runs `task dev`
- **THEN** the local dev environment starts (docker-compose up + servers) (or a stub message prints)

### Requirement: Stub behavior
Any task that is not yet wired to real tooling SHALL print a descriptive message indicating it is not yet configured and what it will do when wired.

#### Scenario: Stub task output
- **WHEN** a developer runs a stub task (e.g., `task lint`)
- **THEN** the output includes a message like "Not yet configured" and describes the intended behavior

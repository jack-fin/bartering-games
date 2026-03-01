## MODIFIED Requirements

### Requirement: Lint task
The Taskfile SHALL define a `lint` task that runs all linters (Go, TypeScript, Proto).

#### Scenario: Lint task runs sub-linters
- **WHEN** a developer runs `task lint`
- **THEN** Go, TypeScript, and Proto linters all execute

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
- **THEN** `pnpm vitest run` executes from the `frontend/` directory

#### Scenario: Integration tests
- **WHEN** a developer runs `task test:int`
- **THEN** integration tests execute from the `backend/` directory with the integration build tag (or a stub message prints)

#### Scenario: End-to-end tests
- **WHEN** a developer runs `task test:e2e`
- **THEN** Playwright browser tests execute from the `frontend/` directory (or a stub message prints)

## ADDED Requirements

### Requirement: TypeScript lint task
The Taskfile SHALL define a `lint:ts` task that runs `pnpm biome check .` from the `frontend/` directory.

#### Scenario: Lint TS runs Biome
- **WHEN** a developer runs `task lint:ts`
- **THEN** `pnpm biome check .` executes from the `frontend/` directory

### Requirement: Frontend dev task
The Taskfile SHALL define a `dev:frontend` task that runs `pnpm dev` from the `frontend/` directory.

#### Scenario: Dev frontend starts the dev server
- **WHEN** a developer runs `task dev:frontend`
- **THEN** the SvelteKit dev server starts

#### Scenario: Dev frontend runs from correct directory
- **WHEN** a developer runs `task dev:frontend`
- **THEN** the command executes from the `frontend/` directory

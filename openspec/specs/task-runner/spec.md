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

### Requirement: Generate tasks
The Taskfile SHALL define `generate`, `generate:proto`, and `generate:sqlc` tasks.

#### Scenario: Aggregate generate task runs sub-tasks
- **WHEN** a developer runs `task generate`
- **THEN** both `generate:proto` and `generate:sqlc` execute

#### Scenario: Proto codegen runs buf generate
- **WHEN** a developer runs `task generate:proto`
- **THEN** `buf generate` executes from the `proto/` directory and generates code in `backend/gen/` and `frontend/gen/`

#### Scenario: Proto codegen working directory
- **WHEN** a developer runs `task generate:proto`
- **THEN** the command executes from the `proto/` directory

#### Scenario: sqlc codegen
- **WHEN** a developer runs `task generate:sqlc`
- **THEN** sqlc generate runs from the `backend/` directory (or a stub message prints)

### Requirement: Migrate task
The Taskfile SHALL define a `migrate` task for running Atlas database migrations.

#### Scenario: Migrate task
- **WHEN** a developer runs `task migrate`
- **THEN** Atlas migrations run (or a stub message prints)

### Requirement: Dev task
The Taskfile SHALL define a `dev` task that starts the local development environment by running `docker compose up`.

#### Scenario: Dev task starts compose services
- **WHEN** a developer runs `task dev`
- **THEN** `docker compose up` executes and all local dev services start

### Requirement: Stub behavior
Any task that is not yet wired to real tooling SHALL print a descriptive message indicating it is not yet configured and what it will do when wired.

#### Scenario: Stub task output
- **WHEN** a developer runs a stub task (e.g., `task lint`)
- **THEN** the output includes a message like "Not yet configured" and describes the intended behavior

### Requirement: Backend dev task
The Taskfile SHALL define a `dev:backend` task that runs the Go backend server locally using `go run ./cmd/server/`.

#### Scenario: Dev backend starts the server
- **WHEN** a developer runs `task dev:backend`
- **THEN** the Go backend server starts on the configured port

#### Scenario: Dev backend runs from correct directory
- **WHEN** a developer runs `task dev:backend`
- **THEN** the command executes from the `backend/` directory

### Requirement: TypeScript lint task
The Taskfile SHALL define a `lint:ts` task that runs ESLint and Prettier check from the `frontend/` directory.

#### Scenario: Lint TS runs ESLint and Prettier
- **WHEN** a developer runs `task lint:ts`
- **THEN** `pnpm eslint .` and `pnpm prettier --check .` execute from the `frontend/` directory

### Requirement: Proto lint task
The Taskfile SHALL define a `lint:proto` task that runs `buf lint` from the `proto/` directory.

#### Scenario: Proto lint runs buf lint
- **WHEN** a developer runs `task lint:proto`
- **THEN** `buf lint` executes from the `proto/` directory

#### Scenario: Proto lint working directory
- **WHEN** a developer runs `task lint:proto`
- **THEN** the command executes from the `proto/` directory

#### Scenario: Proto lint exits non-zero on violations
- **WHEN** a proto file has lint violations and a developer runs `task lint:proto`
- **THEN** the task exits with a non-zero status code

### Requirement: TypeScript fix task
The Taskfile SHALL define a `fix:ts` task that auto-fixes ESLint and Prettier issues from the `frontend/` directory.

#### Scenario: Fix TS auto-corrects issues
- **WHEN** a developer runs `task fix:ts`
- **THEN** `pnpm eslint --fix .` and `pnpm prettier --write .` execute from the `frontend/` directory

### Requirement: Frontend dev task
The Taskfile SHALL define a `dev:frontend` task that runs `pnpm dev` from the `frontend/` directory.

#### Scenario: Dev frontend starts the dev server
- **WHEN** a developer runs `task dev:frontend`
- **THEN** the SvelteKit dev server starts

#### Scenario: Dev frontend runs from correct directory
- **WHEN** a developer runs `task dev:frontend`
- **THEN** the command executes from the `frontend/` directory

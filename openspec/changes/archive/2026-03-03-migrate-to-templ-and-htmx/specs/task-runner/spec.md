## MODIFIED Requirements

### Requirement: Lint task
The Taskfile SHALL define a `lint` task that runs all linters (Go and vault-js TypeScript). Proto linting is removed.

#### Scenario: Lint task runs sub-linters
- **WHEN** a developer runs `task lint`
- **THEN** Go and vault-js TypeScript linters execute

### Requirement: Test tasks
The Taskfile SHALL define `test`, `test:go`, `test:vault`, `test:int`, and `test:e2e` tasks. The `test:ts` task (Vitest for SvelteKit) is replaced by `test:vault` (Vitest for vault-js).

#### Scenario: Aggregate test task runs sub-tasks
- **WHEN** a developer runs `task test`
- **THEN** both `test:go` and `test:vault` execute

#### Scenario: Go unit tests
- **WHEN** a developer runs `task test:go`
- **THEN** `go test ./...` executes from the `backend/` directory

#### Scenario: Vault-js unit tests
- **WHEN** a developer runs `task test:vault`
- **THEN** `npx vitest run` executes from the `vault-js/` directory

#### Scenario: End-to-end tests
- **WHEN** a developer runs `task test:e2e`
- **THEN** Playwright browser tests execute (or a stub message prints)

### Requirement: Generate tasks
The Taskfile SHALL define `generate`, `generate:templ`, and `generate:sqlc` tasks. The `generate:proto` task is removed.

#### Scenario: Aggregate generate task runs sub-tasks
- **WHEN** a developer runs `task generate`
- **THEN** both `generate:templ` and `generate:sqlc` execute

#### Scenario: templ codegen runs templ generate
- **WHEN** a developer runs `task generate:templ`
- **THEN** `templ generate` executes from the `backend/` directory and produces `_templ.go` files

#### Scenario: sqlc codegen runs sqlc generate
- **WHEN** a developer runs `task generate:sqlc`
- **THEN** `sqlc generate` executes from `backend/internal/storage/` and generates Go code in `backend/internal/storage/db/`

### Requirement: TypeScript lint task
The Taskfile SHALL define a `lint:ts` task that runs ESLint and type checking from the `vault-js/` directory (not the removed `frontend/` directory).

#### Scenario: Lint TS runs ESLint and type check on vault-js
- **WHEN** a developer runs `task lint:ts`
- **THEN** ESLint and `tsc --noEmit` execute from the `vault-js/` directory

### Requirement: TypeScript fix task
The Taskfile SHALL define a `fix:ts` task that auto-fixes ESLint and Prettier issues from the `vault-js/` directory.

#### Scenario: Fix TS auto-corrects issues
- **WHEN** a developer runs `task fix:ts`
- **THEN** ESLint fix and Prettier write execute from the `vault-js/` directory

### Requirement: Frontend dev task
The Taskfile SHALL define a `dev:frontend` task that is removed or repurposed. The SvelteKit dev server is no longer applicable.

#### Scenario: dev:frontend is removed
- **WHEN** a developer runs `task --list`
- **THEN** the `dev:frontend` task does not appear (or prints a message that it has been removed)

### Requirement: Docker build task
The Taskfile SHALL define a `docker:build` task that builds the backend Docker image only. The frontend image build is removed.

#### Scenario: Docker build task builds backend image
- **WHEN** a developer runs `task docker:build`
- **THEN** only the `bartering-backend` image is built via `docker build`

### Requirement: deps:check task
The Taskfile SHALL define a `deps:check` task that verifies all required developer tools are installed. The checked tools SHALL be updated: remove `pnpm`, `buf`, and `node`; add `templ` and `npm` (for vault-js).

#### Scenario: Required tools covered
- **WHEN** a developer runs `task deps:check`
- **THEN** it checks for: `go`, `pnpm`, `task`, `docker`, `colima`, `atlas`, `sqlc`, `golangci-lint`, `lefthook`, and `templ`

## ADDED Requirements

### Requirement: Build vault task
The Taskfile SHALL define a `build:vault` task that compiles the vault-js TypeScript module to `backend/static/vault.js` using esbuild.

#### Scenario: Build vault compiles TypeScript
- **WHEN** a developer runs `task build:vault`
- **THEN** esbuild compiles the vault-js source and outputs `backend/static/vault.js`

#### Scenario: Build vault runs from correct directory
- **WHEN** a developer runs `task build:vault`
- **THEN** the command executes from the `vault-js/` directory

## REMOVED Requirements

### Requirement: Proto lint task
**Reason**: Protobuf toolchain is removed. No `.proto` files exist to lint.
**Migration**: Remove `lint:proto` task and its `buf lint` invocation.

### Requirement: Frontend dev task
**Reason**: SvelteKit frontend is removed.
**Migration**: Remove `dev:frontend` task. The Go backend serves HTML directly; use `task dev:backend` for development.

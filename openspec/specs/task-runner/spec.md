## MODIFIED Requirements

### Requirement: Lint task
The Taskfile SHALL define a `lint` task that runs all linters (Go and vault-js TypeScript).

#### Scenario: Go lint runs from repo root
- **WHEN** a developer runs `task lint`
- **THEN** `golangci-lint run ./...` executes from the repository root (no `dir: backend`)

### Requirement: Test tasks
The Taskfile SHALL define `test`, `test:go`, `test:vault`, `test:int`, and `test:e2e` tasks.

#### Scenario: Go unit tests
- **WHEN** a developer runs `task test:go`
- **THEN** `go test ./...` executes from the repository root (no `dir: backend`)

#### Scenario: Vault-js unit tests
- **WHEN** a developer runs `task test:vault`
- **THEN** `npx vitest run` executes from the `vault-js/` directory

#### Scenario: E2E tests run Playwright
- **WHEN** a developer runs `task test:e2e`
- **THEN** `pnpm exec playwright test` executes from the repository root

#### Scenario: E2E tests are opt-in
- **WHEN** a developer runs `task test`
- **THEN** only `test:go` and `test:vault` run — `test:e2e` is NOT a dependency of `test`

### Requirement: Generate tasks
The Taskfile SHALL define `generate`, `generate:templ`, and `generate:sqlc` tasks.

#### Scenario: templ codegen runs templ generate
- **WHEN** a developer runs `task generate:templ`
- **THEN** `templ generate` executes from the repository root and produces `_templ.go` files

#### Scenario: sqlc codegen runs sqlc generate
- **WHEN** a developer runs `task generate:sqlc`
- **THEN** `sqlc generate` executes from `internal/storage/` and generates Go code in `internal/storage/db/`

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
The Taskfile SHALL define a `docker:build` task that builds the backend Docker image.

#### Scenario: Docker build task builds backend image
- **WHEN** a developer runs `task docker:build`
- **THEN** the image is built via `docker build -t bartering-backend .` (context is repo root, not `./backend`)

### Requirement: deps:check task
The Taskfile SHALL define a `deps:check` task that verifies all required developer tools are installed. The checked tools SHALL be updated: remove `pnpm`, `buf`, and `node`; add `templ` and `npm` (for vault-js).

#### Scenario: Required tools covered
- **WHEN** a developer runs `task deps:check`
- **THEN** it checks for: `go`, `pnpm`, `task`, `docker`, `colima`, `atlas`, `sqlc`, `golangci-lint`, `lefthook`, and `templ`

### Requirement: Build task
The Taskfile SHALL define a `build` task that compiles the Go binary.

#### Scenario: Go build runs from repo root
- **WHEN** a developer runs `task build`
- **THEN** `go build -o bin/server ./cmd/server/` executes from the repository root

### Requirement: Migration tasks
The Taskfile SHALL define `migrate` and `migrate:diff` tasks.

#### Scenario: Migrate runs from repo root
- **WHEN** a developer runs `task migrate`
- **THEN** `atlas migrate apply --env local` executes from the repository root

### Requirement: Dev backend task
The Taskfile SHALL define a `dev:backend` task.

#### Scenario: Dev backend runs from repo root
- **WHEN** a developer runs `task dev:backend`
- **THEN** `go run ./cmd/server/` executes from the repository root

## ADDED Requirements

### Requirement: Build vault task
The Taskfile SHALL define a `build:vault` task that compiles the vault-js TypeScript module to `cmd/server/static/vault.js` using esbuild.

#### Scenario: Build vault compiles TypeScript
- **WHEN** a developer runs `task build:vault`
- **THEN** esbuild compiles the vault-js source and outputs `cmd/server/static/vault.js` (no `backend/` prefix)

## REMOVED Requirements

### Requirement: Proto lint task
**Reason**: Protobuf toolchain is removed. No `.proto` files exist to lint.
**Migration**: Remove `lint:proto` task and its `buf lint` invocation.

### Requirement: Frontend dev task
**Reason**: SvelteKit frontend is removed.
**Migration**: Remove `dev:frontend` task. The Go backend serves HTML directly; use `task dev:backend` for development.

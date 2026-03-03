## MODIFIED Requirements

### Requirement: Test tasks
The Taskfile SHALL define `test`, `test:go`, `test:vault`, `test:int`, and `test:e2e` tasks.

#### Scenario: Go unit tests
- **WHEN** a developer runs `task test:go`
- **THEN** `go test ./...` executes from the repository root (no `dir: backend`)

#### Scenario: Vault-js unit tests
- **WHEN** a developer runs `task test:vault`
- **THEN** `npx vitest run` executes from the `vault-js/` directory

### Requirement: Generate tasks
The Taskfile SHALL define `generate`, `generate:templ`, and `generate:sqlc` tasks.

#### Scenario: templ codegen runs templ generate
- **WHEN** a developer runs `task generate:templ`
- **THEN** `templ generate` executes from the repository root and produces `_templ.go` files

#### Scenario: sqlc codegen runs sqlc generate
- **WHEN** a developer runs `task generate:sqlc`
- **THEN** `sqlc generate` executes from `internal/storage/` and generates Go code in `internal/storage/db/`

### Requirement: Lint task
The Taskfile SHALL define a `lint` task that runs all linters (Go and vault-js TypeScript).

#### Scenario: Go lint runs from repo root
- **WHEN** a developer runs `task lint`
- **THEN** `golangci-lint run ./...` executes from the repository root (no `dir: backend`)

### Requirement: Docker build task
The Taskfile SHALL define a `docker:build` task that builds the backend Docker image.

#### Scenario: Docker build task builds backend image
- **WHEN** a developer runs `task docker:build`
- **THEN** the image is built via `docker build -t bartering-backend .` (context is repo root, not `./backend`)

### Requirement: Build vault task
The Taskfile SHALL define a `build:vault` task that compiles the vault-js TypeScript module to `cmd/server/static/vault.js` using esbuild.

#### Scenario: Build vault compiles TypeScript
- **WHEN** a developer runs `task build:vault`
- **THEN** esbuild compiles the vault-js source and outputs `cmd/server/static/vault.js` (no `backend/` prefix)

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

### Requirement: Lint job runs all linters
The CI workflow SHALL include a `lint` job that runs Go and vault-js TypeScript linters. Go linting SHALL use `golangci/golangci-lint-action` with `working-directory` set to the repository root (or omitted, since it defaults to root).

#### Scenario: Go lint working directory is repo root
- **WHEN** the lint job runs `golangci-lint`
- **THEN** `working-directory` SHALL be `.` or omitted (not `backend`)

### Requirement: Go module setup
The CI workflow SHALL use `actions/setup-go` with `go-version-file` pointing to the root-level `go.mod`.

#### Scenario: go-version-file points to root go.mod
- **WHEN** the CI workflow sets up Go
- **THEN** `go-version-file` SHALL be `go.mod` (not `backend/go.mod`)

### Requirement: Unified PR lint comment with upsert behavior
The `lint` job SHALL post a single PR comment summarising the outcome of all non-golangci-lint checks (TypeScript lint, codegen verification). On each re-run the comment SHALL be updated in place rather than a new comment being created.

#### Scenario: Lint comment created on first run
- **WHEN** the lint job runs on a pull request for the first time
- **THEN** a single comment is posted by the GitHub Actions bot containing the status of each lint check

#### Scenario: Lint comment updated on re-run
- **WHEN** the lint job runs on a pull request that already has a lint comment from a previous run
- **THEN** the existing comment is updated with fresh results and no new comment is posted

#### Scenario: Comment shows all-green on passing run
- **WHEN** all lint checks pass
- **THEN** the comment is updated to show a passing status for each check

#### Scenario: Comment shows failures with detail
- **WHEN** one or more lint checks fail
- **THEN** each failing check displays its output in a collapsible `<details>` section within the comment

#### Scenario: No comment on non-PR push
- **WHEN** the lint job runs on a direct push with no associated pull request
- **THEN** no PR comment is posted

### Requirement: Lint job verifies codegen is committed
The `lint` job SHALL verify that generated templ and sqlc code is up to date by running `task generate` and then `git diff --exit-code`.

#### Scenario: Codegen verification runs from repo root
- **WHEN** the lint job runs `task generate`
- **THEN** `working-directory` SHALL be `.` or omitted (not `backend`)

### Requirement: test-go job runs unit and integration tests
The CI workflow SHALL include a `test-go` job that runs Go unit tests and integration tests from the repository root.

#### Scenario: Unit tests run from repo root
- **WHEN** the `test-go` job runs `task test:go`
- **THEN** `working-directory` SHALL be `.` or omitted (not `backend`)

#### Scenario: Integration tests run from repo root
- **WHEN** the `test-go` job runs `task test:int`
- **THEN** `working-directory` SHALL be `.` or omitted (not `backend`)

### Requirement: Go module cache
The CI workflow SHALL cache Go module downloads using `actions/cache` keyed on `go.sum` to avoid redundant downloads across runs.

#### Scenario: Go modules restored from cache
- **WHEN** `go.sum` has not changed since the last run
- **THEN** Go modules are restored from cache without downloading from the network

### Requirement: test-vault job runs vault-js unit tests
The CI workflow SHALL include a `test-vault` job that installs pnpm dependencies in `vault-js/` and runs `task test:vault`.

#### Scenario: Vault tests pass
- **WHEN** all Vitest unit tests pass
- **THEN** the test-vault job exits zero

#### Scenario: test-vault job fails on test failure
- **WHEN** any vault-js test fails
- **THEN** the test-vault job exits non-zero

### Requirement: pnpm store cache for vault-js
The CI workflow SHALL cache the pnpm store for the vault-js directory using `actions/cache` keyed on `vault-js/pnpm-lock.yaml`.

#### Scenario: pnpm store restored from cache
- **WHEN** `vault-js/pnpm-lock.yaml` has not changed since the last run
- **THEN** pnpm dependencies are restored from cache without downloading from the registry

### Requirement: templ CLI installation in CI
The `lint` job SHALL install the `templ` CLI so that `task generate:templ` can run for codegen verification.

#### Scenario: templ is available in lint job
- **WHEN** the lint job runs the codegen verification step
- **THEN** `templ generate` is available and executes successfully

### Requirement: test-e2e job runs Playwright browser tests
The CI workflow SHALL include a `test-e2e` job that runs Playwright E2E tests against the full application stack (Go backend + Postgres). The job SHALL run in parallel with other CI jobs (lint, test-go, test-vault) with no dependencies between them.

#### Scenario: E2E tests pass on clean PR
- **WHEN** a pull request is opened with passing code
- **THEN** the `test-e2e` job starts a Postgres service container, builds the Go server binary, runs `task test:e2e`, and exits zero

#### Scenario: E2E tests fail on broken page
- **WHEN** a pull request breaks a user-facing page (e.g., homepage fails to load)
- **THEN** the `test-e2e` job exits non-zero and uploads failure artifacts

#### Scenario: E2E job runs in parallel with other jobs
- **WHEN** the CI workflow triggers
- **THEN** the `test-e2e` job starts immediately without waiting for lint, test-go, or test-vault

### Requirement: Postgres service container for E2E
The `test-e2e` job SHALL use a GitHub Actions `services` container to run Postgres, exposed on localhost. Database credentials SHALL be passed to the Go server via environment variables.

#### Scenario: Postgres is available when tests start
- **WHEN** the `test-e2e` job begins executing steps
- **THEN** Postgres is already running and accepting connections on localhost

#### Scenario: Atlas migrations run before server starts
- **WHEN** the `test-e2e` job sets up the database
- **THEN** Atlas migrations are applied to the Postgres service container before the Go server boots

### Requirement: Pre-built Go binary for E2E
The `test-e2e` job SHALL compile the Go server with `go build -o bin/server ./cmd/server/` before running Playwright, rather than using `go run`.

#### Scenario: Server binary is pre-compiled
- **WHEN** the `test-e2e` job prepares to run Playwright
- **THEN** a pre-compiled binary exists at `bin/server` and is used by Playwright's `webServer` config

### Requirement: Playwright browser caching
The `test-e2e` job SHALL cache Playwright's Chromium browser installation using `actions/cache`, keyed on the root `pnpm-lock.yaml` hash.

#### Scenario: Chromium restored from cache on unchanged lockfile
- **WHEN** `pnpm-lock.yaml` has not changed since the last run
- **THEN** the cached Chromium binary is restored and `playwright install` is skipped

#### Scenario: Chromium installed on cache miss
- **WHEN** `pnpm-lock.yaml` has changed (e.g., Playwright version bump)
- **THEN** `pnpm exec playwright install --with-deps chromium` runs and the result is cached

### Requirement: Go build caching for E2E
The `test-e2e` job SHALL cache Go modules (`~/go/pkg/mod`) and the Go build cache (`~/.cache/go-build`) to minimize compilation time.

#### Scenario: Go modules restored from cache
- **WHEN** `go.sum` has not changed since the last run
- **THEN** Go modules are restored from cache without downloading

#### Scenario: Go build cache speeds up compilation
- **WHEN** Go source files have not changed significantly since the last run
- **THEN** the Go build cache reduces compilation time for `go build`

### Requirement: E2E failure artifact upload
The `test-e2e` job SHALL upload Playwright test artifacts (screenshots, traces, HTML report) when tests fail, using `actions/upload-artifact`.

#### Scenario: Artifacts uploaded on test failure
- **WHEN** the Playwright test step fails
- **THEN** `test-results/` and `playwright-report/` are uploaded as job artifacts

#### Scenario: No artifacts uploaded on success
- **WHEN** all Playwright tests pass
- **THEN** no artifacts are uploaded

### Requirement: pnpm dependency caching for E2E
The `test-e2e` job SHALL cache pnpm dependencies using the root `pnpm-lock.yaml` as the cache key, separate from the vault-js pnpm cache.

#### Scenario: Root pnpm store restored from cache
- **WHEN** the root `pnpm-lock.yaml` has not changed since the last run
- **THEN** pnpm dependencies are restored from cache without downloading

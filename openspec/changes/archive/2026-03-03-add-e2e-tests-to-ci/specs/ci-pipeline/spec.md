## ADDED Requirements

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

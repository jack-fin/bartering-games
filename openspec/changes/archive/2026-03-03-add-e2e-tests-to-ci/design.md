## Context

The CI pipeline (`.github/workflows/ci.yml`) currently runs four jobs: lint, check-openspec-archived, test-go, and test-vault. Playwright E2E tests exist locally (`e2e/smoke.spec.ts`, `task test:e2e`) but are not validated in CI. The E2E tests need a running Go backend and Postgres database, which is why this was deferred from the initial CI setup (sc-50).

The existing Playwright config already handles CI vs local differences — `forbidOnly`, `retries`, `workers`, and `reuseExistingServer` all branch on `!!process.env.CI`.

## Goals / Non-Goals

**Goals:**
- Run Playwright smoke tests on every PR and merge group event
- Start the Go backend + Postgres within the CI job so tests execute against the real stack
- Upload failure artifacts (screenshots, traces) for debugging
- **Minimize CI wall-clock time** — the E2E job must be as fast as possible through aggressive caching, pre-built binaries, and parallel job execution

**Non-Goals:**
- Running E2E tests against a deployed environment (staging/production)
- Adding Firefox or WebKit browser coverage (Chromium-only matches local config)
- Parallelizing E2E across multiple CI runners (single worker is sufficient for smoke tests)
- Adding the E2E job as a required status check (can be done later once stable)

## Decisions

### 1. Pre-build the Go binary instead of `go run`

Build the server with `go build -o bin/server ./cmd/server/` as an explicit step, then point Playwright's `webServer` command at `bin/server`. This avoids recompiling Go on every test run and lets us benefit from the Go build cache.

Update `playwright.config.ts` to use `bin/server` in CI (via an env var or by detecting `CI`) while keeping `go run` for local dev convenience.

**Rationale**: `go run` recompiles every invocation. A pre-built binary starts instantly, shaving ~10-15s off the critical path. The Go module and build caches further reduce compile time on subsequent runs.

**Alternative**: Keep `go run` as-is. Rejected — unnecessary compile latency in CI where speed is a primary goal.

### 2. Playwright `webServer` starts the backend (not a separate step)

The `playwright.config.ts` defines a `webServer` block that starts the server and waits for `/healthz`. The CI job relies on this mechanism rather than starting the server as a separate background step.

**Rationale**: Playwright manages the server lifecycle (start before tests, kill after), and the config already handles CI-specific settings. No duplication needed.

**Alternative**: Start the Go server as a background step and wait for it. Rejected — duplicates logic already in the Playwright config and introduces race conditions.

### 3. Postgres via `services` container (not testcontainers)

Use GitHub Actions' `services` key to run Postgres as a sidecar container, exposed on localhost. Configure via environment variables matching what the Go server expects.

**Rationale**: `services` containers start before job steps — Postgres is ready by the time steps begin, adding zero wall-clock time. Simpler and faster than testcontainers (no Docker-in-Docker).

**Alternative**: Use `docker-compose up` to start the full stack. Rejected — heavier setup, slower startup, and Playwright's `webServer` already handles the Go process.

### 4. Cache Playwright browsers with `actions/cache`

Cache `~/.cache/ms-playwright` keyed on `pnpm-lock.yaml` hash. On miss, run `pnpm exec playwright install --with-deps chromium`.

**Rationale**: The Chromium download is ~150MB and takes 10-20s. Caching eliminates this on most runs. Using `pnpm-lock.yaml` as cache key ensures the browser version stays in sync with the `@playwright/test` package version.

**Alternative**: Use `playwright install` without caching. Rejected — unnecessary network cost on every run.

### 5. Cache Go modules and build artifacts

Cache `~/go/pkg/mod` (keyed on `go.sum`) and `~/.cache/go-build` (keyed on Go source files) to speed up both dependency resolution and compilation.

**Rationale**: The Go build cache means subsequent runs with unchanged source skip most compilation. Combined with the pre-built binary approach, this reduces the build step to seconds on cache hits.

### 6. Root pnpm dependencies cached separately from vault-js

The lint job already caches pnpm for `vault-js/pnpm-lock.yaml`. The E2E job caches against the root `pnpm-lock.yaml` since that's where `@playwright/test` lives.

**Rationale**: Different lockfiles, different dependency trees. Using the correct lockfile per job ensures accurate cache invalidation.

### 7. Upload artifacts only on failure

Use `actions/upload-artifact` with `if: failure()` to upload `test-results/` and `playwright-report/`.

**Rationale**: Success runs don't need artifacts. Failure artifacts (screenshots, traces) are critical for debugging CI-only failures.

### 8. Run E2E job in parallel with other CI jobs

The `test-e2e` job has no dependency on lint, test-go, or test-vault. It runs independently in parallel.

**Rationale**: CI wall-clock time is bounded by the slowest job. Running E2E in parallel ensures it doesn't extend total pipeline duration unless it's the slowest job itself.

## Risks / Trade-offs

- **CI time increase (~20-40s with caching)**: E2E adds Go compile + Playwright run, but aggressive caching (Go build, Playwright browsers, pnpm) keeps the warm-cache case fast. → Mitigation: Job runs in parallel with other CI jobs, so it only matters if it becomes the bottleneck.
- **Flaky tests in CI**: Browser tests can be flaky in headless CI environments. → Mitigation: Playwright config already sets `retries: 2` in CI. Traces captured on first retry for debugging.
- **Database schema drift**: E2E job needs Postgres with the correct schema. → Mitigation: Run Atlas migrations as a setup step before starting the server.
- **Playwright config divergence (local vs CI)**: Switching from `go run` to `bin/server` in CI introduces a branch. → Mitigation: Use an env var (e.g., `E2E_SERVER_CMD`) or check `process.env.CI` in the config. Keep the logic minimal.

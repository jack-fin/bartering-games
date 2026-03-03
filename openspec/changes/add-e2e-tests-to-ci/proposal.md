## Why

The Playwright E2E infrastructure is in place locally (smoke tests, login fixture, `task test:e2e`), but CI doesn't run browser tests. PRs can break user-facing flows — homepage loading, health checks, page rendering — without any automated signal. This was explicitly deferred from sc-50 due to stack complexity; now it's time to close that gap.

## What Changes

- Add a `test-e2e` job to `.github/workflows/ci.yml` that starts the full application stack (Go backend + Postgres) and runs `task test:e2e`
- Install Playwright browsers in CI (Chromium only, matching local config)
- Upload test artifacts (screenshots, traces) on failure for debugging
- Wire pnpm dependency caching for the root `package.json` (separate from vault-js)

## Capabilities

### New Capabilities

_None — this change adds a CI job, not a new user-facing capability._

### Modified Capabilities

- `ci-pipeline`: Adding a `test-e2e` job alongside existing lint, test-go, and test-vault jobs
- `e2e-testing`: No requirement changes to the tests themselves, but the spec's implicit assumption of "local-only" is now expanded to include CI execution

## Impact

- **CI workflow** (`.github/workflows/ci.yml`): New job added; PR duration increases by E2E test time (~30-60s)
- **CI resource usage**: Chromium browser install + Go build + Postgres container per E2E run
- **Root `pnpm-lock.yaml`**: Will be used as cache key (already exists, no changes needed)
- **Taskfile**: No changes needed — `task test:e2e` already works

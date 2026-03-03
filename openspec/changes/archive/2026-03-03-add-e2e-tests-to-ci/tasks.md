## 1. Update Playwright Config for CI

- [x] 1.1 Update `playwright.config.ts` webServer command to use `bin/server` when `process.env.CI` is set, keeping `go run ./cmd/server/` for local dev
- [x] 1.2 Ensure `PORT` env var is passed through to the pre-built binary in the webServer config

## 2. Add test-e2e Job to CI Workflow

- [x] 2.1 Add `test-e2e` job to `.github/workflows/ci.yml` with Postgres `services` container (postgres:17, health check, exposed on localhost)
- [x] 2.2 Add setup steps: checkout, setup-go (with go.mod), setup-node (lts/*), pnpm, Task CLI
- [x] 2.3 Add Go module cache (`~/go/pkg/mod` keyed on `go.sum`) and Go build cache (`~/.cache/go-build`)
- [x] 2.4 Add Playwright browser cache (`~/.cache/ms-playwright` keyed on root `pnpm-lock.yaml`)
- [x] 2.5 Add pnpm dependency cache for root `pnpm-lock.yaml` (separate from vault-js cache)
- [x] 2.6 Add step to install root pnpm dependencies (`pnpm install --frozen-lockfile`)
- [x] 2.7 Add step to install Playwright Chromium on cache miss (`pnpm exec playwright install --with-deps chromium`)
- [x] 2.8 Add step to install Atlas CLI and run migrations against the Postgres service container
- [x] 2.9 Add step to build Go binary (`go build -o bin/server ./cmd/server/`)
- [x] 2.10 Add step to run E2E tests (`task test:e2e`)
- [x] 2.11 Add `actions/upload-artifact` step with `if: failure()` to upload `test-results/` and `playwright-report/`

## 3. Verify and Test

- [x] 3.1 Run `task test:e2e` locally to verify the Playwright config change doesn't break local dev
- [x] 3.2 Push branch and verify the `test-e2e` job passes in CI

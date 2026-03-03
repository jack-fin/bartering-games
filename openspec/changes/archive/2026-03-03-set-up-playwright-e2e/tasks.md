## 1. Package Setup

- [x] 1.1 Create root `package.json` with `@playwright/test` dev dependency (private, pnpm)
- [x] 1.2 Run `pnpm install` and `pnpm exec playwright install chromium` to install browser binary
- [x] 1.3 Update `.gitignore` with Playwright artifacts (`test-results/`, `playwright-report/`, `blob-report/`)

## 2. Playwright Configuration

- [x] 2.1 Create `playwright.config.ts` at repo root — Chromium only, `testDir: 'e2e'`, `webServer` block starting Go backend on a dedicated E2E port
- [x] 2.2 Create `e2e/` directory

## 3. Smoke Test

- [x] 3.1 Create `e2e/smoke.spec.ts` — navigate to `/`, verify page loads with expected content
- [x] 3.2 Add health endpoint check to smoke test (`/healthz` or equivalent)

## 4. Login Fixture

- [x] 4.1 Create `e2e/fixtures.ts` with extended test object exporting an `authenticatedPage` fixture (stub implementation with TODO for Steam OAuth)

## 5. Taskfile Integration

- [x] 5.1 Update `test:e2e` task in `Taskfile.yaml` to run `pnpm exec playwright test` (replacing placeholder echo)
- [x] 5.2 Verify `test:e2e` is NOT a dependency of the `test` task (opt-in only)

## 6. Claude Rule

- [x] 6.1 Create `.claude/rules/e2e-testing.md` rule instructing Claude to update/add E2E tests when routes or page templates change

## 7. Verification

- [x] 7.1 Run `task test:e2e` and confirm smoke test passes against local Go backend

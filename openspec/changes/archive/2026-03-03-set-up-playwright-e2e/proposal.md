## Why

We need automated browser-level testing to verify the full stack works end-to-end — Go server, templ rendering, HTMX interactions, and vault-js encryption. Unit tests cover individual layers but can't catch integration failures between server-rendered HTML and client-side behavior. Playwright gives us multi-browser, multi-context testing needed for two-user trade flows later.

## What Changes

- Install Playwright as a dev dependency with a root-level `package.json` for E2E tooling
- Add `playwright.config.ts` configured for the Go backend (not SvelteKit — the original story predates the architecture)
- Create a smoke test (`e2e/smoke.spec.ts`) that verifies the app loads and key pages respond
- Scaffold a login fixture (`e2e/fixtures.ts`) for authenticating test users — login is the first feature being built
- Wire `task test:e2e` in Taskfile to actually run Playwright (replacing the current placeholder)
- Add a `.claude/rules/` rule to keep E2E tests updated when routes or pages change
- Skip accessibility auditing (`@axe-core/playwright`) for now — will be added separately

## Capabilities

### New Capabilities
- `e2e-testing`: Playwright installation, configuration, smoke tests, login fixture, and Taskfile integration

### Modified Capabilities
- `task-runner`: Update `test:e2e` task from placeholder to actual Playwright execution

## Impact

- **New files**: `package.json` (root), `pnpm-lock.yaml`, `playwright.config.ts`, `e2e/` test directory, `.claude/rules/e2e-testing.md`
- **Modified files**: `Taskfile.yaml` (test:e2e task), `.gitignore` (Playwright artifacts)
- **Dependencies**: `@playwright/test` (dev only), Chromium browser binary (via `playwright install`)
- **CI**: Not added to CI in this change (per CLAUDE.md — E2E is opt-in initially). Comment placeholder added for future integration.

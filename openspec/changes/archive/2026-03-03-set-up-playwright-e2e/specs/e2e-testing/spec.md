## ADDED Requirements

### Requirement: Playwright installation and configuration
The project SHALL have Playwright installed as a dev dependency with a root-level `package.json` and a `playwright.config.ts` that targets the Go backend.

#### Scenario: Playwright config exists and targets Go backend
- **WHEN** a developer opens `playwright.config.ts` at the repository root
- **THEN** it configures Chromium as the sole browser project, sets `testDir` to `e2e/`, and defines a `webServer` block that starts the Go backend

#### Scenario: Root package.json is E2E-scoped
- **WHEN** a developer inspects the root `package.json`
- **THEN** it contains `@playwright/test` as a dev dependency, is marked `"private": true`, and has a `"test:e2e"` script

### Requirement: Smoke test
The project SHALL include a smoke test at `e2e/smoke.spec.ts` that verifies the application loads.

#### Scenario: Smoke test navigates to homepage
- **WHEN** Playwright runs the smoke test
- **THEN** it navigates to `/`, verifies the page returns HTTP 200, and the page contains expected content (e.g., the site title)

#### Scenario: Smoke test checks health endpoint
- **WHEN** Playwright runs the smoke test
- **THEN** it navigates to `/healthz` (or equivalent health route) and verifies a 200 response

### Requirement: Login fixture
The project SHALL include a login fixture in `e2e/fixtures.ts` that provides an authenticated page context for tests.

#### Scenario: Login fixture exports extended test object
- **WHEN** a test file imports from `e2e/fixtures.ts`
- **THEN** it receives a `test` object extended with an `authenticatedPage` fixture that provides a logged-in browser page

#### Scenario: Login fixture is a callable stub
- **WHEN** the login fixture runs before a test
- **THEN** it executes a placeholder authentication step (TODO for real Steam OAuth flow) and yields an authenticated page context

### Requirement: Taskfile integration
The `test:e2e` task in `Taskfile.yaml` SHALL execute Playwright tests instead of printing a placeholder message.

#### Scenario: task test:e2e runs Playwright
- **WHEN** a developer runs `task test:e2e`
- **THEN** `pnpm exec playwright test` executes from the repository root

#### Scenario: test:e2e is opt-in
- **WHEN** a developer runs `task test`
- **THEN** only `test:go` and `test:vault` run — `test:e2e` is NOT included as a dependency

### Requirement: Gitignore updates
The `.gitignore` SHALL exclude Playwright test artifacts.

#### Scenario: Playwright artifacts ignored
- **WHEN** Playwright tests produce output
- **THEN** `test-results/`, `playwright-report/`, and `blob-report/` directories are git-ignored

### Requirement: Claude rule for E2E test maintenance
A `.claude/rules/` rule SHALL instruct Claude to keep E2E tests updated when routes or page templates change.

#### Scenario: Rule file exists
- **WHEN** Claude operates on this repository
- **THEN** a rule at `.claude/rules/e2e-testing.md` reminds Claude to update or add E2E tests when modifying routes, page templates, or user-facing behavior

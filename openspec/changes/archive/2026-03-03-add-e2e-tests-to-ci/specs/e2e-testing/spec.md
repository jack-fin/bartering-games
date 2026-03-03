## MODIFIED Requirements

### Requirement: Playwright installation and configuration
The project SHALL have Playwright installed as a dev dependency with a root-level `package.json` and a `playwright.config.ts` that targets the Go backend. The Playwright config SHALL support both local development (`go run`) and CI execution (pre-built binary) via the `webServer` configuration.

#### Scenario: Playwright config exists and targets Go backend
- **WHEN** a developer opens `playwright.config.ts` at the repository root
- **THEN** it configures Chromium as the sole browser project, sets `testDir` to `e2e/`, and defines a `webServer` block that starts the Go backend

#### Scenario: Root package.json is E2E-scoped
- **WHEN** a developer inspects the root `package.json`
- **THEN** it contains `@playwright/test` as a dev dependency, is marked `"private": true`, and has a `"test:e2e"` script

#### Scenario: CI uses pre-built binary for webServer
- **WHEN** Playwright runs in CI (`process.env.CI` is set)
- **THEN** the `webServer` command uses the pre-built binary at `bin/server` instead of `go run ./cmd/server/`

#### Scenario: Local dev uses go run for webServer
- **WHEN** Playwright runs locally (no `CI` env var)
- **THEN** the `webServer` command uses `go run ./cmd/server/` as before

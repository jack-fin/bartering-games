## Context

The project is a Go backend serving templ-rendered HTML with HTMX for SPA-like navigation and vault-js for client-side encryption. There are no browser-level tests today — the `test:e2e` task in Taskfile is a placeholder. The first user-facing feature being built is login (Steam OAuth), so the login fixture is the priority scaffolding.

Playwright is not yet installed. The project has a root-level Go module and a `vault-js/` TypeScript sub-package with its own `package.json`. There is no root `package.json`.

## Goals / Non-Goals

**Goals:**
- Install Playwright with Chromium-only for fast local testing
- Configure Playwright to test against the Go backend (not a JS dev server)
- Create a smoke test proving the setup works
- Scaffold a login fixture for authenticated test scenarios
- Wire `task test:e2e` to run Playwright for real
- Add a Claude rule ensuring E2E tests stay current as routes change

**Non-Goals:**
- CI integration (deferred — E2E is opt-in locally for now)
- Multi-browser testing (Chromium only initially)
- Accessibility auditing via axe-core (deferred per user request)
- Actual login flow implementation (just the fixture scaffold)
- Multi-user trade flow fixtures (comes with trade feature work)

## Decisions

### 1. Root-level `package.json` for E2E tooling

**Decision**: Create a root `package.json` separate from `vault-js/package.json`.

**Rationale**: Playwright tests exercise the full Go stack, not just vault-js. Placing E2E deps at root keeps concerns separated — vault-js is a standalone crypto library, E2E is a project-wide testing concern. pnpm workspaces are unnecessary overhead for two independent package.jsons.

**Alternatives considered**:
- Add Playwright to `vault-js/package.json` — wrong scope, vault-js is a standalone module
- pnpm workspaces — over-engineered for two unrelated packages

### 2. Test directory at `e2e/` (project root)

**Decision**: Tests live in `e2e/` at the repository root, not nested under any Go or TS package.

**Rationale**: E2E tests are a project-wide concern that spans Go backend + JS frontend. Root-level placement makes this clear and keeps `playwright.config.ts` at the root alongside the config.

### 3. Go backend as `webServer` in Playwright config

**Decision**: Use Playwright's `webServer` config to start the Go backend via `go run ./cmd/server/` before tests, targeting `http://localhost:<port>`.

**Rationale**: This gives Playwright ownership of the server lifecycle — no manual "start the server first" step. Tests are self-contained. The Go server starts fast enough (~1-2s) that this won't slow down test runs.

### 4. Login fixture as the primary scaffold

**Decision**: Create a `login` fixture in `e2e/fixtures.ts` that extends Playwright's base test with an authenticated page context.

**Rationale**: Login (Steam OAuth) is the first feature being built. The fixture will initially be a stub (TODO for actual auth flow) but establishes the pattern for all future authenticated tests. This avoids every test file reimplementing login logic.

### 5. Chromium-only for speed

**Decision**: Configure only Chromium in `playwright.config.ts`. Firefox and WebKit can be added later.

**Rationale**: Single-browser keeps `playwright install` fast and test runs quick for local development. Cross-browser testing can be added when CI integration happens.

## Risks / Trade-offs

- **`webServer` port conflicts** → Use a dedicated port (e.g., 3100) for E2E tests to avoid colliding with `task dev:backend`. Configurable via env var.
- **Login fixture is a stub** → Acceptable since login isn't implemented yet. The fixture establishes the pattern; actual auth logic gets filled in when login ships.
- **No CI validation** → E2E tests could drift if not run regularly. Mitigated by the Claude rule reminding to update tests, and eventual CI integration.
- **Root package.json may confuse tooling** → Add a clear `"name": "bartering-games-e2e"` and `"private": true` to signal this isn't a publishable package.

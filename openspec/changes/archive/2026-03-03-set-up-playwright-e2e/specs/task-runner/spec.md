## MODIFIED Requirements

### Requirement: Test tasks
The Taskfile SHALL define `test`, `test:go`, `test:vault`, `test:int`, and `test:e2e` tasks.

#### Scenario: Go unit tests
- **WHEN** a developer runs `task test:go`
- **THEN** `go test ./...` executes from the repository root (no `dir: backend`)

#### Scenario: Vault-js unit tests
- **WHEN** a developer runs `task test:vault`
- **THEN** `npx vitest run` executes from the `vault-js/` directory

#### Scenario: E2E tests run Playwright
- **WHEN** a developer runs `task test:e2e`
- **THEN** `pnpm exec playwright test` executes from the repository root

#### Scenario: E2E tests are opt-in
- **WHEN** a developer runs `task test`
- **THEN** only `test:go` and `test:vault` run — `test:e2e` is NOT a dependency of `test`

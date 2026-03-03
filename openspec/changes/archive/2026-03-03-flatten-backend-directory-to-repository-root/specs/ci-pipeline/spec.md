## MODIFIED Requirements

### Requirement: Lint job runs all linters
The CI workflow SHALL include a `lint` job that runs Go and vault-js TypeScript linters. Go linting SHALL use `golangci/golangci-lint-action` with `working-directory` set to the repository root (or omitted, since it defaults to root).

#### Scenario: Go lint working directory is repo root
- **WHEN** the lint job runs `golangci-lint`
- **THEN** `working-directory` SHALL be `.` or omitted (not `backend`)

### Requirement: Go module setup
The CI workflow SHALL use `actions/setup-go` with `go-version-file` pointing to the root-level `go.mod`.

#### Scenario: go-version-file points to root go.mod
- **WHEN** the CI workflow sets up Go
- **THEN** `go-version-file` SHALL be `go.mod` (not `backend/go.mod`)

### Requirement: test-go job runs unit and integration tests
The CI workflow SHALL include a `test-go` job that runs Go unit tests and integration tests from the repository root.

#### Scenario: Unit tests run from repo root
- **WHEN** the `test-go` job runs `task test:go`
- **THEN** `working-directory` SHALL be `.` or omitted (not `backend`)

#### Scenario: Integration tests run from repo root
- **WHEN** the `test-go` job runs `task test:int`
- **THEN** `working-directory` SHALL be `.` or omitted (not `backend`)

### Requirement: Lint job verifies codegen is committed
The `lint` job SHALL verify that generated templ and sqlc code is up to date by running `task generate` and then `git diff --exit-code`.

#### Scenario: Codegen verification runs from repo root
- **WHEN** the lint job runs `task generate`
- **THEN** `working-directory` SHALL be `.` or omitted (not `backend`)

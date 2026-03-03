## MODIFIED Requirements

### Requirement: Lint job runs all linters
The CI workflow SHALL include a `lint` job that runs Go and vault-js TypeScript linters. Go linting SHALL use `golangci/golangci-lint-action` (with PR annotations enabled); vault-js TypeScript linting SHALL invoke `task lint:ts`. Proto linting is removed.

#### Scenario: Lint job passes on clean code
- **WHEN** all source files pass their respective linters
- **THEN** the lint job exits zero

#### Scenario: Lint job fails on violation
- **WHEN** any linter reports a violation
- **THEN** the lint job exits non-zero and the violation is reported in CI output

#### Scenario: Go lint violation annotates the PR diff
- **WHEN** a Go lint violation exists on lines changed in a pull request
- **THEN** the violation appears as an inline annotation on the PR diff

### Requirement: Unified PR lint comment with upsert behavior
The `lint` job SHALL post a single PR comment summarising the outcome of all non-golangci-lint checks (TypeScript lint, codegen verification). Buf breaking and proto lint are removed from the comment. On each re-run the comment SHALL be updated in place rather than a new comment being created.

#### Scenario: Lint comment created on first run
- **WHEN** the lint job runs on a pull request for the first time
- **THEN** a single comment is posted by the GitHub Actions bot containing the status of each lint check

#### Scenario: Lint comment updated on re-run
- **WHEN** the lint job runs on a pull request that already has a lint comment from a previous run
- **THEN** the existing comment is updated with fresh results and no new comment is posted

#### Scenario: Comment shows all-green on passing run
- **WHEN** all lint checks pass
- **THEN** the comment is updated to show a passing status for each check

#### Scenario: Comment shows failures with detail
- **WHEN** one or more lint checks fail
- **THEN** each failing check displays its output in a collapsible `<details>` section within the comment

#### Scenario: No comment on non-PR push
- **WHEN** the lint job runs on a direct push with no associated pull request
- **THEN** no PR comment is posted

### Requirement: Lint job verifies codegen is committed
The `lint` job SHALL verify that generated templ and sqlc code is up to date by running `task generate` and then `git diff --exit-code`. Protobuf codegen verification is removed.

#### Scenario: Generated code is up to date
- **WHEN** all `.templ` and SQL query files match the checked-in generated output
- **THEN** `git diff --exit-code` exits zero and the verify-codegen check passes

#### Scenario: Generated code is stale
- **WHEN** a `.templ` or SQL query file was modified without regenerating
- **THEN** `git diff --exit-code` exits non-zero and the lint job fails with a message indicating which files differ

### Requirement: test-go job runs unit and integration tests
The CI workflow SHALL include a `test-go` job that runs Go unit tests via `task test:go` and integration tests via `task test:int`. No changes to this requirement.

#### Scenario: Unit tests pass
- **WHEN** all Go unit tests pass
- **THEN** the `task test:go` step exits zero

#### Scenario: Integration tests pass
- **WHEN** all Go integration tests pass with a real Postgres instance via testcontainers
- **THEN** the `task test:int` step exits zero

#### Scenario: test-go job fails on test failure
- **WHEN** any Go unit or integration test fails
- **THEN** the test-go job exits non-zero

### Requirement: Go module cache
The CI workflow SHALL cache Go module downloads using `actions/cache` keyed on `go.sum` to avoid redundant downloads across runs. No changes to this requirement.

#### Scenario: Go modules restored from cache
- **WHEN** `go.sum` has not changed since the last run
- **THEN** Go modules are restored from cache without downloading from the network

## ADDED Requirements

### Requirement: test-vault job runs vault-js unit tests
The CI workflow SHALL include a `test-vault` job that installs pnpm dependencies in `vault-js/` and runs `task test:vault`.

#### Scenario: Vault tests pass
- **WHEN** all Vitest unit tests pass
- **THEN** the test-vault job exits zero

#### Scenario: test-vault job fails on test failure
- **WHEN** any vault-js test fails
- **THEN** the test-vault job exits non-zero

### Requirement: pnpm store cache for vault-js
The CI workflow SHALL cache the pnpm store for the vault-js directory using `actions/cache` keyed on `vault-js/pnpm-lock.yaml`.

#### Scenario: pnpm store restored from cache
- **WHEN** `vault-js/pnpm-lock.yaml` has not changed since the last run
- **THEN** pnpm dependencies are restored from cache without downloading from the registry

### Requirement: templ CLI installation in CI
The `lint` job SHALL install the `templ` CLI so that `task generate:templ` can run for codegen verification.

#### Scenario: templ is available in lint job
- **WHEN** the lint job runs the codegen verification step
- **THEN** `templ generate` is available and executes successfully

## REMOVED Requirements

### Requirement: buf breaking check with label bypass
**Reason**: Protobuf toolchain is removed. No `.proto` files exist to check for breaking changes.
**Migration**: Remove the buf breaking step, the `api:breaking-change` label bypass logic, and the associated PR comment.

### Requirement: test-ts job runs TypeScript unit tests
**Reason**: SvelteKit frontend is removed. TypeScript tests are now vault-js only, handled by the new `test-vault` job.
**Migration**: Replace `test-ts` job with `test-vault` job.

### Requirement: pnpm store cache
**Reason**: The cache key changes from `frontend/pnpm-lock.yaml` to `vault-js/pnpm-lock.yaml`.
**Migration**: Update the pnpm store cache key to reference the vault-js lockfile.

### Requirement: api:breaking-change GitHub label exists
**Reason**: Protobuf toolchain is removed. The label served the buf breaking check bypass, which no longer exists.
**Migration**: Label can be deleted from the repository (no action needed if left in place — it becomes inert).

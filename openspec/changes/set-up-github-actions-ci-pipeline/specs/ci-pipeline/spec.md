## ADDED Requirements

### Requirement: CI workflow file exists
The repository SHALL contain a `.github/workflows/ci.yml` file that triggers on `push` and `pull_request` events for all branches.

#### Scenario: Workflow triggers on push
- **WHEN** a developer pushes commits to any branch
- **THEN** the CI workflow runs automatically

#### Scenario: Workflow triggers on pull request
- **WHEN** a pull request is opened, synchronized, or reopened
- **THEN** the CI workflow runs automatically

### Requirement: Lint job runs all linters
The CI workflow SHALL include a `lint` job that runs Go, TypeScript, and Proto linters. Go linting SHALL use `golangci/golangci-lint-action` (with PR annotations enabled); TypeScript and Proto linting SHALL invoke `task lint:ts` and `task lint:proto`.

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
The `lint` job SHALL post a single PR comment summarising the outcome of all non-golangci-lint checks (TypeScript lint, Proto lint, buf breaking, codegen verification). On each re-run the comment SHALL be updated in place rather than a new comment being created.

#### Scenario: Lint comment created on first run
- **WHEN** the lint job runs on a pull request for the first time
- **THEN** a single comment is posted by the GitHub Actions bot containing the status of each lint check

#### Scenario: Lint comment updated on re-run
- **WHEN** the lint job runs on a pull request that already has a lint comment from a previous run
- **THEN** the existing comment is updated with fresh results and no new comment is posted

#### Scenario: Comment shows all-green on passing run
- **WHEN** all lint checks pass
- **THEN** the comment is updated to show a passing status for each check (comment is not deleted)

#### Scenario: Comment shows failures with detail
- **WHEN** one or more lint checks fail
- **THEN** each failing check displays its output in a collapsible `<details>` section within the comment

#### Scenario: No comment on non-PR push
- **WHEN** the lint job runs on a direct push with no associated pull request
- **THEN** no PR comment is posted

### Requirement: Lint job verifies codegen is committed
The `lint` job SHALL verify that generated protobuf and sqlc code is up to date by running `task generate` and then `git diff --exit-code`.

#### Scenario: Generated code is up to date
- **WHEN** all `.proto` and SQL query files match the checked-in generated output
- **THEN** `git diff --exit-code` exits zero and the verify-codegen check passes

#### Scenario: Generated code is stale
- **WHEN** a `.proto` or SQL query file was modified without regenerating
- **THEN** `git diff --exit-code` exits non-zero and the lint job fails with a message indicating which files differ

### Requirement: buf breaking check with label bypass
The `lint` job SHALL run `buf breaking --against '.git#branch=main'` on proto files. When the check fails on a pull request, the job SHALL post a PR comment explaining the failure and how to bypass it using the `api:breaking-change` label.

#### Scenario: No breaking changes detected
- **WHEN** no proto changes break backward compatibility with main
- **THEN** the buf breaking step passes and the lint job continues

#### Scenario: Breaking change detected, no bypass label
- **WHEN** a proto change breaks backward compatibility AND the PR does not have the `api:breaking-change` label
- **THEN** the lint job fails AND a comment is posted on the PR explaining the failure and instructing the author to apply the `api:breaking-change` label if the break is intentional

#### Scenario: Breaking change detected, bypass label applied
- **WHEN** a proto change breaks backward compatibility AND the PR has the `api:breaking-change` label
- **THEN** the lint job continues and the breaking change is permitted

#### Scenario: buf breaking on push (not a PR)
- **WHEN** a push occurs outside of a PR context
- **THEN** the buf breaking step runs and fails the job if breaking changes are detected (no label bypass available on direct pushes)

### Requirement: test-go job runs unit and integration tests
The CI workflow SHALL include a `test-go` job that runs Go unit tests via `task test:go` and integration tests via `task test:int`.

#### Scenario: Unit tests pass
- **WHEN** all Go unit tests pass
- **THEN** the `task test:go` step exits zero

#### Scenario: Integration tests pass
- **WHEN** all Go integration tests pass with a real Postgres instance via testcontainers
- **THEN** the `task test:int` step exits zero

#### Scenario: test-go job fails on test failure
- **WHEN** any Go unit or integration test fails
- **THEN** the test-go job exits non-zero

### Requirement: Docker image pre-pull cache for integration tests
The `test-go` job SHALL cache the Postgres Docker image used by testcontainers using `actions/cache`, keyed by the image name and tag, to avoid a full registry pull on every run.

#### Scenario: Cache hit on subsequent runs
- **WHEN** the Postgres image has been cached from a previous run
- **THEN** the image is loaded from cache and the registry pull is skipped

#### Scenario: Cache miss on first run or version change
- **WHEN** no cached image exists for the current Postgres tag
- **THEN** the image is pulled from the registry and saved to the cache for future runs

### Requirement: test-ts job runs TypeScript unit tests
The CI workflow SHALL include a `test-ts` job that installs pnpm dependencies with `--frozen-lockfile` and runs `task test:ts`.

#### Scenario: TypeScript tests pass
- **WHEN** all Vitest unit tests pass
- **THEN** the test-ts job exits zero

#### Scenario: Lockfile drift is caught
- **WHEN** `package.json` has been updated but `pnpm-lock.yaml` has not been regenerated
- **THEN** `pnpm install --frozen-lockfile` fails and the test-ts job exits non-zero

### Requirement: Go module cache
The CI workflow SHALL cache Go module downloads using `actions/cache` keyed on `go.sum` to avoid redundant downloads across runs.

#### Scenario: Go modules restored from cache
- **WHEN** `go.sum` has not changed since the last run
- **THEN** Go modules are restored from cache without downloading from the network

### Requirement: pnpm store cache
The CI workflow SHALL cache the pnpm store using `actions/cache` keyed on `pnpm-lock.yaml` to avoid redundant downloads across runs.

#### Scenario: pnpm store restored from cache
- **WHEN** `pnpm-lock.yaml` has not changed since the last run
- **THEN** pnpm dependencies are restored from cache without downloading from the registry

### Requirement: OpenSpec archived check runs on PRs to main
The CI workflow SHALL include a job that fails if any unarchived OpenSpec changes exist in `openspec/changes/` (excluding `openspec/changes/archive/`). The standalone `check-openspec-archived.yml` workflow SHALL be deleted once this job is added to `ci.yml`.

#### Scenario: Unarchived change blocks merge
- **WHEN** a pull request to `main` is opened and an `.openspec.yaml` file exists outside `openspec/changes/archive/`
- **THEN** the check job fails and lists the unarchived change names

#### Scenario: All changes archived — check passes
- **WHEN** all `.openspec.yaml` files are under `openspec/changes/archive/`
- **THEN** the check job exits zero

### Requirement: api:breaking-change GitHub label exists
The repository SHALL have a GitHub label named `api:breaking-change` that maintainers can apply to PRs to permit intentional proto breaking changes through CI.

#### Scenario: Label is available in repo
- **WHEN** a maintainer opens a PR with intentional breaking proto changes
- **THEN** the `api:breaking-change` label is available to apply from the PR label picker

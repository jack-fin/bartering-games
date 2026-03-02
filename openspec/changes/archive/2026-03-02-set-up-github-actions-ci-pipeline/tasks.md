## 1. Pre-flight Setup

- [x] 1.1 Create the `api:breaking-change` GitHub label (red, `#d93f0b`) via `gh label create "api:breaking-change" --color "d93f0b" --description "Permits intentional proto breaking changes to pass CI"`
- [x] 1.2 Wire up `task test:int` in `Taskfile.yaml` — replace stub with `go test -tags=integration ./...`
- [x] 1.3 Add `buf breaking --against '.git#branch=main'` as a second command in the `lint-proto` block of `lefthook.yml` (separate command name: `lint-proto-breaking` so it can be individually skipped)

## 2. GitHub Actions Workflow

- [x] 2.1 Create `.github/workflows/ci.yml` with top-level trigger on `push` and `pull_request` for all branches
- [x] 2.2 Add the `lint` job: setup Go, use `golangci/golangci-lint-action` (annotations enabled), install buf + sqlc for remaining linter steps
- [x] 2.3 Add `task lint:ts` and `task lint:proto` steps to `lint` job with `continue-on-error: true`
- [x] 2.4 Add verify-codegen-is-committed step to `lint` job: run `task generate`, then `git diff --exit-code`, with `continue-on-error: true`
- [x] 2.5 Add `buf breaking` step to `lint` job with `continue-on-error: true`; include label-bypass logic (`api:breaking-change`)
- [x] 2.6 Add unified PR lint comment step via `actions/github-script`: collects outcomes + outputs from steps 2.3–2.5, upserts a single comment (search for `<!-- bartering-games-ci-lint -->` marker, update if found, create if not), then hard-fails the job if any step failed without a valid bypass
- [x] 2.7 Add `check-openspec-archived` job to `ci.yml` (scoped to `pull_request` targeting `main` only); copy logic from existing `check-openspec-archived.yml`
- [x] 2.8 Delete `.github/workflows/check-openspec-archived.yml`
- [x] 2.9 Add the `test-go` job: setup Go 1.26, install Task runner, add Go module cache (`actions/cache` keyed on `go.sum`)
- [x] 2.10 Add Docker image pre-pull cache step to `test-go` job: restore/save `postgres:17` tarball via `actions/cache` keyed on `postgres:17`, load on cache hit, pull + save on cache miss
- [x] 2.11 Add test steps to `test-go` job: `task test:go` then `task test:int`
- [x] 2.12 Add the `test-ts` job: setup Node LTS, install pnpm via `pnpm/action-setup`, add pnpm store cache (`actions/cache` keyed on `pnpm-lock.yaml`), run `pnpm install --frozen-lockfile`, then `task test:ts`

## 3. Verification

- [x] 3.1 Push the branch and confirm all jobs appear in GitHub Actions and pass on a clean run
- [x] 3.2 Introduce a deliberate proto breaking change on a test commit, verify the lint job fails and the PR comment shows the buf breaking error with bypass instructions
- [x] 3.3 Re-run after applying the `api:breaking-change` label — verify the comment is updated (not duplicated) and the job passes
- [x] 3.4 Verify the Docker image cache is populated after the first `test-go` run and used (not re-pulled) on a second run
- [x] 3.5 Remove `.gitkeep` from `.github/workflows/` if present

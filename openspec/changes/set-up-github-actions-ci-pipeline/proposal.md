## Why

The project has pre-commit hooks for local quality gates, but nothing enforces code quality on CI — hooks can be bypassed (`--no-verify`), and contributors without hooks installed can push broken code. A GitHub Actions pipeline closes this gap by acting as the authoritative gate on every push and PR. While setting this up, we're also adding `buf breaking` to pre-commit hooks, which currently only runs `buf lint`.

## What Changes

- Add `.github/workflows/ci.yml` with three parallel jobs: `lint`, `test-go`, and `test-ts`
- `lint` job runs all linters (Go, TypeScript, Proto, DB) plus a verify-codegen-is-committed check
- `test-go` job runs unit tests and integration tests (via testcontainers) against real Postgres
- `test-ts` job runs Vitest unit tests with pnpm
- Go module cache and pnpm store cached across runs to reduce CI time
- Add `buf breaking --against .git#branch=main` to the `lint-proto` pre-commit hook (currently only `buf lint` runs locally)

## Capabilities

### New Capabilities
- `ci-pipeline`: GitHub Actions workflow that enforces linting, codegen verification, and testing on every push and pull request

### Modified Capabilities
- `pre-commit-hooks`: Add `buf breaking --against .git#branch=main` to the proto pre-commit check, so breaking changes are caught locally before push
- `task-runner`: CI will invoke `task lint`, `task test:go`, `task test:ts` to stay in sync with local dev — new linters added to Taskfile automatically run in CI

## Impact

- New file: `.github/workflows/ci.yml`
- Updated file: `lefthook.yml` (add `buf breaking` to `lint-proto` command)
- Taskfile tasks (`lint`, `test:go`, `test:ts`, `generate:proto`, `generate:sqlc`) must work in a clean CI environment
- Integration tests need Docker-in-CI; testcontainers pulls images at runtime — `ubuntu-latest` runners have Docker available
- No new runtime dependencies; CI tools installed in workflow steps

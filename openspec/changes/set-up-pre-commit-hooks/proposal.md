## Why

Linting errors are currently only caught in CI, meaning developers get feedback only after pushing. Fast local pre-commit checks short-circuit that cycle and prevent avoidable CI failures from landing on the remote. CI continues to run the full linter suite as a safety net — pre-commit is optimized for speed, not completeness.

## What Changes

- Add `lefthook.yml` at the repo root configuring a pre-commit hook that lints only staged files
  - `golangci-lint` on staged `.go` files
  - ESLint + Prettier on staged `.ts`, `.svelte`, `.json` files
  - `buf lint` when any `.proto` file is staged
- Add `task hooks:install` to Taskfile — runs `lefthook install` to wire hooks into `.git/hooks/`
- Document hook setup in CLAUDE.md so new contributors know to run `task hooks:install`
- CI/CD continues to run `task lint` (full repo, no file filtering) — no changes needed there

## Capabilities

### New Capabilities

- `pre-commit-hooks`: Lefthook-based pre-commit hook system that runs linters against staged files only, installed via `task hooks:install`

### Modified Capabilities

- `task-runner`: Adding `hooks:install` task that runs `lefthook install`

## Impact

- **`lefthook.yml`**: New file at repo root (version-controlled)
- **`Taskfile.yaml`**: New `hooks:install` task
- **`CLAUDE.md`**: Setup instructions for new contributors
- **New dev dependency**: `lefthook` binary (installed via Homebrew or `go install`, not a project dependency)
- **No CI changes required**: existing `task lint` already covers the full run

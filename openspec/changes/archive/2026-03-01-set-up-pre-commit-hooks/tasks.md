## 1. Lefthook Configuration

- [x] 1.1 Add `lefthook.yml` at repo root with pre-commit hooks for Go (`golangci-lint`), TS/Svelte/JSON (ESLint + Prettier), and Proto (`buf lint`) — each scoped to staged files via glob filters
- [x] 1.2 Verify lefthook is installed locally (`brew install lefthook` or `go install`) and run `lefthook install` to test the config

## 2. Taskfile Integration

- [x] 2.1 Add `hooks:install` task to `Taskfile.yaml` that runs `lefthook install`

## 3. Documentation

- [x] 3.1 Update `CLAUDE.md` to document `task hooks:install` as a one-time setup step for new contributors and note the `lefthook` binary prerequisite

## 4. Validation

- [x] 4.1 Stage a Go file with a lint violation and confirm the commit is blocked
- [x] 4.2 Stage a TS/Svelte file with a formatting issue and confirm Prettier auto-fixes and re-stages it
- [x] 4.3 Stage a `.proto` file and confirm `buf lint` runs
- [x] 4.4 Stage only non-linted files (e.g., a markdown file) and confirm all hook steps are skipped
- [x] 4.5 Run `task hooks:install` twice and confirm it succeeds both times without error

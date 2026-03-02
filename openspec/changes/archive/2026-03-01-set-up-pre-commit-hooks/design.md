## Context

The repo has three linting tools configured (`golangci-lint`, ESLint + Prettier, `buf lint`) but no local git hooks to run them. Developers only see lint failures after pushing to CI. The goal is to add fast pre-commit checks without slowing down the commit workflow.

## Goals / Non-Goals

**Goals:**
- Run linters locally on staged files before each commit
- Keep pre-commit under ~5 seconds on a typical change
- One-command setup for new contributors (`task hooks:install`)
- Hook config tracked in git so all contributors use the same setup

**Non-Goals:**
- Replacing the CI lint run — CI continues running the full `task lint` suite
- Type-checking or compilation on pre-commit (too slow; belongs in CI)

## Decisions

### 1. Lefthook as the hook runner

**Decision**: Use `lefthook` rather than Husky, `pre-commit` (Python), or a raw shell script.

**Rationale**:
- Single Go binary — no Node or Python runtime required, appropriate for a Go + TS + Proto monorepo
- Built-in staged-file filtering via `glob` patterns — no secondary tool (e.g., lint-staged) needed
- Parallel hook execution out of the box
- `lefthook.yml` is version-controlled at the repo root, visible to all contributors

**Alternatives considered**:
- **Husky**: Node-only install, no built-in file filtering, requires `lint-staged` as a second tool, awkward placement in a multi-language monorepo
- **pre-commit (Python)**: Creates Python venvs per hook at install time — noticeable startup overhead on every commit
- **Raw shell script (`.githooks/pre-commit`)**: Zero dependencies but requires manual staged-file diffing logic; harder to maintain across three linters

### 2. Staged files only on pre-commit; full run in CI

**Decision**: Pre-commit hooks use lefthook's `glob` filtering to run each linter only against the files staged for the current commit. CI runs `task lint` unchanged (full corpus, no filtering).

**Rationale**:
- Pre-commit is a tightening feedback loop, not a replacement for CI. Speed matters — a slow pre-commit will get `--no-verify`'d.
- CI is already the authoritative lint gate. Running full lint locally on every commit adds ~15–30s with no additional safety benefit over what CI already catches.

### 3. Hooks invoke linters directly, not via Taskfile

**Decision**: `lefthook.yml` calls linters (`golangci-lint`, `eslint`, `prettier`, `buf`) directly with staged file arguments. It does not route through `task lint:*` tasks.

**Rationale**:
- Taskfile lint tasks operate on the entire repo (no file-list argument). There is no existing `task lint:go:staged` variant.
- Adding file-list arguments to Taskfile tasks would complicate them for a use case (staged-file filtering) that is exclusively a pre-commit concern.
- Lefthook's `glob` + `{staged_files}` substitution handles this cleanly without Taskfile involvement.
- `task hooks:install` remains the install entrypoint — the Taskfile integration is at the install level, not the execution level.

### 4. `lefthook` installed as a developer tool, not a project dependency

**Decision**: `lefthook` is installed globally (Homebrew: `brew install lefthook`, or `go install github.com/evilmartians/lefthook@latest`). It is not added to `go.mod` or `frontend/package.json`.

**Rationale**:
- Pre-commit tooling is a developer workstation concern, not a build or runtime dependency.
- Adding it to `go.mod` would pull it into the production dependency graph unnecessarily.
- CLAUDE.md and `task hooks:install` output will surface the install requirement clearly.

## Risks / Trade-offs

- **Developer skips install** → Pre-commit hooks simply don't run; no error, no protection. Mitigation: document in CLAUDE.md and print a reminder in `task hooks:install` output. CI remains the safety net.
- **Linter version skew** → Local `golangci-lint` version may differ from CI. Mitigation: pin `golangci-lint` version in CI config and document the expected version in CLAUDE.md.
- **False positives on rename/move** → If a file is staged as renamed, lefthook passes the new path but the file content hasn't changed. Edge case; acceptable given CI is the authoritative gate.

## Migration Plan

1. Add `lefthook.yml` to repo root
2. Add `task hooks:install` to `Taskfile.yaml`
3. Update `CLAUDE.md` with setup instructions
4. Each developer runs `task hooks:install` once to activate

No rollback concern — removing the hook is `git config --unset core.hooksPath` or deleting `.git/hooks/pre-commit`.

## Open Questions

- None — all decisions resolved above.

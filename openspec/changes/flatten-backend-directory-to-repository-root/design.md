## Context

The repository was originally structured as a monorepo with `backend/` and `frontend/` top-level directories. After removing the SvelteKit frontend (sc-143), only `backend/` and `vault-js/` remain. The `backend/` wrapper adds an unnecessary nesting layer to every Go path and deviates from standard Go project layout for single-service repos.

Current Go module: `github.com/jack-fin/bartering-games/backend`
Current import example: `github.com/jack-fin/bartering-games/backend/internal/components/pages`

The templ documentation and standard Go conventions both recommend a flat layout with `cmd/`, `internal/`, etc. at the repo root for single-service projects.

## Goals / Non-Goals

**Goals:**

- Eliminate the `backend/` directory wrapper, moving all contents to the repo root
- Update the Go module path to `github.com/jack-fin/bartering-games`
- Rewrite all internal import paths
- Update all tooling configurations (Taskfile, CI, lefthook, Docker, sqlc, Atlas)
- Rename `static/vendor/` to `static/lib/` to avoid `.gitignore` `vendor/` rule conflict
- Regenerate all generated code (templ, sqlc) with correct paths

**Non-Goals:**

- Changing any runtime behavior, APIs, or features
- Restructuring `internal/` package layout (that's a separate concern)
- Modifying `vault-js/` internal structure (only its build output path changes)
- Changing the database schema or migrations content

## Decisions

### 1. Module path: `github.com/jack-fin/bartering-games`

**Rationale**: Dropping the `/backend` suffix follows Go convention — the module path matches the repository path. This is the standard for single-service repos.

**Alternative considered**: Keeping the module path and just moving files. Rejected because it would create a confusing mismatch between filesystem layout and module path.

### 2. Rename `static/vendor/` → `static/lib/`

**Rationale**: The root `.gitignore` has a `vendor/` rule for Go vendoring. After flattening, `cmd/server/static/vendor/` would be caught by this rule. Renaming to `lib/` avoids the conflict cleanly.

**Alternative considered**: Adding a `!cmd/server/static/vendor/` exception to `.gitignore`. Rejected because negation rules are fragile and confusing — `lib/` is clearer and doesn't fight the ignore system.

### 3. Single atomic commit for the move

**Rationale**: Git tracks renames best when done in a single commit. Splitting the move across commits would make `git log --follow` less reliable and create intermediate broken states.

**Alternative considered**: Multi-commit approach (move files, then update paths). Rejected because the intermediate state wouldn't compile, and a single commit preserves git blame history better.

### 4. Regenerate rather than manually fix generated files

**Rationale**: templ `_templ.go` files and sqlc `db/*.go` files contain import paths. Regenerating them with `templ generate` and `sqlc generate` after the move is more reliable than find-and-replace in generated code.

### 5. Update `sqlc.yaml` schema path

**Rationale**: Currently `sqlc.yaml` lives at `backend/internal/storage/sqlc.yaml` with `schema: "../../migrations/"`. After flattening, it moves to `internal/storage/sqlc.yaml` and the relative path to `migrations/` stays the same (`../../migrations/`). No change needed to the relative path since both the config and migrations move together.

## Risks / Trade-offs

- **[Risk] Git history for moved files** → Git's rename detection handles this well for single-commit moves. Use `git log --follow` to trace history across the rename. Keeping the move in one commit maximizes rename detection accuracy.

- **[Risk] Open PRs or branches based on old structure** → No other PRs are open. This is early-stage, so no external consumers of the module path.

- **[Risk] Broken IDE state after move** → Developers need to restart their IDE / LSP after the move. `gopls` will re-index automatically once `go.mod` is updated.

- **[Trade-off] `vault-js/` stays nested** → `vault-js/` remains as a subdirectory since it's a separate TypeScript module with its own `package.json`. This is the correct structure — it's not a Go package.

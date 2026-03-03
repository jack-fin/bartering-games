## Why

The `backend/` wrapper directory is a remnant of the previous monorepo layout that included a SvelteKit frontend. Now that the frontend has been removed (sc-143), every Go path carries an unnecessary `backend/` prefix. Flattening to the repo root follows standard Go project conventions for single-service repos and matches the directory structure recommended by the templ documentation.

## What Changes

- Move all contents of `backend/` (`cmd/`, `internal/`, `migrations/`, `schema.hcl`, `atlas.hcl`, `go.mod`, `go.sum`, `Dockerfile`, `.dockerignore`) to the repository root
- Update Go module path from `github.com/jack-fin/bartering-games/backend` to `github.com/jack-fin/bartering-games` and rewrite all import paths
- Rename `cmd/server/static/vendor/` to `cmd/server/static/lib/` to avoid `.gitignore` conflict with the Go `vendor/` rule
- Update `Taskfile.yaml` — remove `dir: backend` entries, adjust paths
- Update `.github/workflows/ci.yml` — remove `working-directory: backend`, fix `go-version-file` path
- Update `lefthook.yml` — change glob patterns and `root:` from `backend` to `.`
- Update `vault-js/package.json` build output path (`../backend/cmd/server/static/vault.js` → `../cmd/server/static/vault.js`)
- Update `docker-compose.yaml` if it references `backend/`
- Update `sqlc.yaml` relative schema path (`../../migrations/` → adjusted for new location)
- Update `atlas.hcl` paths (already relative, will work at new location)
- Update `Dockerfile` COPY paths for the new root context
- Remove the now-empty `backend/` directory

## Capabilities

### New Capabilities

_(none — this is a structural refactor, not a new feature)_

### Modified Capabilities

- `monorepo-layout`: Directory tree changes — `backend/` contents move to repo root; `vendor/` renamed to `lib/` under static assets
- `task-runner`: All `dir: backend` entries removed; paths adjusted for root-level Go module
- `ci-pipeline`: `working-directory` and `go-version-file` paths updated
- `docker-images`: Dockerfile build context changes from `./backend` to `.`; COPY paths updated
- `pre-commit-hooks`: Glob patterns and `root:` entries updated from `backend/` to `.`
- `sqlc-codegen`: Config path moves; relative schema reference updated
- `atlas-migrations`: `atlas.hcl` and `schema.hcl` move to repo root; migration dir path stays relative
- `templ-server`: Component paths updated (no `backend/` prefix)
- `http-server`: Import paths updated throughout
- `gitignore`: `vendor/` rule already covers Go vendor; add `bin/` at root level

## Impact

- **All Go source files**: Import paths change from `github.com/jack-fin/bartering-games/backend/...` to `github.com/jack-fin/bartering-games/...`
- **Generated code**: templ `_templ.go` and sqlc `db/*.go` files must be regenerated after the move
- **CI/CD**: Workflow paths change; Docker build context changes
- **Developer tooling**: Taskfile, lefthook, and IDE configurations need path updates
- **vault-js build**: Output path reference changes
- **No runtime behavior changes**: This is purely structural — no API, database, or feature changes

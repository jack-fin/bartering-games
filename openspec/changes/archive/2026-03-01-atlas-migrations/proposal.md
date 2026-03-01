## Why

The backend has no database migration workflow yet. The Taskfile `migrate` and `generate:sqlc` commands are stubs, and `backend/migrations/` doesn't exist. Before any feature work that touches Postgres (users, game keys, trades), we need a repeatable, lintable migration pipeline so schema changes are versioned, reviewable, and safe to apply in both local dev and production.

## What Changes

- Add Atlas CLI configuration (`atlas.hcl`) pointing at the local Postgres instance from docker-compose
- Create a declarative HCL schema file (`backend/schema.hcl`) defining the desired database state — this is the source of truth for what the schema should look like
- Use `atlas migrate diff` to auto-generate versioned SQL migration files from the HCL schema into `backend/migrations/`
- Create the initial migration with a minimal `users` table placeholder (just `id` + `created_at`) to verify the pipeline end-to-end
- Wire real commands into the Taskfile: `task migrate` (apply), `task migrate:diff` (generate migration from HCL diff), `task migrate:lint` (CI validation)

## Capabilities

### New Capabilities
- `atlas-migrations`: Database migration pipeline using Atlas in hybrid mode (declarative HCL schema + auto-generated versioned SQL migrations), including configuration, initial migration, and Taskfile integration

### Modified Capabilities
- `task-runner`: Adding `migrate`, `migrate:diff`, and `migrate:lint` task definitions to replace the current stubs

## Impact

- **New files**: `backend/atlas.hcl`, `backend/schema.hcl`, `backend/migrations/` (auto-generated SQL migration + atlas.sum)
- **Modified files**: `Taskfile.yaml` (replace stub migrate task, add migrate:diff and migrate:lint)
- **Dependencies**: Atlas CLI must be installed locally (and in CI). No new Go module dependencies.
- **Infrastructure**: No production impact — this story only targets local dev. Production Atlas usage comes later with deployment stories.

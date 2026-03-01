## Context

The backend has a Postgres instance running via docker-compose (user: `bartering`, password: `bartering`, db: `bartering_dev`, port: `5432`). The `backend/migrations/` directory doesn't exist yet. The Taskfile has stub `migrate` and `generate:sqlc` tasks. The `backend/internal/storage/` directory exists with empty `db/` and `query/` subdirectories, ready for sqlc output once the schema is in place.

This change sets up the Atlas migration pipeline so all subsequent schema work (users, game keys, trades, sessions) has a consistent workflow.

## Goals / Non-Goals

**Goals:**
- Establish Atlas hybrid mode (declarative HCL schema + versioned SQL migrations) as the database schema workflow
- Create `backend/schema.hcl` as the single source of truth for desired database state
- Create `backend/atlas.hcl` config that connects to the local docker-compose Postgres
- Produce one initial migration with a minimal `users` table to validate the full pipeline (define schema → diff → apply → verify)
- Replace Taskfile stubs with real Atlas commands (`migrate`, `migrate:diff`, `migrate:lint`)

**Non-Goals:**
- Full user schema (columns beyond `id` + `created_at` come in later stories)
- Production deployment configuration (remote DB URLs, CI/CD Atlas integration)
- sqlc setup (separate story, though this migration creates the schema sqlc will read)
- Atlas Cloud or remote state — everything is local and file-based

## Decisions

### 1. Hybrid mode: declarative HCL schema + versioned migrations

Atlas supports pure declarative (`schema apply`) and pure versioned (hand-written SQL). We use the **hybrid** approach:

- `backend/schema.hcl` defines the desired state in Atlas HCL
- `atlas migrate diff` compares HCL against the migration directory and auto-generates versioned SQL
- `atlas migrate apply` runs the versioned migrations against the database

This gives us the best of both worlds: you edit the HCL to describe what you want, Atlas generates the exact DDL, and the SQL migration files are reviewable in PRs with a full audit trail.

**Alternative considered**: Pure declarative with `atlas schema apply`. Rejected because it skips migration files — no audit trail and harder to review in PRs.

**Alternative considered**: Pure versioned with hand-written SQL. Rejected because it doesn't take advantage of Atlas's schema diffing, reducing Atlas to a basic migration runner.

### 2. HCL over SQL for the declarative schema

Atlas supports both HCL and SQL as the declarative schema language. We use **HCL** because:
- It's Atlas's native format with the richest feature set
- Better support for Atlas-specific features (policies, checks, lifecycle hooks)
- Cleaner syntax for schema definitions vs. CREATE TABLE statements

**Alternative considered**: SQL schema file. Viable but less idiomatic for Atlas and lacks some HCL-specific features.

### 3. `atlas.hcl` and `schema.hcl` live in `backend/`

Both config files go in `backend/` alongside `go.mod`, keeping all backend concerns together. The migration directory is `backend/migrations/` (relative). Taskfile tasks use `dir: backend` so all paths stay relative to the backend directory.

### 4. Dev database URL from environment with sensible default

`atlas.hcl` will read `DATABASE_URL` from the environment, falling back to the docker-compose defaults (`postgres://bartering:bartering@localhost:5432/bartering_dev?sslmode=disable`). This avoids hardcoding credentials while keeping zero-config local dev working.

### 5. Minimal `users` table as pipeline validation

The initial `schema.hcl` defines `users` with just `id` (UUID, PK, `gen_random_uuid()` default) and `created_at` (timestamptz, default `now()`). This is intentionally minimal — it proves the pipeline works without committing to a full schema that will change in later stories.

### 6. Migration workflow for future schema changes

The developer workflow for schema changes will be:
1. Edit `backend/schema.hcl` to describe the desired state
2. Run `task migrate:diff -- <migration_name>` to auto-generate a SQL migration
3. Review the generated SQL in `backend/migrations/`
4. Run `task migrate` to apply
5. Commit both `schema.hcl` changes and the generated migration file

## Risks / Trade-offs

- **[Risk] Atlas CLI not installed locally** → Taskfile tasks will fail with a clear "command not found" error. Mitigation: Atlas is a single binary (`brew install ariga/tap/atlas` or `curl -sSf https://atlasgo.sh | sh`).
- **[Risk] docker-compose Postgres not running when migrate runs** → `atlas migrate apply` will fail with a connection error. Mitigation: `task dev` must be running first. This is expected and the error message is clear.
- **[Risk] atlas.sum checksum drift** → If someone edits a migration file without re-running `atlas migrate hash`, apply will refuse to run. Mitigation: `atlas migrate lint` in CI catches this. This is a safety feature.
- **[Risk] HCL schema and migrations diverge** → If someone hand-edits a migration without updating the HCL, the schema file becomes stale. Mitigation: always edit HCL first, then diff. CI can validate by checking `atlas migrate diff` produces no output.

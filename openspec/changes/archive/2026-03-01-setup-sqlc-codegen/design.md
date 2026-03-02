## Context

Atlas migrations are fully working — `schema.hcl` declares a `users` table, `backend/migrations/` has versioned SQL, and Postgres 17 runs in Docker Compose. The `backend/internal/storage/` directory exists with empty `db/` and `query/` subdirectories (`.gitkeep` placeholders). The Taskfile has a stub `generate:sqlc` task. No SQL driver or query tooling exists in `go.mod` yet.

sqlc reads `.sql` query files annotated with `-- name:` and `-- :one`/`:many`/`:exec` comments, and generates type-safe Go functions from them. It needs to know the database schema (to resolve column types) and the target Go package/driver.

## Goals / Non-Goals

**Goals:**
- Configure sqlc so that `sqlc generate` produces working Go code from annotated SQL files
- Establish the query file convention and directory layout that all future database queries will follow
- Add pgx/v5 as the database driver (the standard high-performance Postgres driver for Go)
- Validate the pipeline end-to-end with a seed query
- Wire the Taskfile so `task generate:sqlc` and `task generate` work

**Non-Goals:**
- Wiring a database connection pool into the server (`cmd/server/main.go` stays unchanged)
- Creating a real data access layer or repository pattern
- Writing production queries beyond a minimal seed query
- Integration tests with a real database (future story)
- Database connection configuration or environment variable handling

## Decisions

### 1. sqlc config at `backend/internal/storage/sqlc.yaml`

Place the sqlc config file inside the storage directory, colocated with the `query/` and `db/` directories it references. This keeps the storage concern self-contained. Paths in the config are relative to the config file location.

**Alternative considered:** Config at `backend/sqlc.yaml` (repo-level). This works but scatters config — the storage directory already exists as the home for database code. Colocating means `query/`, `db/`, and `sqlc.yaml` are siblings.

### 2. Use pgx/v5 as the SQL driver

pgx/v5 is the recommended high-performance Postgres driver for Go. sqlc has first-class support for it via `sql_package: "pgx/v5"`. This avoids `database/sql` wrapper overhead and gives access to Postgres-native types (UUID, timestamptz, arrays, JSONB) without manual type conversion.

**Alternative considered:** `database/sql` with `lib/pq` or `pgx/stdlib`. These add an abstraction layer with no benefit — we're Postgres-only and pgx's native interface is simpler and faster.

### 3. Point sqlc at Atlas migration files for schema

sqlc needs to understand the database schema to generate correct Go types. We'll point it at `../../migrations/*.sql` (the Atlas migration files). This is the simplest approach — the migrations are the source of truth for what the database actually looks like, and Atlas already generates them from `schema.hcl`.

**Alternative considered:** Pointing at `schema.hcl` directly — sqlc can't read HCL, only SQL. We could maintain a separate `schema.sql`, but that duplicates the Atlas schema and risks drift. Using the migration files means sqlc always sees the real schema.

### 4. Seed query: `GetUserByID` in `query/users.sql`

A minimal but realistic query that exercises the generation pipeline: selecting a user row by UUID primary key. This validates that sqlc correctly resolves column types from the migration files and generates a working Go function. It's a query we'll actually use, not throwaway.

**Alternative considered:** `SELECT 1` as a pure smoke test. Too trivial — doesn't validate type mapping (UUID, timestamptz) which is the main thing that could go wrong.

### 5. Generated Go package name: `db`

The generated code goes to `backend/internal/storage/db/` with package `db`. Short, conventional, and matches the directory name. Consumers import it as `db "github.com/jack-fin/bartering-games/backend/internal/storage/db"`.

### 6. Emit `sql.NullString`-style types disabled — use pointer types

sqlc supports two styles for nullable columns: `sql.NullXxx` wrapper types or Go pointer types (`*string`, `*time.Time`). We'll use pointer types (`emit_pointers_for_null_types: true`) — they're more ergonomic in Go and work naturally with pgx.

## Risks / Trade-offs

- **Migration file ordering matters for sqlc** → sqlc reads migration files in lexicographic order. Atlas names them with timestamps (`20260301...`), which sorts correctly. If a migration drops and recreates a table, sqlc sees the final state. This is fine.
- **sqlc binary must be installed** → Like `buf`, `sqlc` is a dev tool that must be on `$PATH`. Document installation alongside buf in the README (future story). CI will need it too.
- **Schema drift between HCL and migrations** → If someone edits `schema.hcl` but forgets to run `atlas migrate diff`, sqlc won't see the new columns. Mitigated by CI freshness checks on both generated outputs.
- **pgx/v5 added but not used yet** → The dependency exists in `go.mod` but nothing imports it until the server wires up a connection pool. `go mod tidy` would remove it. We'll keep it by having the generated sqlc code import it.

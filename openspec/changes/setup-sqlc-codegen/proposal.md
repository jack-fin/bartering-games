## Why

The Atlas migration pipeline and declarative schema (`schema.hcl`) are in place, producing a `users` table in Postgres. However, there is no way for Go code to query the database — no SQL driver, no query layer, and no type-safe data access. sqlc generates Go code from SQL queries, giving compile-time type safety and eliminating the boilerplate of manual `rows.Scan()` calls. Setting this up now unblocks every future story that needs database access (authentication, trades, library sync, etc.).

## What Changes

- Create `backend/internal/storage/sqlc.yaml` configuring sqlc with PostgreSQL engine, pgx/v5 driver, and output to `db/`
- Add a seed query file (`query/users.sql`) with a trivial query to validate the generation pipeline end-to-end
- Add `github.com/jackc/pgx/v5` as a Go dependency (the database driver sqlc will target)
- Wire `task generate:sqlc` to run `sqlc generate` (replacing the current stub)
- Ensure `task generate` runs both `buf generate` and `sqlc generate`
- Generated `db/` code committed to Git, matching the project convention for generated code

## Capabilities

### New Capabilities
- `sqlc-codegen`: sqlc configuration, query file conventions, code generation pipeline, and the pattern for adding new queries

### Modified Capabilities
- `task-runner`: `generate:sqlc` task wired to real command; `generate` task runs both proto and sqlc codegen

## Impact

- **Backend**: New config file at `backend/internal/storage/sqlc.yaml`, seed query in `query/users.sql`, generated Go code in `db/`. New `pgx/v5` dependency in `go.mod`.
- **Taskfile**: `generate:sqlc` stub replaced with real command. `generate` meta-task runs both codegen steps.
- **CI**: Generated code freshness check will now cover sqlc output in addition to protobuf output.

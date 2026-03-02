## 1. sqlc Configuration

- [x] 1.1 Create `backend/internal/storage/sqlc.yaml` with PostgreSQL engine, pgx/v5 driver, schema pointing at `../../migrations/*.sql`, queries at `query/`, output to `db/`, and `emit_pointers_for_null_types: true`
- [x] 1.2 Add `github.com/jackc/pgx/v5` dependency to `backend/go.mod`

## 2. Seed Query

- [x] 2.1 Create `backend/internal/storage/query/users.sql` with a `GetUserByID` query (`:one`) selecting by UUID primary key

## 3. Code Generation

- [x] 3.1 Run `sqlc generate` from `backend/internal/storage/` and verify Go code appears in `db/`
- [x] 3.2 Verify generated code compiles: `go build ./internal/storage/db/...`

## 4. Taskfile Wiring

- [x] 4.1 Replace `generate:sqlc` stub in `Taskfile.yaml` with `sqlc generate` running from `backend/internal/storage/`

## 5. Verification

- [x] 5.1 Run `task generate` — both proto and sqlc codegen succeed
- [x] 5.2 Run `task test:go` — all tests pass
- [x] 5.3 Run `task lint` — no lint errors

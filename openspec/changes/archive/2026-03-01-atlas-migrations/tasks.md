## 1. Atlas Configuration

- [x] 1.1 Create `backend/atlas.hcl` with dev database URL (env var `DATABASE_URL` with default `postgres://bartering:bartering@localhost:5432/bartering_dev?sslmode=disable`), migration directory (`file://migrations`), and schema source (`file://schema.hcl`)
- [x] 1.2 Create `backend/schema.hcl` with a minimal `users` table: `id` (uuid, PK, default `gen_random_uuid()`) and `created_at` (timestamptz, default `now()`)

## 2. Initial Migration

- [x] 2.1 Run `atlas migrate diff` to auto-generate the initial versioned SQL migration from the HCL schema into `backend/migrations/`
- [x] 2.2 Verify the generated migration SQL is correct (CREATE TABLE with expected columns, types, defaults)
- [x] 2.3 Run `atlas migrate apply` against local Postgres and verify the `users` table exists with the correct schema

## 3. Taskfile Integration

- [x] 3.1 Replace the stub `migrate` task with `atlas migrate apply --env local` running from `backend/`
- [x] 3.2 Add `migrate:diff` task that runs `atlas migrate diff` from `backend/`, accepting a migration name argument
- ~~3.3 `migrate:lint` dropped — requires Atlas Pro~~

## 4. Verification

- [x] 4.1 Run `task migrate` against a clean local Postgres and confirm the users table is created
- [x] 4.2 Run `task migrate` a second time and confirm it's idempotent (no errors, no duplicate changes)

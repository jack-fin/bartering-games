### Requirement: sqlc configuration file
The backend SHALL have a sqlc configuration file at `backend/internal/storage/sqlc.yaml` that defines the PostgreSQL engine, pgx/v5 driver, query source directory, and Go code output directory.

#### Scenario: Config file is valid
- **WHEN** a developer runs `sqlc generate` from `backend/internal/storage/`
- **THEN** the command succeeds without configuration errors

#### Scenario: Config targets pgx/v5
- **WHEN** the sqlc config is inspected
- **THEN** the `sql_package` is set to `pgx/v5`

#### Scenario: Config reads schema from migrations
- **WHEN** sqlc resolves the database schema
- **THEN** it reads from the Atlas migration files in `backend/migrations/`

### Requirement: Query file conventions
SQL query files SHALL live in `backend/internal/storage/query/` and use sqlc annotation comments (`-- name:` and `:one`/`:many`/`:exec`/`:execrows`) to define named Go functions.

#### Scenario: Query file produces Go function
- **WHEN** a `.sql` file in `query/` contains `-- name: GetUserByID :one` followed by a SELECT statement
- **THEN** `sqlc generate` produces a Go function `GetUserByID` in the `db` package

#### Scenario: Query files are organized by entity
- **WHEN** new database entities are added
- **THEN** their queries go in separate files named after the entity (e.g., `users.sql`, `trades.sql`)

### Requirement: Generated Go code output
sqlc SHALL generate Go code into `backend/internal/storage/db/` with package name `db`.

#### Scenario: Generated package is importable
- **WHEN** a Go file imports `github.com/jack-fin/bartering-games/backend/internal/storage/db`
- **THEN** the import resolves and the package compiles

#### Scenario: Generated code uses pointer types for nullable columns
- **WHEN** a query returns a nullable column
- **THEN** the generated Go struct field is a pointer type (e.g., `*string`) rather than `sql.NullString`

### Requirement: Generated code committed to Git
Generated sqlc code in `backend/internal/storage/db/` SHALL be committed to the repository, matching the project convention for generated code.

#### Scenario: CI freshness check
- **WHEN** CI runs `sqlc generate` and checks `git diff`
- **THEN** there are no uncommitted changes in `backend/internal/storage/db/`

### Requirement: Seed query for pipeline validation
The initial setup SHALL include a seed query file `backend/internal/storage/query/users.sql` with at least one query that exercises type mapping (UUID, timestamptz).

#### Scenario: Seed query generates valid Go code
- **WHEN** a developer runs `sqlc generate`
- **THEN** `backend/internal/storage/db/` contains Go files with a function for the seed query
- **AND** the generated code compiles without errors

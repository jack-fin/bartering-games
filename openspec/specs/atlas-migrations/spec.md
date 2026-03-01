## ADDED Requirements

### Requirement: Atlas configuration file
The project SHALL have an `atlas.hcl` configuration file in `backend/` that defines the Atlas project settings, including the database connection URL and migration directory path.

#### Scenario: Config uses environment variable with default
- **WHEN** `DATABASE_URL` environment variable is not set
- **THEN** Atlas uses the default connection string `postgres://bartering:bartering@localhost:5432/bartering_dev?sslmode=disable`

#### Scenario: Config uses environment variable when set
- **WHEN** `DATABASE_URL` environment variable is set to a custom connection string
- **THEN** Atlas uses the custom connection string

#### Scenario: Config references migration directory
- **WHEN** Atlas reads the configuration
- **THEN** the migration directory is set to `file://migrations` (relative to `backend/`)

### Requirement: Declarative HCL schema file
The project SHALL have a `schema.hcl` file in `backend/` that defines the desired database schema state in Atlas HCL format. This file is the source of truth for what the database schema should look like.

#### Scenario: Schema file defines tables
- **WHEN** a developer reads `backend/schema.hcl`
- **THEN** it contains the complete desired database schema in Atlas HCL syntax

#### Scenario: Schema file is diffable
- **WHEN** a developer runs `atlas migrate diff` referencing the schema file
- **THEN** Atlas generates a SQL migration representing the diff between the current migration state and the desired HCL schema

### Requirement: Initial users table migration
The initial migration SHALL create a `users` table with an `id` column (UUID primary key with `gen_random_uuid()` default) and a `created_at` column (timestamptz with `now()` default).

#### Scenario: Initial migration creates users table
- **WHEN** `atlas migrate apply` runs against an empty database
- **THEN** a `users` table exists with `id` (uuid, PK, default gen_random_uuid()) and `created_at` (timestamptz, default now()) columns

#### Scenario: Users table id is auto-generated
- **WHEN** a row is inserted into `users` without specifying `id`
- **THEN** a UUID is automatically generated for the `id` column

#### Scenario: Users table created_at is auto-set
- **WHEN** a row is inserted into `users` without specifying `created_at`
- **THEN** `created_at` is automatically set to the current timestamp

### Requirement: Versioned migration files
Atlas SHALL generate versioned SQL migration files in `backend/migrations/`. Each migration file SHALL contain the SQL DDL statements and the directory SHALL include an `atlas.sum` checksum file.

#### Scenario: Migration files are plain SQL
- **WHEN** a developer inspects a file in `backend/migrations/`
- **THEN** it contains standard SQL DDL statements (CREATE TABLE, ALTER TABLE, etc.)

#### Scenario: Checksum file exists
- **WHEN** a developer lists `backend/migrations/`
- **THEN** an `atlas.sum` file is present that validates the integrity of migration files

### Requirement: Migration apply is idempotent
Running `atlas migrate apply` multiple times against the same database SHALL NOT fail or produce duplicate changes. Atlas tracks which migrations have been applied via its revision table.

#### Scenario: Repeat apply is safe
- **WHEN** `atlas migrate apply` runs against a database where all migrations are already applied
- **THEN** the command succeeds with no changes applied

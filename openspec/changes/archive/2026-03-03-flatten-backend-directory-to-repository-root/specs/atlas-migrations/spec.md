## MODIFIED Requirements

### Requirement: Atlas configuration file
The project SHALL have an `atlas.hcl` configuration file at the repository root that defines the Atlas project settings, including the database connection URL and migration directory path.

#### Scenario: Config uses environment variable with default
- **WHEN** `DATABASE_URL` environment variable is not set
- **THEN** Atlas uses the default connection string `postgres://bartering:bartering@localhost:5432/bartering_dev?sslmode=disable`

#### Scenario: Config uses environment variable when set
- **WHEN** `DATABASE_URL` environment variable is set to a custom connection string
- **THEN** Atlas uses the custom connection string

#### Scenario: Config references migration directory
- **WHEN** Atlas reads the configuration
- **THEN** the migration directory is set to `file://migrations` (relative to repo root)

### Requirement: Declarative HCL schema file
The project SHALL have a `schema.hcl` file at the repository root that defines the desired database schema state in Atlas HCL format.

#### Scenario: Schema file defines tables
- **WHEN** a developer reads `schema.hcl` at the repo root
- **THEN** it contains the complete desired database schema in Atlas HCL syntax

#### Scenario: Schema file is diffable
- **WHEN** a developer runs `atlas migrate diff` referencing the schema file
- **THEN** Atlas generates a SQL migration representing the diff between the current migration state and the desired HCL schema

### Requirement: Versioned migration files
Atlas SHALL generate versioned SQL migration files in `migrations/` at the repository root. Each migration file SHALL contain the SQL DDL statements and the directory SHALL include an `atlas.sum` checksum file.

#### Scenario: Migration files are plain SQL
- **WHEN** a developer inspects a file in `migrations/`
- **THEN** it contains standard SQL DDL statements (CREATE TABLE, ALTER TABLE, etc.)

#### Scenario: Checksum file exists
- **WHEN** a developer lists `migrations/`
- **THEN** an `atlas.sum` file is present that validates the integrity of migration files

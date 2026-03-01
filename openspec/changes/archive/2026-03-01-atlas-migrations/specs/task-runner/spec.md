## MODIFIED Requirements

### Requirement: Migrate task
The Taskfile SHALL define a `migrate` task that runs `atlas migrate apply` from the `backend/` directory to apply pending database migrations.

#### Scenario: Migrate task applies migrations
- **WHEN** a developer runs `task migrate`
- **THEN** `atlas migrate apply` executes from the `backend/` directory using the `atlas.hcl` configuration

#### Scenario: Migrate task uses atlas config
- **WHEN** a developer runs `task migrate`
- **THEN** Atlas reads connection settings from `backend/atlas.hcl`

## ADDED Requirements

### Requirement: Migrate diff task
The Taskfile SHALL define a `migrate:diff` task that runs `atlas migrate diff` to auto-generate a new versioned SQL migration from the difference between the current migration state and the desired HCL schema.

#### Scenario: Diff generates migration file
- **WHEN** a developer modifies `backend/schema.hcl` and runs `task migrate:diff -- <name>`
- **THEN** a new SQL migration file is created in `backend/migrations/` containing the DDL to reach the desired state

#### Scenario: Diff with no changes
- **WHEN** a developer runs `task migrate:diff` and the HCL schema matches the current migration state
- **THEN** no new migration file is generated

### Requirement: Migrate lint task
The Taskfile SHALL define a `migrate:lint` task that runs `atlas migrate lint` to validate migration files for safety issues (destructive changes, checksum integrity, dependency ordering).

#### Scenario: Lint detects issues
- **WHEN** a migration file contains a destructive change and a developer runs `task migrate:lint`
- **THEN** the command reports the issue and exits with a non-zero status code

#### Scenario: Lint passes clean migrations
- **WHEN** all migration files are valid and checksums match and a developer runs `task migrate:lint`
- **THEN** the command exits successfully

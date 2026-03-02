## MODIFIED Requirements

### Requirement: Generate tasks
The Taskfile SHALL define `generate`, `generate:proto`, and `generate:sqlc` tasks.

#### Scenario: Aggregate generate task runs sub-tasks
- **WHEN** a developer runs `task generate`
- **THEN** both `generate:proto` and `generate:sqlc` execute

#### Scenario: Proto codegen runs buf generate
- **WHEN** a developer runs `task generate:proto`
- **THEN** `buf generate` executes from the `proto/` directory and generates code in `backend/gen/` and `frontend/gen/`

#### Scenario: Proto codegen working directory
- **WHEN** a developer runs `task generate:proto`
- **THEN** the command executes from the `proto/` directory

#### Scenario: sqlc codegen runs sqlc generate
- **WHEN** a developer runs `task generate:sqlc`
- **THEN** `sqlc generate` executes from `backend/internal/storage/` and generates Go code in `backend/internal/storage/db/`

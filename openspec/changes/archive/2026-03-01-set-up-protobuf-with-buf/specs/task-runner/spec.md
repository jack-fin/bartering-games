## MODIFIED Requirements

### Requirement: Proto codegen
The Taskfile SHALL define a `generate:proto` task that runs `buf generate` from the `proto/` directory.

#### Scenario: Proto codegen runs buf generate
- **WHEN** a developer runs `task generate:proto`
- **THEN** `buf generate` executes from the `proto/` directory and generates code in `backend/gen/` and `frontend/gen/`

#### Scenario: Proto codegen working directory
- **WHEN** a developer runs `task generate:proto`
- **THEN** the command executes from the `proto/` directory

### Requirement: Lint task runs sub-linters
The Taskfile SHALL define a `lint:proto` task that runs `buf lint` from the `proto/` directory.

#### Scenario: Proto lint runs buf lint
- **WHEN** a developer runs `task lint:proto`
- **THEN** `buf lint` executes from the `proto/` directory

#### Scenario: Proto lint working directory
- **WHEN** a developer runs `task lint:proto`
- **THEN** the command executes from the `proto/` directory

#### Scenario: Proto lint exits non-zero on violations
- **WHEN** a proto file has lint violations and a developer runs `task lint:proto`
- **THEN** the task exits with a non-zero status code

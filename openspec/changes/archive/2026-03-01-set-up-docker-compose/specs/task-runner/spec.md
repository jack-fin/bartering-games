## MODIFIED Requirements

### Requirement: Dev task
The Taskfile SHALL define a `dev` task that starts the local development environment by running `docker compose up`.

#### Scenario: Dev task starts compose services
- **WHEN** a developer runs `task dev`
- **THEN** `docker compose up` executes and all local dev services start

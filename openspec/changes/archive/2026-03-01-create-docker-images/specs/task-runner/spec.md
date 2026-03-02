## ADDED Requirements

### Requirement: Docker build task
The Taskfile SHALL define a `docker:build` task that builds both the backend and frontend Docker images locally.

#### Scenario: Docker build task builds both images
- **WHEN** a developer runs `task docker:build`
- **THEN** both `bartering-backend` and `bartering-frontend` images are built via `docker build`

#### Scenario: Docker build task runs from repo root
- **WHEN** a developer runs `task docker:build`
- **THEN** the build commands execute with correct context paths (`./backend` and `./frontend`)

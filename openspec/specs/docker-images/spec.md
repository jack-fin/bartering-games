## ADDED Requirements

### Requirement: Backend Dockerfile exists
The repository SHALL contain a `backend/Dockerfile` that produces a production-ready container image for the Go server.

#### Scenario: Backend image builds successfully
- **WHEN** a developer runs `docker build -t bartering-backend ./backend`
- **THEN** the build completes without errors

#### Scenario: Backend image uses multi-stage build
- **WHEN** the backend image is built
- **THEN** the final image SHALL NOT contain Go toolchain, build tools, or source code

#### Scenario: Backend binary is statically linked
- **WHEN** the Go binary is compiled in the build stage
- **THEN** it SHALL be compiled with `CGO_ENABLED=0` and `GOOS=linux`

#### Scenario: Backend runs as non-root
- **WHEN** a container is started from the backend image
- **THEN** the process SHALL run as a non-root user (UID != 0)

#### Scenario: Backend image declares a health check
- **WHEN** the backend image is inspected
- **THEN** it SHALL have a `HEALTHCHECK` instruction targeting the `/healthz` endpoint

### Requirement: Frontend Dockerfile exists
The repository SHALL contain a `frontend/Dockerfile` that produces a production-ready container image for the SvelteKit adapter-node server.

#### Scenario: Frontend image builds successfully
- **WHEN** a developer runs `docker build -t bartering-frontend ./frontend`
- **THEN** the build completes without errors

#### Scenario: Frontend image uses multi-stage build
- **WHEN** the frontend image is built
- **THEN** the final image SHALL NOT contain pnpm, build tooling, or raw source files

#### Scenario: Frontend dependencies installed with frozen lockfile
- **WHEN** the frontend build stage runs
- **THEN** pnpm SHALL be invoked with `--frozen-lockfile` to ensure reproducible installs

#### Scenario: Frontend runs as non-root
- **WHEN** a container is started from the frontend image
- **THEN** the process SHALL run as a non-root user (UID != 0)

#### Scenario: Frontend image declares a health check
- **WHEN** the frontend image is inspected
- **THEN** it SHALL have a `HEALTHCHECK` instruction

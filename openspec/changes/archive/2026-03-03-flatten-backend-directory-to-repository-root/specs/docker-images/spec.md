## MODIFIED Requirements

### Requirement: Backend Dockerfile exists
The repository SHALL contain a `Dockerfile` at the repository root (not `backend/Dockerfile`) that produces a production-ready container image for the Go server. The image SHALL include embedded static assets (CSS, JavaScript, lib scripts) compiled into the Go binary.

#### Scenario: Backend image builds successfully
- **WHEN** a developer runs `docker build -t bartering-backend .`
- **THEN** the build completes without errors (build context is the repo root)

#### Scenario: Dockerfile COPY paths reference root-level Go files
- **WHEN** the Dockerfile copies `go.mod`, `go.sum`, source code
- **THEN** COPY paths SHALL reference root-level paths (`go.mod`, `cmd/`, `internal/`) not `backend/` prefixed paths

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

#### Scenario: Static assets are served from the image
- **WHEN** a container is started and a client requests `/static/styles.css`
- **THEN** the Go binary serves the embedded static asset without requiring files on the filesystem

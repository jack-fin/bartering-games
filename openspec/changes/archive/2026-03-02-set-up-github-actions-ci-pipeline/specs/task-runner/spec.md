## MODIFIED Requirements

### Requirement: Integration tests task runs real tests
The Taskfile SHALL define a `test:int` task that runs `go test -tags=integration ./...` from the `backend/` directory (not a stub).

#### Scenario: Integration tests run with real Postgres
- **WHEN** a developer runs `task test:int` with Docker available
- **THEN** `go test -tags=integration ./...` executes from the `backend/` directory and testcontainers starts a real Postgres instance for the tests

#### Scenario: Integration tests exit non-zero on failure
- **WHEN** one or more integration tests fail
- **THEN** `task test:int` exits with a non-zero status code

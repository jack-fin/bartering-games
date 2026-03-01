## MODIFIED Requirements

### Requirement: Server main uses rpc import alias
The server entry point (`backend/cmd/server/main.go`) SHALL import the generated Connect package with the `rpc` alias, consistent with the project-wide convention.

#### Scenario: Handler mounting uses rpc alias
- **WHEN** `cmd/server/main.go` mounts Connect service handlers
- **THEN** the handler constructor call uses the `rpc.` prefix (e.g., `rpc.NewHealthServiceHandler(...)`)
- **AND** the server starts and serves health checks identically to before the alias change

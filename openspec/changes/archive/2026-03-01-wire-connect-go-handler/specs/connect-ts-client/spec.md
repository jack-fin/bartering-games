## ADDED Requirements

### Requirement: Connect transport setup
The frontend SHALL have a Connect transport client in `src/lib/api/` that creates a web transport configured to talk to the backend API server.

#### Scenario: Transport uses configurable base URL
- **WHEN** the transport is initialized
- **THEN** it reads the backend URL from an environment variable with a default of `http://localhost:8080` for local development

#### Scenario: Transport is reusable
- **WHEN** multiple service clients are needed (e.g., HealthService, future services)
- **THEN** they all share the same transport instance

### Requirement: Connect npm dependencies
The frontend SHALL include `@connectrpc/connect` and `@connectrpc/connect-web` as dependencies.

#### Scenario: Dependencies are installed
- **WHEN** a developer runs `pnpm install` in the `frontend/` directory
- **THEN** `@connectrpc/connect` and `@connectrpc/connect-web` are available for import

### Requirement: Typed service client export
The frontend API module SHALL export a typed client for `HealthService` created from the generated service definition and the shared transport.

#### Scenario: Health client is importable
- **WHEN** a SvelteKit page or component imports from the API module
- **THEN** it can access a typed `HealthService` client with autocomplete for the `check()` method

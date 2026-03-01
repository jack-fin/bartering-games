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

### Requirement: SvelteKit $gen path alias for generated code
The SvelteKit configuration SHALL define a `$gen` path alias that resolves to the `frontend/gen/` directory, following the same convention as the built-in `$lib` alias.

#### Scenario: Alias is configured
- **WHEN** a developer inspects `frontend/svelte.config.js`
- **THEN** `kit.alias` includes `$gen` mapped to `./gen` and `$gen/*` mapped to `./gen/*`

#### Scenario: TypeScript resolves $gen imports
- **WHEN** a TypeScript file imports from `$gen/bartering/v1/health_pb.js`
- **THEN** the import resolves correctly during both development (`vite dev`) and build (`vite build`)
- **AND** the TypeScript compiler reports no errors

### Requirement: Frontend imports use $gen alias
All frontend source files that import from the generated code directory SHALL use the `$gen` path alias instead of relative paths.

#### Scenario: API client uses $gen import
- **WHEN** `src/lib/api/index.ts` imports the `HealthService` definition
- **THEN** the import path is `$gen/bartering/v1/health_pb.js` (not a relative path like `../../../gen/...`)

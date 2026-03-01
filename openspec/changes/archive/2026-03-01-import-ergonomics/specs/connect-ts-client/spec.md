## MODIFIED Requirements

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

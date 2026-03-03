## ADDED Requirements

### Requirement: vault-js module structure
The repository SHALL contain a `vault-js/` directory at the repo root with TypeScript source files, a `package.json`, and a `tsconfig.json`.

#### Scenario: Module directory exists
- **WHEN** a developer inspects the repository root
- **THEN** `vault-js/` exists with `package.json`, `tsconfig.json`, and `src/` directory

#### Scenario: Zero runtime dependencies
- **WHEN** a developer inspects `vault-js/package.json`
- **THEN** the `dependencies` field is empty or absent — all dependencies are `devDependencies`

### Requirement: esbuild compilation
The vault-js module SHALL compile to a single JavaScript file at `backend/static/vault.js` using esbuild. The output SHALL be an IIFE bundle with no external imports.

#### Scenario: Build produces single output file
- **WHEN** a developer runs the build command from `vault-js/`
- **THEN** `backend/static/vault.js` is created as a single self-contained JavaScript file

#### Scenario: Output is IIFE format
- **WHEN** the compiled `vault.js` is inspected
- **THEN** it is wrapped in an immediately-invoked function expression with no `import` or `require` statements

#### Scenario: Output targets modern browsers
- **WHEN** esbuild compiles the vault module
- **THEN** the target is set to modern browsers that support WebCrypto (no polyfills needed)

### Requirement: TypeScript strict mode
The vault-js module SHALL use TypeScript with strict type checking enabled.

#### Scenario: Type checking passes
- **WHEN** a developer runs `pnpm tsc --noEmit` from the `vault-js/` directory
- **THEN** no type errors are reported

### Requirement: Vault scaffold with exported interface
The vault-js module SHALL export a namespace or object that exposes the vault API surface. The initial scaffold SHALL include stub functions for: key derivation, encryption, decryption, and escrow key generation. Stub implementations SHALL throw a "not implemented" error.

#### Scenario: Vault API surface exists
- **WHEN** `vault.js` is loaded in a browser
- **THEN** the vault API is accessible (e.g., via a global `Vault` object or similar)

#### Scenario: Stubs throw not-implemented errors
- **WHEN** a stub function is called
- **THEN** it throws an error indicating the operation is not yet implemented

### Requirement: HTMX form interception scaffold
The vault-js module SHALL include a scaffold for HTMX form interception that listens to `htmx:configRequest` events. The scaffold SHALL identify forms that require vault operations (via a `data-vault-*` attribute or similar marker) and provide a hook point for encryption logic.

#### Scenario: Event listener is registered
- **WHEN** `vault.js` is loaded in a browser with HTMX present
- **THEN** an event listener for `htmx:configRequest` is registered on the document body

#### Scenario: Non-vault forms are ignored
- **WHEN** an HTMX request fires for a form without vault markers
- **THEN** the event listener takes no action and the request proceeds normally

#### Scenario: Vault-marked forms trigger interception
- **WHEN** an HTMX request fires for a form with a vault marker attribute
- **THEN** the interception scaffold is invoked (stub: logs a message or throws not-implemented)

### Requirement: Test setup with Vitest
The vault-js module SHALL have Vitest configured for unit testing with a DOM environment (jsdom or happy-dom) that provides WebCrypto APIs.

#### Scenario: Tests run successfully
- **WHEN** a developer runs `pnpm vitest run` from the `vault-js/` directory
- **THEN** the test suite executes and reports results

#### Scenario: WebCrypto is available in tests
- **WHEN** a test accesses `globalThis.crypto.subtle`
- **THEN** the WebCrypto SubtleCrypto API is available

### Requirement: Compiled vault.js committed to Git
The compiled `backend/static/vault.js` SHALL be committed to the Git repository, following the project's convention of committing generated code.

#### Scenario: vault.js is present after clone
- **WHEN** a developer clones the repository
- **THEN** `backend/static/vault.js` exists without needing to run the vault-js build

#### Scenario: Compiled output matches source
- **WHEN** the vault-js build runs on unchanged TypeScript source
- **THEN** `git diff` shows no changes to `backend/static/vault.js`

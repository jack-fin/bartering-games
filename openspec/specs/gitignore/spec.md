### Requirement: Root .gitignore covers Go artifacts
The `.gitignore` at the repository root SHALL ignore Go build and test artifacts.

#### Scenario: Go binaries and build output are ignored
- **WHEN** a Go binary is built via `go build -o bin/server ./cmd/server/`
- **THEN** the `bin/` directory at the repo root SHALL be excluded from Git tracking
- **AND** the `vendor/` directory SHALL be ignored (Go vendoring; this also means `cmd/server/static/vendor/` would be ignored, which is why it was renamed to `lib/`)

### Requirement: Root .gitignore covers Node/TypeScript artifacts
The `.gitignore` SHALL ignore Node.js and TypeScript build artifacts.

#### Scenario: node_modules and build output are ignored
- **WHEN** `pnpm install` is run in `frontend/`
- **THEN** `node_modules/` directories SHALL be excluded from Git tracking
- **AND** SvelteKit build output (`.svelte-kit/`, `build/`) SHALL be ignored

### Requirement: Root .gitignore covers non-shared IDE and OS files
The `.gitignore` SHALL ignore IDE-specific files that are not shared across the team. The `.vscode/` directory is committed as the shared IDE configuration and SHALL NOT be ignored.

#### Scenario: Non-shared IDE files are ignored
- **WHEN** a developer uses JetBrains or Vim
- **THEN** `.idea/` and `*.swp` SHALL be excluded from Git tracking

#### Scenario: OS metadata files are ignored
- **WHEN** a developer works on macOS or Windows
- **THEN** `.DS_Store` and `Thumbs.db` SHALL be excluded from Git tracking

#### Scenario: VS Code configuration is tracked
- **WHEN** `.vscode/` exists in the repository
- **THEN** it SHALL NOT be listed in `.gitignore`

### Requirement: Root .gitignore covers Docker artifacts
The `.gitignore` SHALL ignore Docker-related ephemeral files.

#### Scenario: Docker build context artifacts are ignored
- **WHEN** Docker images are built locally
- **THEN** Docker override files (`docker-compose.override.yml`) SHALL be ignored

### Requirement: Root .gitignore covers environment files
The `.gitignore` SHALL ignore environment variable files to prevent secret leakage.

#### Scenario: Env files are ignored
- **WHEN** a `.env` file is created for local development
- **THEN** `.env`, `.env.local`, and `.env.*.local` files SHALL be excluded from Git tracking

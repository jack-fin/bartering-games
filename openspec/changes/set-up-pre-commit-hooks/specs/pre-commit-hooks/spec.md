## ADDED Requirements

### Requirement: lefthook configuration exists at repo root
The repo SHALL contain a `lefthook.yml` file at the repository root that configures pre-commit hooks for all three linting tools.

#### Scenario: Config file is present
- **WHEN** a developer clones the repository
- **THEN** `lefthook.yml` exists at the repo root and is tracked in git

### Requirement: Pre-commit runs golangci-lint on staged Go files
The pre-commit hook SHALL run `golangci-lint run` against staged `.go` files only.

#### Scenario: Go files staged
- **WHEN** one or more `.go` files are staged and the developer runs `git commit`
- **THEN** `golangci-lint run` executes against only those staged files

#### Scenario: No Go files staged
- **WHEN** no `.go` files are staged and the developer runs `git commit`
- **THEN** the golangci-lint step is skipped entirely

#### Scenario: Go lint violation blocks commit
- **WHEN** a staged `.go` file has a lint violation
- **THEN** the commit is aborted and the violation is reported to the developer

### Requirement: Pre-commit runs ESLint and Prettier on staged TS/Svelte/JSON files
The pre-commit hook SHALL run ESLint and Prettier check against staged `.ts`, `.svelte`, and `.json` files only.

#### Scenario: TypeScript/Svelte/JSON files staged
- **WHEN** one or more `.ts`, `.svelte`, or `.json` files are staged and the developer runs `git commit`
- **THEN** ESLint and Prettier check execute against only those staged files

#### Scenario: No TS/Svelte/JSON files staged
- **WHEN** no `.ts`, `.svelte`, or `.json` files are staged
- **THEN** the ESLint and Prettier steps are skipped entirely

#### Scenario: TS lint violation blocks commit
- **WHEN** a staged `.ts` or `.svelte` file has a lint or formatting violation
- **THEN** the commit is aborted and the violation is reported to the developer

### Requirement: Pre-commit runs buf lint on staged proto files
The pre-commit hook SHALL run `buf lint` when any `.proto` file is staged.

#### Scenario: Proto file staged
- **WHEN** one or more `.proto` files are staged and the developer runs `git commit`
- **THEN** `buf lint` executes from the `proto/` directory

#### Scenario: No proto files staged
- **WHEN** no `.proto` files are staged
- **THEN** the buf lint step is skipped entirely

#### Scenario: Proto lint violation blocks commit
- **WHEN** a staged `.proto` file has a lint violation
- **THEN** the commit is aborted and the violation is reported to the developer

### Requirement: Hook installation is idempotent
Running the install command multiple times SHALL produce the same result without error.

#### Scenario: Install run twice
- **WHEN** a developer runs `task hooks:install` more than once
- **THEN** the second run succeeds and the hooks remain correctly installed

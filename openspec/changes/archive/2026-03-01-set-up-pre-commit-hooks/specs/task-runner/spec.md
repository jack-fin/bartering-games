## ADDED Requirements

### Requirement: deps:check task
The Taskfile SHALL define a `deps:check` task that verifies all required developer tools are installed, printing a pass/fail line for each with an install hint for any that are missing.

#### Scenario: All tools present
- **WHEN** a developer runs `task deps:check` and all required tools are installed
- **THEN** each tool is listed with a checkmark and its version, and the task exits zero

#### Scenario: A tool is missing
- **WHEN** a developer runs `task deps:check` and one or more tools are not installed
- **THEN** missing tools are listed with an install hint and the task exits non-zero

#### Scenario: Required tools covered
- **WHEN** a developer runs `task deps:check`
- **THEN** it checks for: `go`, `node`, `pnpm`, `task`, `docker`, `colima`, `buf`, `atlas`, `sqlc`, `golangci-lint`, and `lefthook`

### Requirement: hooks:install task
The Taskfile SHALL define a `hooks:install` task that installs the lefthook pre-commit hooks into the local git repository.

#### Scenario: Install task runs lefthook install
- **WHEN** a developer runs `task hooks:install`
- **THEN** `lefthook install` executes and the pre-commit hook is written to `.git/hooks/pre-commit`

#### Scenario: Install task is idempotent
- **WHEN** a developer runs `task hooks:install` more than once
- **THEN** each run succeeds without error and hooks remain correctly installed

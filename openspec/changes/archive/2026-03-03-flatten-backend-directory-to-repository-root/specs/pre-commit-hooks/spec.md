## MODIFIED Requirements

### Requirement: Pre-commit runs golangci-lint on staged Go files
The pre-commit hook SHALL run `golangci-lint run` against staged `.go` files only. The glob and root SHALL target the repository root, not `backend/`.

#### Scenario: Go files staged
- **WHEN** one or more `.go` files are staged and the developer runs `git commit`
- **THEN** `golangci-lint run` executes with `glob: "**/*.go"` and `root: "."` (not `backend/`)

#### Scenario: No Go files staged
- **WHEN** no `.go` files are staged and the developer runs `git commit`
- **THEN** the golangci-lint step is skipped entirely

#### Scenario: Go lint violation blocks commit
- **WHEN** a staged `.go` file has a lint violation
- **THEN** the commit is aborted and the violation is reported to the developer

## MODIFIED Requirements

### Requirement: Pre-commit runs buf lint and breaking check on staged proto files
The pre-commit hook SHALL run both `buf lint` and `buf breaking --against .git#branch=main` when any `.proto` file is staged.

#### Scenario: Proto file staged — lint passes, no breaking changes
- **WHEN** one or more `.proto` files are staged and the developer runs `git commit`
- **THEN** both `buf lint` and `buf breaking` execute from the `proto/` directory and both pass

#### Scenario: Proto lint violation blocks commit
- **WHEN** a staged `.proto` file has a lint violation
- **THEN** the commit is aborted and the violation is reported to the developer

#### Scenario: Breaking proto change blocks commit
- **WHEN** a staged `.proto` file introduces a backward-incompatible change relative to `main`
- **THEN** the commit is aborted and the breaking change is reported to the developer

#### Scenario: Intentional breaking change bypass
- **WHEN** a developer intentionally introduces a breaking proto change and runs `LEFTHOOK_SKIP=lint-proto-breaking git commit`
- **THEN** the breaking check is skipped and the commit proceeds (buf lint still runs)

#### Scenario: No proto files staged
- **WHEN** no `.proto` files are staged
- **THEN** both buf steps are skipped entirely

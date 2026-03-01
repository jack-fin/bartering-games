## ADDED Requirements

### Requirement: Buf module configuration
The repository SHALL contain a `proto/buf.yaml` file using Buf v2 format that defines a module named `buf.build/bartering-games/bartering` with a dependency on `buf.build/googleapis/googleapis` for well-known types.

#### Scenario: buf.yaml is valid
- **WHEN** a developer runs `buf config ls-modules` from the `proto/` directory
- **THEN** the module is listed without errors

#### Scenario: Buf dependencies resolve
- **WHEN** a developer runs `buf dep update` from the `proto/` directory
- **THEN** dependencies resolve and `buf.lock` is created or updated

### Requirement: Buf lint configuration
The `proto/buf.yaml` SHALL configure Buf linting with the `DEFAULT` category enabled.

#### Scenario: Lint passes on well-formed protos
- **WHEN** a developer runs `buf lint` from the `proto/` directory with all proto files following conventions
- **THEN** the command exits with status 0 and no errors

#### Scenario: Lint catches violations
- **WHEN** a proto file uses an uppercase field name (e.g., `string PageToken = 1;`)
- **THEN** `buf lint` reports a `FIELD_LOWER_SNAKE_CASE` violation

### Requirement: Code generation configuration
The repository SHALL contain a `proto/buf.gen.yaml` file that configures code generation with four plugins:
1. `buf.build/protocolbuffers/go` → output to `../backend/gen`
2. `buf.build/connectrpc/go` → output to `../backend/gen`
3. `buf.build/bufbuild/es` → output to `../frontend/gen`
4. `buf.build/connectrpc/es` → output to `../frontend/gen`

#### Scenario: Go code generation
- **WHEN** a developer runs `buf generate` from the `proto/` directory
- **THEN** Go protobuf types and Connect service interfaces are generated in `backend/gen/bartering/v1/`

#### Scenario: TypeScript code generation
- **WHEN** a developer runs `buf generate` from the `proto/` directory
- **THEN** TypeScript protobuf types and Connect service clients are generated in `frontend/gen/bartering/v1/`

#### Scenario: Clean generation output directories
- **WHEN** `buf generate` runs and the output directories already contain previously generated files
- **THEN** the `clean` option SHALL ensure stale files are removed before generating new output

### Requirement: Go protobuf dependencies
The `backend/go.mod` SHALL include `google.golang.org/protobuf` and `connectrpc.com/connect` as dependencies.

#### Scenario: Go module resolves protobuf imports
- **WHEN** a developer runs `go build ./...` from the `backend/` directory after code generation
- **THEN** all generated Go files compile without import errors

### Requirement: TypeScript protobuf dependencies
The `frontend/package.json` SHALL include `@bufbuild/protobuf`, `@connectrpc/connect`, and `@connectrpc/connect-web` as dependencies.

#### Scenario: TypeScript resolves protobuf imports
- **WHEN** a developer runs `pnpm tsc --noEmit` or a build step in the `frontend/` directory after code generation
- **THEN** all generated TypeScript files resolve without import errors

### Requirement: Generated code committed to Git
Generated code in `backend/gen/` and `frontend/gen/` SHALL be committed to the Git repository.

#### Scenario: Generated code is present after clone
- **WHEN** a developer clones the repository
- **THEN** `backend/gen/bartering/v1/` and `frontend/gen/bartering/v1/` contain generated files without needing to run `buf generate`

#### Scenario: Generated code freshness
- **WHEN** `buf generate` runs on unchanged proto files
- **THEN** `git diff` shows no changes (generated code matches what is committed)

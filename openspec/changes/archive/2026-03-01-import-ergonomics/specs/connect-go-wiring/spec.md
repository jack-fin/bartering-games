## MODIFIED Requirements

### Requirement: Go import alias convention for generated protobuf code
Go source files that import the generated protobuf package (`barteringv1`) SHALL alias it as `pb`. Go source files that import the generated Connect package (`barteringv1connect`) SHALL alias it as `rpc`.

#### Scenario: Handler file uses pb alias
- **WHEN** a handler file in `backend/internal/handler/` imports `github.com/jack-fin/bartering-games/backend/gen/bartering/v1`
- **THEN** the import is aliased as `pb`
- **AND** all type references use the `pb.` prefix (e.g., `pb.CheckRequest`, `pb.CheckResponse`)

#### Scenario: Handler file uses rpc alias
- **WHEN** a handler file or test imports `github.com/jack-fin/bartering-games/backend/gen/bartering/v1/barteringv1connect`
- **THEN** the import is aliased as `rpc`
- **AND** all type references use the `rpc.` prefix (e.g., `rpc.NewHealthServiceHandler`, `rpc.NewHealthServiceClient`)

#### Scenario: Existing handler tests updated
- **WHEN** `backend/internal/handler/health_test.go` is compiled
- **THEN** it uses `pb` for protobuf types and `rpc` for Connect client/handler constructors
- **AND** all tests pass with identical behavior to before the alias change

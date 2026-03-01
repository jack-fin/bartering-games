## ADDED Requirements

### Requirement: Common proto file exists
The repository SHALL contain a `proto/bartering/v1/common.proto` file with package `bartering.v1` and Go package option set to `github.com/jack-fin/bartering-games/backend/gen/bartering/v1;barteringv1`.

#### Scenario: Package declaration
- **WHEN** a developer inspects `proto/bartering/v1/common.proto`
- **THEN** the file declares `package bartering.v1` and sets the Go package option

#### Scenario: Buf lint passes
- **WHEN** a developer runs `buf lint` from the `proto/` directory
- **THEN** `common.proto` passes all lint rules

### Requirement: PaginationRequest message
The `common.proto` file SHALL define a `PaginationRequest` message with fields for cursor-based pagination.

#### Scenario: PaginationRequest fields
- **WHEN** a developer inspects the `PaginationRequest` message
- **THEN** it contains a `string page_token` field and an `int32 page_size` field

#### Scenario: PaginationRequest is importable
- **WHEN** another proto file imports `bartering/v1/common.proto`
- **THEN** it can use `bartering.v1.PaginationRequest` as a field type

### Requirement: PaginationResponse message
The `common.proto` file SHALL define a `PaginationResponse` message with fields for returning pagination metadata.

#### Scenario: PaginationResponse fields
- **WHEN** a developer inspects the `PaginationResponse` message
- **THEN** it contains a `string next_page_token` field and an `int32 total_count` field

#### Scenario: Empty next_page_token indicates last page
- **WHEN** `next_page_token` is an empty string
- **THEN** consumers SHALL interpret this as no further pages available

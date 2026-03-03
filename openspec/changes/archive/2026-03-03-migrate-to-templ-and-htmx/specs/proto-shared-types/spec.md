## REMOVED Requirements

### Requirement: PaginationRequest and PaginationResponse proto messages
**Reason**: Shared protobuf types in `common.proto` are removed along with the protobuf toolchain.
**Migration**: Pagination types will be defined as Go structs when needed by feature stories. No proto-level shared types needed without Connect RPC.

### Requirement: common.proto file
**Reason**: The `proto/bartering/v1/common.proto` file and its generated output are removed.
**Migration**: Delete the file. Shared data structures are Go-level concerns, not proto-level.

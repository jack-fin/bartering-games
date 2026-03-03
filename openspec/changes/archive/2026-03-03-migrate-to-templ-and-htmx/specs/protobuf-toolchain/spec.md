## REMOVED Requirements

### Requirement: Buf module configuration
**Reason**: The protobuf toolchain is entirely removed. No `.proto` files, no buf.yaml, no code generation pipeline.
**Migration**: Delete `proto/` directory including `buf.yaml`, `buf.gen.yaml`, and all `.proto` files.

### Requirement: Buf code generation (Go + TypeScript)
**Reason**: buf generate produced Go Connect stubs and TypeScript Connect clients. Both are removed.
**Migration**: Delete `backend/gen/` and `frontend/gen/` directories. Go types are defined as structs. No TypeScript API generation needed.

### Requirement: Buf linting (STANDARD rules)
**Reason**: No proto files exist to lint.
**Migration**: Remove `lint:proto` task from Taskfile and proto lint step from CI.

### Requirement: Buf breaking change detection
**Reason**: No proto files exist to check for backward compatibility.
**Migration**: Remove buf breaking step from CI and the `api:breaking-change` label bypass logic.

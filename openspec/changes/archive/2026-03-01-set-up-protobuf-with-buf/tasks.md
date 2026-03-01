## 1. Buf Configuration

- [x] 1.1 Create `proto/buf.yaml` with v2 format, module name `buf.build/bartering-games/bartering`, `DEFAULT` lint category, and `buf.build/googleapis/googleapis` dependency
- [x] 1.2 Create `proto/buf.gen.yaml` with four plugins: `protocolbuffers/go` and `connectrpc/go` outputting to `../backend/gen`, `bufbuild/es` and `connectrpc/es` outputting to `../frontend/gen`, with clean option enabled
- [x] 1.3 Run `buf dep update` from `proto/` to generate `buf.lock`

## 2. Proto Definitions

- [x] 2.1 Create `proto/bartering/v1/common.proto` with package `bartering.v1`, Go package option, `PaginationRequest` message (page_token, page_size), and `PaginationResponse` message (next_page_token, total_count)
- [x] 2.2 Create `proto/bartering/v1/health.proto` with package `bartering.v1`, Go package option, `ServingStatus` enum (UNSPECIFIED, SERVING, NOT_SERVING), `CheckRequest` (empty), `CheckResponse` (status field), and `HealthService` with `Check` RPC
- [x] 2.3 Run `buf lint` from `proto/` and verify it passes with no errors

## 3. Dependencies

- [x] 3.1 Add `google.golang.org/protobuf` and `connectrpc.com/connect` to `backend/go.mod` and run `go mod tidy`
- [x] 3.2 Add `@bufbuild/protobuf`, `@connectrpc/connect`, and `@connectrpc/connect-web` to `frontend/package.json` and run `pnpm install`

## 4. Code Generation

- [x] 4.1 Run `buf generate` from `proto/` and verify Go files appear in `backend/gen/bartering/v1/`
- [x] 4.2 Verify TypeScript files appear in `frontend/gen/bartering/v1/`
- [x] 4.3 Run `go build ./...` from `backend/` to verify generated Go code compiles

## 5. Taskfile Wiring

- [x] 5.1 Update `generate:proto` task to run `buf generate` from the `proto/` directory (replace stub echo)
- [x] 5.2 Update `lint:proto` task to run `buf lint` from the `proto/` directory (replace stub echo)
- [x] 5.3 Run `task generate:proto` and `task lint:proto` to verify both tasks work

## 6. Cleanup and Verification

- [x] 6.1 Remove `.gitkeep` from `proto/bartering/v1/` (real files now exist)
- [x] 6.2 Run `task lint` and `task test` to verify nothing is broken
- [x] 6.3 Verify generated code freshness: run `buf generate` again and confirm `git diff` shows no changes

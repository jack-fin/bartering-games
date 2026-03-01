## Why

The proto package `bartering.v1` is correct and conventional for wire format identity, but it generates verbose prefixes in Go code (`barteringv1.CheckRequest`, `barteringv1connect.NewHealthServiceHandler`) and ugly relative import paths in TypeScript (`../../../gen/bartering/v1/health_pb.js`). As more services are added (trades, users, vault, etc.), this noise compounds — every handler file imports two long-prefixed packages and uses them on nearly every line. On the frontend, deeper route nesting means longer relative paths.

The proto package itself should not change — `bartering.v1` is stable, meaningful, and follows Buf conventions. The fix is purely in how consuming code references the generated types.

## What Changes

- **Go import aliases**: Establish a project convention of aliasing `barteringv1` as `pb` and `barteringv1connect` as `rpc` across all Go source files (handlers, tests, future services)
- **SvelteKit path alias**: Add `$gen` alias in `svelte.config.js` so frontend imports use `$gen/bartering/v1/...` instead of relative paths
- Update all existing Go files and frontend imports to use the new aliases

## Capabilities

### Modified Capabilities
- `connect-go-wiring`: Handler files adopt `pb`/`rpc` import aliases as the standard pattern
- `http-server`: `main.go` imports updated to use `rpc` alias
- `connect-ts-client`: Frontend API client imports use `$gen` path alias

## Impact

- **Backend**: Import statements change in `cmd/server/main.go`, `internal/handler/health.go`, `internal/handler/health_test.go`. No logic changes. All type references use `pb.` and `rpc.` prefixes.
- **Frontend**: `svelte.config.js` gains `kit.alias` config. `src/lib/api/index.ts` and any other files importing from `gen/` use `$gen/` prefix. No logic changes.
- **Proto/Wire**: No changes. `bartering.v1` package and all wire formats stay identical.

## Non-Goals

- Renaming the proto package (`bartering.v1` stays)
- Changing database naming (`bartering_dev`, `bartering` user stay)
- Changing the Go module path or Buf module name

## Shortcut

- Story: [sc-117](https://app.shortcut.com/bartering-games/story/117)
- Branch: `jackf/sc-117/improve-import-ergonomics-with-go-ali`

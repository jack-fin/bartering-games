## Why

The monorepo has multiple toolchains (Go, TypeScript/pnpm, Protobuf/Buf, sqlc, Atlas, Docker Compose) but no unified way to run common development tasks. A `Taskfile.yaml` at the repo root gives every developer a single entry point — `task lint`, `task test`, `task dev` — regardless of which subsystem they're working in.

## What Changes

- Add `Taskfile.yaml` at the repo root using [taskfile.dev](https://taskfile.dev) syntax.
- Define initial task stubs for: linting, testing (unit, integration, e2e), codegen (proto, sqlc), database migrations, and local dev environment.
- Stubs print a descriptive "not yet configured" message until the underlying tools are wired in by later tickets.

## Capabilities

### New Capabilities
- `task-runner`: Defines the `Taskfile.yaml` with all initial task stubs and their expected interfaces.

### Modified Capabilities

_None._

## Impact

- **New file**: `Taskfile.yaml` at repo root.
- **Dependencies**: Requires `task` CLI (taskfile.dev) installed on developer machines. No new runtime dependencies.
- **CI**: No CI changes yet — tasks will be wired into GitHub Actions workflows in a later ticket.

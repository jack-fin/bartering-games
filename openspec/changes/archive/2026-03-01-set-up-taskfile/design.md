## Context

The monorepo currently has `backend/`, `frontend/`, and `proto/` directories but no task runner. Developers need to remember per-subsystem commands (e.g., `cd backend && go test ./...`, `cd frontend && pnpm vitest`). The CLAUDE.md already documents the expected `task` commands, so the interface contract is established — this change creates the actual file.

## Goals / Non-Goals

**Goals:**
- Provide a single `Taskfile.yaml` at the repo root with all tasks documented in CLAUDE.md.
- Each task either runs the real command (if the tool is already wired) or prints a clear stub message.
- Tasks are organized so subsystem-specific tasks (e.g., `test:go`) can be composed into aggregate tasks (e.g., `test`).

**Non-Goals:**
- Wiring up actual tool execution (that happens in later tickets per tool — e.g., "set up golangci-lint", "configure Vitest").
- CI integration — GitHub Actions workflows will call these tasks in a separate ticket.
- Installing `task` CLI automatically — developers install it themselves.

## Decisions

### Use Taskfile v3 syntax
Taskfile.dev v3 is the current stable version. The file starts with `version: '3'`.

### Stub pattern: `echo` with descriptive message
Stub tasks use `cmd: echo "..."` with a message that tells the developer what the task will do and which ticket will wire it up. This is simpler than a `silent: true` + `cmds` block and makes it obvious the task isn't live yet.

### Flat namespace with colon-delimited subtasks
Use `test:go`, `test:ts`, `generate:proto`, `generate:sqlc` naming. The aggregate `test` task calls its subtasks via `deps`. This matches the interface already documented in CLAUDE.md.

### Set `dir` per task where appropriate
Tasks like `test:go` set `dir: backend` and `test:ts` set `dir: frontend` so developers can run them from anywhere in the repo.

## Risks / Trade-offs

- **[Risk] `task` not installed** → Taskfile is inert without the CLI. Mitigation: README and onboarding docs will mention the prerequisite. The `task` CLI is a single binary with easy install (`brew install go-task`).
- **[Risk] Stubs stay stubs** → If follow-up tickets are deprioritized, the Taskfile provides no real value. Mitigation: Each stub message names the task that will replace it, creating traceability.

## 1. Create Taskfile

- [x] 1.1 Create `Taskfile.yaml` at the repo root with `version: '3'` and all task definitions: `lint`, `test`, `test:go`, `test:ts`, `test:int`, `test:e2e`, `generate`, `generate:proto`, `generate:sqlc`, `migrate`, `dev`. Each task prints a stub message describing its intended behavior. Aggregate tasks (`test`, `generate`, `lint`) use `deps` to call their subtasks. Subsystem tasks set `dir` appropriately (`backend/` or `frontend/`).

## 2. Verify

- [x] 2.1 Run `task --list` and confirm all tasks appear without errors.
- [x] 2.2 Run each task individually and confirm stub messages print correctly.

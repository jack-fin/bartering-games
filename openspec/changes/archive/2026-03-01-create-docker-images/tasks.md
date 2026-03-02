## 1. Backend Dockerfile

- [x] 1.1 Create `backend/Dockerfile` with a multi-stage build: Go 1.26 build stage → `gcr.io/distroless/static-debian12:nonroot` runtime
- [x] 1.2 Compile the binary with `CGO_ENABLED=0 GOOS=linux` targeting `./cmd/server`
- [x] 1.3 Add `HEALTHCHECK` instruction targeting `/healthz`
- [x] 1.4 Verify: `docker build -t bartering-backend ./backend` succeeds
- [x] 1.5 Verify: container starts and `/healthz` responds

## 2. Frontend Dockerfile

- [x] 2.1 Create `frontend/Dockerfile` with a multi-stage build: Node 22 build stage with corepack/pnpm → `node:22-alpine` runtime
- [x] 2.2 Run `pnpm install --frozen-lockfile` and `pnpm run build` in the build stage
- [x] 2.3 Copy `build/` output and `package.json` into the runtime stage; run as `node` user
- [x] 2.4 Add `HEALTHCHECK` instruction
- [x] 2.5 Verify: `docker build -t bartering-frontend ./frontend` succeeds
- [x] 2.6 Verify: container starts and serves a response

## 3. Taskfile

- [x] 3.1 Add `docker:build` task to `Taskfile.yaml` that builds both images with correct context paths

## 4. CLAUDE.md

- [x] 4.1 Add Docker section to `CLAUDE.md` noting distroless runtime, `:debug` variant for local debugging, and `task docker:build`

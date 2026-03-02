## Context

The backend (Go) and frontend (SvelteKit with adapter-node) need production Dockerfiles to be deployable via Kamal. Currently neither service has a Dockerfile. The images must be suitable for a Hetzner VPS with Kamal 2 pulling from a container registry, and must be as small and secure as practically reasonable.

## Goals / Non-Goals

**Goals:**
- Multi-stage Dockerfiles that produce small, non-root runtime images
- Backend image builds a statically-linked Go binary (`CGO_ENABLED=0`)
- Frontend image installs deps with pnpm and builds the SvelteKit adapter-node output
- Both images declare a `HEALTHCHECK` against `/healthz`
- A `task docker:build` command builds both images locally
- Images verified to start and serve their health endpoints

**Non-Goals:**
- Publishing images to a registry (Kamal handles that)
- Multi-arch builds (amd64 only for now)
- Docker Compose integration changes

## Decisions

### Backend runtime base: `gcr.io/distroless/static-debian12:nonroot`

The Go binary is compiled with `CGO_ENABLED=0 GOOS=linux`, producing a fully static binary with no libc dependency. Distroless static provides exactly enough to run it — no shell, no package manager, no OS utilities. The `nonroot` tag runs as UID 65532 without an additional `USER` directive.

**Alternative considered:** `alpine:3` — familiar, has a shell for debugging. Rejected: the shell is a security liability in production and there is no dynamic linking benefit to justify it.

### Frontend runtime base: `node:22-alpine`

SvelteKit adapter-node produces a Node.js server (`build/index.js`). A pure distroless Node image is awkward to configure; `node:22-alpine` is well-maintained, small (~60 MB), and minimal. An explicit non-root user (`node`, UID 1000) is used.

**Alternative considered:** `node:22-slim` (Debian slim) — slightly larger, more compatible. Not needed for this workload.

### pnpm via corepack

The frontend build stage activates pnpm through `corepack enable` so the exact pnpm version is resolved from `package.json`'s `packageManager` field — no separate pnpm version pin in the Dockerfile.

### Layer cache ordering

Both Dockerfiles copy dependency manifests first (`go.mod`/`go.sum`, `package.json`/`pnpm-lock.yaml`), install dependencies, then copy source. This maximises Docker layer cache hits on incremental builds.

## Risks / Trade-offs

- **Distroless has no shell** → No `docker exec` debugging in production. Mitigation: the `:debug` variant of distroless includes busybox and can be used locally when needed.
- **Frontend `/healthz`** → adapter-node doesn't automatically expose a health route; the `HEALTHCHECK` in the frontend Dockerfile is best-effort for this story. A proper SvelteKit `/healthz` endpoint is a follow-up.
- **Registry auth** → `task docker:build` only builds locally. Pushing to a registry is out of scope.

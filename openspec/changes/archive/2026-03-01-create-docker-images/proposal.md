## Why

The backend and frontend services have no production Dockerfiles, so they cannot be built into container images for deployment via Kamal. Docker images are a prerequisite to any staging or production rollout.

Security is a first-class concern: images should run as non-root users, use minimal base images to reduce attack surface, and avoid shipping build tools or shells into production. Multi-stage Docker builds for Go are particularly effective here — Go compiles to a single static binary (`CGO_ENABLED=0`), meaning the runtime image needs no build tools at all, just the binary itself. This makes distroless images a natural fit: no shell, no package manager, nothing but the binary.

## What Changes

- Add `backend/Dockerfile` — multi-stage Go build producing a minimal, hardened runtime image
- Add `frontend/Dockerfile` — multi-stage Node/pnpm build producing a Node runtime image with adapter-node
- Add `task docker:build` to `Taskfile.yaml` for building both images locally

## Capabilities

### New Capabilities

- `docker-images`: Production-grade Dockerfiles for backend (Go) and frontend (SvelteKit/adapter-node) with multi-stage builds, non-root users, and health check instructions

### Modified Capabilities

- `task-runner`: New `docker:build` task added to Taskfile

## Impact

- `backend/Dockerfile` — new file; affects CI and Kamal deploy pipeline
- `frontend/Dockerfile` — new file; affects CI and Kamal deploy pipeline
- `Taskfile.yaml` — new `docker:build` task
- No API or database changes
- No new external dependencies

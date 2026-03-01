## Why

Developers currently have no way to run the application's infrastructure dependencies (Postgres, Prometheus, Grafana, Loki) locally. A `docker-compose.yaml` gives every developer a single `docker compose up` to spin up the full local environment with consistent configuration.

## What Changes

- Add `docker-compose.yaml` at the repo root with four services: postgres, prometheus, grafana, loki.
- Add `monitoring/prometheus.yml` with a basic scrape config targeting the Go backend.
- Add `.env.example` documenting required environment variables (`.env` stays gitignored).
- Wire the existing `task dev` stub to run `docker compose up`.

## Capabilities

### New Capabilities
- `local-dev-services`: Defines the docker-compose services, their configuration, volumes, networking, and environment variables for local development.

### Modified Capabilities
- `task-runner`: The `dev` task stub gets replaced with a real command (`docker compose up`).

## Impact

- **New files**: `docker-compose.yaml`, `monitoring/prometheus.yml`, `.env.example`
- **Modified files**: `Taskfile.yaml` (wire `dev` task)
- **Dependencies**: Requires Docker (via Colima or Docker Desktop) on developer machines.
- **No production impact** — this is local dev tooling only.

## Context

The monorepo needs local infrastructure (Postgres, monitoring stack) for development and integration testing. Currently there is no way to run these services locally. The `task dev` stub exists in `Taskfile.yaml` but does nothing.

## Goals / Non-Goals

**Goals:**
- Provide a single `docker compose up` to spin up all infrastructure dependencies.
- Configure Postgres with a dev database, persistent volume, and predictable credentials.
- Set up the monitoring stack (Prometheus, Grafana, Loki) for local observability.
- Wire the `task dev` Taskfile stub to actually start the compose stack.
- Document environment variables via `.env.example`.

**Non-Goals:**
- Production Docker configuration — this is local dev only.
- Running the Go backend or SvelteKit frontend inside Docker — those run natively on the host.
- Configuring Grafana dashboards or Loki log shipping — those come in later tickets.
- Docker installation or Colima setup — developers manage that themselves.

## Decisions

### PostgreSQL 17 instead of 18
The story specifies PostgreSQL 18, but as of March 2026 the latest stable release available on Docker Hub is PostgreSQL 17. Using `postgres:17` ensures we get a real, pullable image. We can bump to 18 when it ships.

### Use named volumes for persistence
Named Docker volumes (`pgdata`, `grafana-data`, `loki-data`) persist across `docker compose down` / `up` cycles. Developers can `docker compose down -v` to reset. This is simpler than bind-mounting host directories and avoids filesystem permission issues.

### Prometheus config at `monitoring/prometheus.yml`
A dedicated `monitoring/` directory keeps observability config organized. The initial scrape config targets `host.docker.internal:8080` (the Go backend running on the host). This follows Docker's convention for container-to-host networking.

### `.env.example` not `.env`
`.env` is gitignored (secrets). `.env.example` is committed with safe defaults so developers can `cp .env.example .env` and go. Docker Compose automatically reads `.env` from the project root.

### Grafana anonymous access enabled
For local dev, requiring Grafana login is friction with no security benefit. Anonymous access with org role `Admin` lets developers open `localhost:3000` and immediately explore.

### Loki configured as Grafana datasource via provisioning
Rather than requiring manual datasource setup, Grafana provisioning (`grafana/provisioning/datasources/`) auto-configures Loki on first boot.

## Risks / Trade-offs

- **[Risk] Port conflicts** — Services bind to standard ports (5432, 3000, 9090, 3100). If a developer already has Postgres on 5432, they'll hit a conflict. Mitigation: `.env.example` documents the ports; developers can override via `.env`.
- **[Risk] Docker resource usage** — Four containers use non-trivial memory. Mitigation: monitoring services are optional — developers can `docker compose up postgres` to run only what they need.
- **[Risk] `host.docker.internal` not universal** — Works on Docker Desktop and Colima but may not work in all Linux Docker setups. Mitigation: document the assumption; Linux users can use `extra_hosts` or `network_mode: host`.

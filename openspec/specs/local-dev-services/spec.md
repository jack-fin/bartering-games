## ADDED Requirements

### Requirement: Docker Compose file exists
The repo SHALL contain a `docker-compose.yaml` at the repository root that defines all local development infrastructure services.

#### Scenario: Compose file is valid
- **WHEN** a developer runs `docker compose config` from the repo root
- **THEN** the configuration is valid and lists all defined services

### Requirement: PostgreSQL service
The compose file SHALL define a `postgres` service using the `postgres:17` image with a persistent named volume, exposed on `localhost:5432`, that creates a dev database on first run.

#### Scenario: Postgres starts and accepts connections
- **WHEN** a developer runs `docker compose up postgres -d`
- **THEN** a PostgreSQL instance is available at `localhost:5432` with the configured database and credentials

#### Scenario: Postgres data persists across restarts
- **WHEN** a developer runs `docker compose down` followed by `docker compose up postgres -d`
- **THEN** data from the previous session is still present

#### Scenario: Postgres data can be reset
- **WHEN** a developer runs `docker compose down -v`
- **THEN** the Postgres volume is removed and the next `up` starts fresh

### Requirement: Prometheus service
The compose file SHALL define a `prometheus` service using the `prom/prometheus` image, configured via `monitoring/prometheus.yml`, with a scrape target for the Go backend.

#### Scenario: Prometheus starts with scrape config
- **WHEN** a developer runs `docker compose up prometheus -d`
- **THEN** Prometheus is available at `localhost:9090` and its targets page shows the backend scrape target

### Requirement: Prometheus scrape config
A `monitoring/prometheus.yml` file SHALL exist with a scrape config that targets the Go backend on the host machine.

#### Scenario: Scrape config is valid
- **WHEN** Prometheus loads `monitoring/prometheus.yml`
- **THEN** it parses without errors and lists the backend as a scrape target

### Requirement: Grafana service
The compose file SHALL define a `grafana` service using the `grafana/grafana` image with a persistent named volume, exposed on `localhost:3000`, with anonymous access enabled.

#### Scenario: Grafana starts with anonymous access
- **WHEN** a developer opens `http://localhost:3000` in a browser
- **THEN** Grafana loads without requiring login

### Requirement: Grafana Loki datasource provisioning
Grafana SHALL be provisioned with Loki as a datasource automatically on first boot.

#### Scenario: Loki datasource is pre-configured
- **WHEN** Grafana starts for the first time
- **THEN** the Loki datasource appears in Grafana's datasource list without manual configuration

### Requirement: Loki service
The compose file SHALL define a `loki` service using the `grafana/loki` image with a persistent named volume.

#### Scenario: Loki starts and accepts log pushes
- **WHEN** a developer runs `docker compose up loki -d`
- **THEN** Loki is available at `localhost:3100` and its `/ready` endpoint returns OK

### Requirement: Environment variable documentation
The repo SHALL contain a `.env.example` file documenting all environment variables used by the compose file, with safe default values.

#### Scenario: Developer sets up environment
- **WHEN** a developer runs `cp .env.example .env`
- **THEN** `docker compose up` works without additional configuration

### Requirement: Gitignore excludes .env
The `.env` file MUST be listed in `.gitignore` to prevent committing secrets.

#### Scenario: .env is gitignored
- **WHEN** a developer creates `.env` from `.env.example`
- **THEN** `git status` does not show `.env` as an untracked file

## 1. Environment Config

- [x] 1.1 Create `.env.example` with variables for Postgres credentials (`POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB`), port mappings, and any other compose-referenced vars, all with safe defaults.
- [x] 1.2 Verify `.env` is already in `.gitignore`. If not, add it.

## 2. Docker Compose

- [x] 2.1 Create `docker-compose.yaml` with `postgres` service (postgres:17, named volume `pgdata`, port 5432, env vars from `.env`).
- [x] 2.2 Add `prometheus` service (prom/prometheus, bind-mount `monitoring/prometheus.yml`, port 9090).
- [x] 2.3 Add `loki` service (grafana/loki, named volume `loki-data`, port 3100).
- [x] 2.4 Add `grafana` service (grafana/grafana, named volume `grafana-data`, port 3000, anonymous access enabled via environment, Loki datasource provisioned via bind-mounted config).

## 3. Monitoring Config

- [x] 3.1 Create `monitoring/prometheus.yml` with a scrape config targeting the Go backend at `host.docker.internal:8080`.
- [x] 3.2 Create `grafana/provisioning/datasources/loki.yaml` to auto-configure Loki as a Grafana datasource.

## 4. Wire Taskfile

- [x] 4.1 Update the `dev` task in `Taskfile.yaml` to run `docker compose up` instead of the stub echo.

## 5. Verify

- [x] 5.1 Run `docker compose config` and confirm it parses without errors.
- [x] 5.2 Run `task dev` and confirm it starts the compose stack.

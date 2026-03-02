# bartering.games

A Steam key bartering platform where gamers can trade game keys.

## Developer Setup

### Prerequisites

Install all required tools (macOS with Homebrew):

```bash
# Language runtimes
brew install go           # 1.26+
brew install node         # LTS
npm install -g pnpm       # package manager for frontend

# Task runner
brew install go-task      # runs as `task`

# Docker (via Colima — no Docker Desktop required)
brew install colima
brew install docker
colima start              # start the Docker runtime

# Protobuf / Connect toolchain
brew install bufbuild/buf/buf

# Database tooling
brew install ariga/tap/atlas   # schema migrations
brew install sqlc              # Go SQL codegen

# Linters
brew install golangci-lint
brew install lefthook
```

Verify everything is in order:

```bash
task deps:check
```

### First-Time Setup

After cloning the repo:

```bash
# 1. Install frontend dependencies
cd frontend && pnpm install && cd ..

# 2. Install git pre-commit hooks
task hooks:install

# 3. Start local services (Postgres, Prometheus, Grafana, Loki)
task dev
```

### Local Services

`task dev` starts the following via Docker Compose:

| Service    | URL                     | Purpose              |
|------------|-------------------------|----------------------|
| Postgres   | `localhost:5432`        | Primary database     |
| Prometheus | `http://localhost:9090` | Metrics              |
| Grafana    | `http://localhost:3000` | Dashboards (anon admin) |
| Loki       | `http://localhost:3100` | Log aggregation      |

Run the backend and frontend separately in additional terminals:

```bash
task dev:backend    # Go server
task dev:frontend   # SvelteKit dev server
```

### Common Tasks

```bash
task deps:check      # verify all required tools are installed
task hooks:install   # install git pre-commit hooks (run once after cloning)
task lint            # run all linters (Go + TS + Proto)
task test            # run all unit tests
task generate        # regenerate protobuf + sqlc code
task migrate         # apply pending database migrations
task build           # build Go backend binary
```

See `task --list` for the full list.

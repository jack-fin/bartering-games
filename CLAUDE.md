# bartering.games

A Steam key bartering platform where gamers can trade game keys.
Domain: bartering.games

## Tech Stack

- **Backend**: Go 1.26 (Chi router, templ for HTML rendering, HTMX for SPA-like navigation, sqlc for queries, pgx for dynamic SQL)
- **Frontend**: Server-rendered HTML via Go templ components, HTMX with `hx-boost` + head-support extension
- **Vault**: Standalone TypeScript module (`vault-js/`) compiled by esbuild — client-side WebCrypto (AES-256-GCM, PBKDF2, RSA-OAEP)
- **Database**: PostgreSQL, Atlas migrations (declarative HCL schema + versioned migrations), sqlc codegen
- **Deployment**: Kamal 2 on Hetzner VPS, Docker images, Traefik for SSL
- **Monitoring**: Prometheus + Grafana + Loki (self-hosted), Sentry, UptimeRobot

## Repository Structure

Monorepo layout:
```
bartering-games/
├── CLAUDE.md
├── .claude/rules/          # Path-scoped rules (backend, vault-js)
├── openspec/               # OpenSpec artifacts (changes, specs, proposals)
├── vault-js/               # Standalone TypeScript WebCrypto module
│   ├── src/                # TypeScript source (index.ts, htmx-interception.ts)
│   ├── package.json        # pnpm, esbuild + vitest devDeps, zero runtime deps
│   └── vitest.config.ts
├── backend/                # Go server (HTML + API + background workers)
│   ├── cmd/server/
│   │   ├── main.go         # Server entry point
│   │   └── static/         # Embedded static assets (CSS, JS, vendor)
│   │       ├── styles.css
│   │       ├── vault.js    # Compiled vault-js output (esbuild IIFE)
│   │       └── vendor/     # Vendored HTMX + extensions
│   ├── internal/
│   │   ├── components/     # templ components (layout, nav, footer)
│   │   │   └── pages/      # Page-level templ components (home, login)
│   │   ├── service/        # Business logic
│   │   ├── port/           # Interface definitions (adapters pattern)
│   │   ├── adapter/        # Platform implementations (steam/, igdb/, itad/, manual/)
│   │   ├── storage/        # sqlc queries + generated code
│   │   │   ├── sqlc.yaml
│   │   │   ├── query/      # Hand-written SQL
│   │   │   └── db/         # Generated Go (sqlc output)
│   │   ├── worker/         # Background sync goroutines
│   │   └── crypto/         # Server-side crypto utilities
│   ├── migrations/         # Atlas versioned migration files
│   ├── schema.hcl          # Declarative DB schema (Atlas source of truth)
│   ├── atlas.hcl           # Atlas CLI config (envs, dev database)
│   └── Dockerfile
├── docker-compose.yaml     # Local dev (Postgres, Prometheus, Grafana, Loki)
├── Taskfile.yaml           # Task runner (use `task` not `make`)
└── .github/workflows/      # CI (lint, test-go, test-vault, openspec check)
```

## Build Output

- Go binaries go in `backend/bin/` (gitignored). Always use `go build -o bin/ ./cmd/...`
  when compiling manually. Never run `go build` without `-o bin/` — bare `go build`
  drops binaries in the source tree.
- Vault JS output goes to `backend/cmd/server/static/vault.js` (compiled by esbuild from `vault-js/src/`).

## Code Style & Conventions

- **Readability over cleverness**, unless the performance benefit is significant
- Never log plaintext game keys, vault passphrases, or sensitive user data

## Running Tasks

All project tasks use Taskfile (`task` CLI):
```bash
task hooks:install   # Install git pre-commit hooks (run once after cloning)
task lint            # Run all linters (Go + TypeScript)
task test            # Run all unit tests (Go + vault-js)
task test:go         # Go unit tests
task test:vault      # vault-js unit tests (Vitest)
task test:int        # Integration tests (testcontainers, needs Docker)
task test:e2e        # Playwright browser tests
task generate        # Run all codegen (templ generate + sqlc generate)
task generate:templ  # templ generate only
task generate:sqlc   # sqlc generate only
task build:vault     # Compile vault-js TypeScript → backend/cmd/server/static/vault.js
task migrate         # Run Atlas migrations
task migrate:diff    # Generate migration from schema.hcl diff (usage: task migrate:diff -- <name>)
task dev             # Start local dev environment (docker-compose up)
task dev:backend     # Run Go backend server locally
```

## Pre-commit Hooks

Pre-commit hooks run linters automatically on staged files before each commit.
Install once after cloning:

```bash
brew install lefthook golangci-lint gopls  # prerequisites
task hooks:install
```

## Claude Code LSP Setup

LSP servers give Claude real-time diagnostics, go-to-definition, and type info while editing.

Active plugins (installed via `claude-plugins-official` marketplace):
- **Go**: `gopls-lsp` — requires `gopls` in PATH: `brew install gopls`
- **TypeScript**: `typescript-lsp` — requires `typescript-language-server` in PATH: `brew install typescript-language-server`

Hooks run in parallel and only check staged files — Go and TypeScript each
have their own linter triggered only when relevant files are staged.

**Claude must never run `git commit --no-verify` without explicit user instruction.**
If a pre-commit hook fails, fix the underlying issue. Only bypass hooks if the user
directly asks for it.

## Testing

- **Go unit tests**: `go test ./...` in `backend/`
- **Go integration tests**: `go test -tags=integration ./...` (uses testcontainers for real Postgres)
- **vault-js unit tests**: Vitest in `vault-js/`
- **Browser E2E**: Playwright (multi-context for two-user trade flows)
- **CI** (GitHub Actions): lint + test-go + test-vault + openspec archived check

## Git Workflow

- When starting work on a Shortcut story, always branch off of `main`. Before creating
  the feature branch:
  1. `git fetch origin main`
  2. Check if local `main` is behind `origin/main`.
  3. If behind and already on `main`: just `git pull --ff-only origin main` (safe
     fast-forward, no confirmation needed).
  4. If behind and on a different branch, or if fast-forward isn't possible: offer the
     user options (e.g., switch to main and pull, create branch from `origin/main`
     directly, rebase, etc.).
  5. Create the feature branch from the up-to-date main.
- Use the branch name generated by Shortcut (via `stories-get-branch-name`) as the
  feature branch. Do not invent a branch name. The format is
  `{mention_name}/sc-{story_id}/{description}` e.g.
  `jackf/sc-48/set-up-sqlc-code-generation`.
- All feature work (commits, pushes) happens on the feature branch, never on `main`.
  Merge into `main` only via squash-merge PR.
- Shortcut stories auto-transition to "Done" when their linked PR is merged (via
  GitHub integration). No need to manually update story state after merge.

## Docker

- The backend runtime image uses `gcr.io/distroless/static-debian12:nonroot` — no shell, no package manager, runs as UID 65532. For local debugging (`docker exec`), swap to `gcr.io/distroless/static-debian12:debug` which includes busybox.
- Single Docker image: the Go binary embeds static assets (CSS, JS, vendor scripts) via `//go:embed`. No separate frontend image.
- Build the image with `task docker:build`.

## Architecture Patterns

- **Ports and Adapters**: Business logic in `service/` depends on interfaces in `port/`.
  Implementations in `adapter/` (steam, igdb, itad, manual). Tests use mock adapters.
- **Server-side rendering**: Go templ components render full HTML pages. HTMX `hx-boost`
  provides SPA-like navigation by swapping `<body>` content via AJAX. The `head-support`
  extension merges `<head>` elements across navigations.
- **Client-side encryption**: Game keys encrypted in browser via WebCrypto (AES-256-GCM).
  Server stores opaque blobs only. Trade auto-reveal via RSA-OAEP escrow. Vault JS
  intercepts HTMX form submissions via `htmx:configRequest` to encrypt data before sending.
  The vault key persists in JS memory across `hx-boost` navigations (no page reload).
- **Background workers**: Go goroutines for Steam library sync, wishlist sync, game
  enrichment, bundle data. Heartbeat table for monitoring.
- **Server-side sessions**: Hashed tokens in Postgres, HttpOnly cookies. No JWTs.
  Session lookup per request (~0.2ms). Instant revocation on logout/compromise.
- **Generated code checked into Git**: templ (`_templ.go`), sqlc (`backend/internal/storage/db/`),
  and vault-js (`backend/cmd/server/static/vault.js`) output is committed. CI verifies codegen is committed.
- **Housekeeping**: Remove `.gitkeep` placeholder files from directories once real
  content is added.

# bartering.games

A Steam key bartering platform where gamers can trade game keys.
Domain: bartering.games

## Tech Stack

- **Backend**: Go 1.26 (Chi router, Connect-go for RPC, sqlc for queries, pgx for dynamic SQL)
- **Frontend**: SvelteKit (Svelte 5), TypeScript, pnpm
- **API Contract**: Protobuf + Buf + Connect (`.proto` files are the source of truth)
- **Database**: PostgreSQL, Atlas migrations (SQL-mode), sqlc codegen
- **Deployment**: Kamal 2 on Hetzner VPS, Docker images, Traefik for SSL
- **Monitoring**: Prometheus + Grafana + Loki (self-hosted), Sentry, UptimeRobot

## Repository Structure

Monorepo layout:
```
bartering-games/
├── CLAUDE.md
├── openspec/               # OpenSpec artifacts (changes, specs, proposals)
├── proto/                  # Protobuf definitions (source of truth for API)
│   ├── buf.yaml
│   ├── buf.gen.yaml
│   └── bartering/v1/
├── backend/                # Go API server + background workers
│   ├── cmd/server/
│   ├── internal/
│   │   ├── handler/        # Connect RPC handlers
│   │   ├── service/        # Business logic
│   │   ├── port/           # Interface definitions (adapters pattern)
│   │   ├── adapter/        # Platform implementations (steam/, igdb/, itad/, manual/)
│   │   ├── storage/        # sqlc queries + generated code
│   │   │   ├── sqlc.yaml
│   │   │   ├── query/      # Hand-written SQL
│   │   │   └── db/         # Generated Go (sqlc output)
│   │   ├── worker/         # Background sync goroutines
│   │   └── crypto/         # Server-side crypto utilities
│   ├── gen/                # Generated protobuf Go code
│   ├── migrations/         # Atlas migration files
│   └── Dockerfile
├── frontend/               # SvelteKit web UI
│   ├── src/lib/
│   │   ├── api/            # Connect client setup
│   │   ├── vault/          # Client-side encryption (WebCrypto)
│   │   └── components/
│   ├── gen/                # Generated protobuf TS code
│   ├── tests/e2e/          # Playwright browser tests
│   └── Dockerfile
├── docker-compose.yaml     # Local dev (Postgres, Prometheus, Grafana, Loki)
├── Taskfile.yaml           # Task runner (use `task` not `make`)
└── .github/workflows/      # CI/CD
```

## Build Output

- Go binaries go in `backend/bin/` (gitignored). Always use `go build -o bin/ ./cmd/...`
  when compiling manually. Never run `go build` without `-o bin/` — bare `go build`
  drops binaries in the source tree.

## Code Style & Conventions

- **Readability over cleverness**, unless the performance benefit is significant
- Go code follows standard Go conventions (gofmt, effective Go)
- TypeScript uses ESLint + Prettier for linting + formatting
- Go uses golangci-lint
- Proto uses buf lint
- Never log plaintext game keys, vault passphrases, or sensitive user data

## Frontend Standards

These three concerns are first-class requirements in every UI component, not follow-up tasks:

- **Accessibility (a11y)**: Semantic HTML (`<button>`, `<nav>`, `<dialog>`, not `<div>` with
  click handlers). Logical heading hierarchy. ARIA only when semantic HTML is insufficient.
  All interactive elements keyboard-reachable and operable. Visible focus indicators.
  WCAG 2.1 AA contrast (4.5:1 normal text, 3:1 large text). Never convey info through
  color alone. `aria-live` for dynamic content (trade updates, sync progress).
- **Internationalization (i18n)**: English-only at launch, but all user-facing strings must
  go through the i18n function — no hardcoded text. Date/number formatting via `Intl` APIs.
  Backend returns error codes, frontend maps to localized messages.
- **Responsive UI**: Single adaptive layout (not separate mobile/desktop). CSS custom
  properties for theming (light/dark via `prefers-color-scheme`). Interactions adapt by
  input method (`pointer: coarse` vs `fine`), not screen size. Touch targets min 44px.

## Running Tasks

All project tasks use Taskfile (`task` CLI):
```bash
task lint          # Run all linters (Go + TS + Proto)
task test          # Run all unit tests
task test:go       # Go unit tests
task test:ts       # TypeScript unit tests (Vitest)
task test:int      # Integration tests (testcontainers, needs Docker)
task test:e2e      # Playwright browser tests
task generate      # Run all codegen (buf generate + sqlc generate)
task generate:proto  # buf generate only
task generate:sqlc   # sqlc generate only
task migrate       # Run Atlas migrations
task dev           # Start local dev environment (docker-compose up + servers)
```

## Testing

- **Go unit tests**: `go test ./...` in `backend/`
- **Go integration tests**: `go test -tags=integration ./...` (uses testcontainers for real Postgres)
- **TS unit tests**: Vitest in `frontend/`
- **Browser E2E**: Playwright in `frontend/tests/e2e/` (multi-context for two-user trade flows)
- **CI** (GitHub Actions): lint + unit tests + integration tests. Browser E2E not in CI initially.

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
  feature branch. Do not invent a new branch name.
- All feature work (commits, pushes) happens on the feature branch, never on `main`.
  Merge into `main` only via squash-merge PR.

## Architecture Patterns

- **Ports and Adapters**: Business logic in `service/` depends on interfaces in `port/`.
  Implementations in `adapter/` (steam, igdb, itad, manual). Tests use mock adapters.
- **Client-side encryption**: Game keys encrypted in browser via WebCrypto (AES-256-GCM).
  Server stores opaque blobs only. Trade auto-reveal via RSA-OAEP escrow.
- **Background workers**: Go goroutines for Steam library sync, wishlist sync, game
  enrichment, bundle data. Heartbeat table for monitoring.
- **Server-side sessions**: Hashed tokens in Postgres, HttpOnly cookies. No JWTs.
  Session lookup per request (~0.2ms). Instant revocation on logout/compromise.
- **Generated code checked into Git**: Both protobuf (backend/gen/, frontend/gen/) and
  sqlc (backend/internal/storage/db/) output is committed. CI validates freshness.

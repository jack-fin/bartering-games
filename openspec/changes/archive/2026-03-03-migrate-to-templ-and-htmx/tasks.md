## 1. Delete removed code

- [x] 1.1 Delete `frontend/` directory (SvelteKit app, nginx config, Dockerfile, all source)
- [x] 1.2 Delete `proto/` directory (buf.yaml, buf.gen.yaml, all .proto files, buf.lock)
- [x] 1.3 Delete `backend/gen/` directory (generated protobuf Go code)
- [x] 1.4 Delete `backend/internal/handler/health.go` and `backend/internal/handler/health_test.go` (Connect RPC handler)
- [x] 1.5 Remove Connect and protobuf dependencies from `backend/go.mod` (`connectrpc.com/connect`, `google.golang.org/protobuf`) and run `go mod tidy`

## 2. Add templ and HTMX infrastructure

- [x] 2.1 Add `github.com/a-h/templ` dependency to `backend/go.mod`
- [x] 2.2 Install `templ` CLI (`go install github.com/a-h/templ/cmd/templ@latest`)
- [x] 2.3 Create `backend/static/` directory with `styles.css` (CSS custom properties, light/dark mode via `prefers-color-scheme`)
- [x] 2.4 Vendor HTMX (`htmx.min.js`) and head-support extension into `backend/static/vendor/`
- [x] 2.5 Create `backend/internal/components/layout.templ` — base HTML layout with `<html>`, `<head>` (HTMX scripts, vault.js, styles.css), `<body hx-boost="true" hx-ext="head-support">`, `{ children... }`
- [x] 2.6 Create `backend/internal/components/nav.templ` — navigation component with `<nav>` inside `<header>`
- [x] 2.7 Create `backend/internal/components/footer.templ` — footer component
- [x] 2.8 Create `backend/internal/components/pages/home.templ` — home page using layout
- [x] 2.9 Create `backend/internal/components/pages/login.templ` — login page using layout
- [x] 2.10 Run `templ generate` and commit the generated `_templ.go` files

## 3. Set up vault-js module

- [x] 3.1 Create `vault-js/` directory with `package.json` (zero runtime deps, esbuild + typescript + vitest as devDeps), `tsconfig.json` (strict mode), and esbuild config — use pnpm as package manager
- [x] 3.2 Create `vault-js/src/index.ts` — vault scaffold with stub functions (deriveKey, encrypt, decrypt, generateEscrowKeyPair) that throw not-implemented errors
- [x] 3.3 Create `vault-js/src/htmx-interception.ts` — HTMX `htmx:configRequest` event listener scaffold that identifies vault-marked forms (`data-vault-*`) and provides hook point
- [x] 3.4 Create `vault-js/src/index.test.ts` — basic Vitest tests verifying stubs throw, event listener registration, and WebCrypto availability
- [x] 3.5 Configure Vitest with jsdom or happy-dom environment for WebCrypto
- [x] 3.6 Run esbuild to compile `vault-js/src/` → `backend/static/vault.js` (IIFE, single file) and commit output
- [x] 3.7 Run `pnpm vitest run` and verify tests pass

## 4. Rewire the Go server

- [x] 4.1 Update `backend/cmd/server/main.go` — remove Connect handler mount, add static file server at `/static/*`, add templ page routes (`GET /`, `GET /login`), keep `/healthz` and `/readyz` as plain HTTP handlers
- [x] 4.2 Add `//go:embed static` directive for production asset embedding with a build-tag or env-based switch for development (serve from disk)
- [x] 4.3 Write tests for the new page routes (GET /, GET /login return 200 with HTML content-type) and static asset serving
- [x] 4.4 Verify `go build -o bin/server ./cmd/server/` compiles and the server starts

## 5. Update Dockerfile

- [x] 5.1 Update `backend/Dockerfile` — ensure embedded static assets are included in the build context; remove any references to frontend image
- [x] 5.2 Delete `frontend/Dockerfile` (already deleted in step 1.1)
- [x] 5.3 Verify `docker build -t bartering-backend ./backend` succeeds and the image serves pages and static assets

## 6. Update Taskfile

- [x] 6.1 Add `generate:templ` task (runs `templ generate` from `backend/`)
- [x] 6.2 Add `build:vault` task (runs esbuild from `vault-js/`)
- [x] 6.3 Replace `generate:proto` with `generate:templ` in the aggregate `generate` task
- [x] 6.4 Replace `test:ts` with `test:vault` (runs `pnpm vitest run` from `vault-js/`)
- [x] 6.5 Update `lint:ts` to run from `vault-js/` instead of `frontend/`
- [x] 6.6 Update `fix:ts` to run from `vault-js/` instead of `frontend/`
- [x] 6.7 Remove `lint:proto`, `dev:frontend` tasks
- [x] 6.8 Update `lint` aggregate to remove proto, update TS references
- [x] 6.9 Update `docker:build` to build backend image only
- [x] 6.10 Update `deps:check` — remove `buf`, `node`; add `templ` (keep `pnpm`)

## 7. Update CI pipeline

- [x] 7.1 Update `.github/workflows/ci.yml` lint job — remove proto lint, buf breaking, and proto codegen; add templ CLI install; update codegen verification to run `task generate` (templ + sqlc only)
- [x] 7.2 Update lint PR comment — remove proto lint and buf breaking sections; keep TS lint and codegen verification
- [x] 7.3 Replace `test-ts` job with `test-vault` job — install pnpm deps in `vault-js/`, run `task test:vault`, cache pnpm store keyed on `vault-js/pnpm-lock.yaml`
- [x] 7.4 Update pnpm store cache to key on `vault-js/pnpm-lock.yaml` instead of `frontend/pnpm-lock.yaml`
- [x] 7.5 Verify CI workflow YAML is valid (`act` or push to branch and check)

## 8. Update docker-compose and local dev

- [x] 8.1 Remove any frontend service references from `docker-compose.yaml` (if present)
- [x] 8.2 Verify `task dev` starts the local environment and `task dev:backend` serves pages at localhost

## 9. Update documentation and rules

- [x] 9.1 Update `CLAUDE.md` — tech stack, repository structure, build commands, test commands, dependency list, architecture patterns, pre-commit hooks section
- [x] 9.2 Update `.claude/rules/` — remove frontend and proto scoped rules; add templ and vault-js scoped rules
- [x] 9.3 Update `lefthook.yml` (pre-commit hooks) — remove frontend/proto linter triggers; add templ and vault-js triggers

## 10. Verification

- [x] 10.1 Run `task lint` — all linters pass
- [x] 10.2 Run `task test` — all unit tests pass (Go + vault-js)
- [x] 10.3 Run `task generate` then `git diff --exit-code` — codegen is up to date
- [x] 10.4 Run `task docker:build` — Docker image builds successfully
- [x] 10.5 Start server and manually verify: home page renders, login page renders, static assets load, light/dark mode works, HTMX navigation works (no full page reload between / and /login)

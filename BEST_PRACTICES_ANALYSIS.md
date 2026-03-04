# Best Practices Analysis: bartering-games

**Date**: 2026-03-04
**Scope**: Go, TypeScript, SQL/Database, CI/CD, Infrastructure

---

## Executive Summary

The bartering-games codebase demonstrates strong foundational practices across all
languages. The project is early-stage (many placeholder directories), but the
architecture, tooling, and CI pipeline are well-designed for scaling. Key strengths
include type-safe database access via sqlc, security-first Docker images, comprehensive
CI, and a zero-dependency client-side crypto module. The primary gaps are in
incomplete business logic, minimal schema, and missing authentication.

---

## 1. Go (Backend)

### 1.1 Project Structure — Excellent

| Practice | Status |
|----------|--------|
| `cmd/`, `internal/` layout | Follows standard Go project layout |
| Ports & Adapters pattern | Directories prepared (`port/`, `adapter/`, `service/`) |
| Minimal dependencies | Only 4 direct deps: templ, chi, pgx, cors |
| Generated code committed | templ (`_templ.go`) and sqlc (`db/`) are versioned |

**Specific strengths:**
- `cmd/server/main.go` is a clean single entry point (~130 lines)
- `go.mod` pins Go 1.26 with minimal dependency tree
- Static assets embedded via `//go:embed` — single binary deployment

### 1.2 HTTP Routing & Middleware — Good

**`cmd/server/main.go:31-44`** — Chi middleware stack is well-ordered:
```
RealIP → Logger → Recoverer → Compress → CORS
```

**`cmd/server/main.go:83-103`** — Graceful shutdown handles SIGTERM + SIGINT with
10-second timeout. Uses `signal.NotifyContext()` (Go 1.16+ best practice).

**`cmd/server/main.go:68-76`** — Separate `/healthz` (liveness) and `/readyz`
(readiness) probes are Kubernetes-ready.

**Areas for improvement:**
- **CORS is overly permissive** (`main.go:38`): `AllowedOrigins: []string{"*"}` should
  be restricted to `https://bartering.games` before production
- **Inline handler closures** (`main.go:55-65`): Should migrate to a handler package as
  complexity grows
- **Missing request IDs**: Add `middleware.RequestID` for observability

### 1.3 Error Handling — Needs Improvement

**What's good:**
- Critical startup errors cause fatal exit (`main.go:48-51, 88`)
- Structured logging with `slog` (stdlib, Go 1.21+)

**What needs work:**
- **Incomplete handler error responses** (`main.go:56-58`): Render errors are logged but
  no HTTP error status is written to the client:
  ```go
  // Current (incomplete):
  if err := pages.Home().Render(r.Context(), w); err != nil {
      slog.Error("render error", "page", "home", "error", err)
      // Missing: http.Error(w, "Internal Server Error", 500)
  }
  ```
- **No custom error types**: Define domain errors (`ErrUserNotFound`, `ErrInvalidKey`)
  once service layer is built
- **No error wrapping**: Use `fmt.Errorf("...: %w", err)` to preserve error chains

### 1.4 Database Access — Strong Foundation

**`internal/storage/sqlc.yaml`** — Well-configured:
- v2 config format, `pgx/v5` driver, `emit_pointers_for_null_types: true`
- Named parameters (`@id`) prevent SQL injection

**`internal/storage/query/users.sql`** — Clean parameterized query with `:one` marker.

**`internal/storage/db/db.go`** — Generated code includes `WithTx()` for transaction
support.

**Areas for improvement:**
- Only 1 query exists (`GetUserByID`) — needs full CRUD + business queries
- No sentinel errors wrapping `pgx.ErrNoRows`
- Consider adding `strict: true` to sqlc.yaml

### 1.5 Testing — Good Patterns, Limited Coverage

**`cmd/server/main_test.go`** — Tests use `httptest.NewServer` with a dedicated
`newTestRouter()`. Response validation checks status codes, content-type, and body.

**Areas for improvement:**
- Refactor to table-driven tests to reduce duplication
- No integration tests yet (testcontainers infrastructure is ready in CI)
- No component-level tests for templ rendering
- No benchmark tests for performance-sensitive paths

### 1.6 Configuration — Simple & Effective

**`main.go:131-136`** — `envOr()` helper for environment-based config with fallbacks.
Clean, no third-party config libraries.

**Areas for improvement:**
- No structured config struct with validation
- No feature flag system for gradual rollouts

### 1.7 Security — Good Defaults, Incomplete Implementation

**Strengths:**
- Distroless Docker image, non-root UID 65532
- Static binary with `-trimpath` (strips local paths from stack traces)
- `CGO_ENABLED=0` for fully static binary
- Embedded assets (no external file reads)
- `slog` structured logging (no plaintext secrets)

**Gaps:**
- No authentication/session handling yet
- No CSRF protection on forms
- No input validation middleware
- No rate limiting
- No audit logging for sensitive operations

---

## 2. TypeScript (vault-js)

### 2.1 Project Setup — Excellent

| Practice | Status |
|----------|--------|
| Zero runtime dependencies | Only devDeps (esbuild, vitest, TS, ESLint) |
| ES modules | `"type": "module"` in package.json |
| Strict TypeScript | `strict: true`, `noUnusedLocals`, `noUnusedParameters` |
| Modern build | esbuild IIFE bundle → `cmd/server/static/vault.js` |
| Private package | `"private": true` prevents accidental npm publish |

**Bundle output**: 2.2 KB uncompressed (~700-800 bytes gzipped) — minimal payload.

### 2.2 Code Organization — Clean & Focused

- `src/index.ts` (52 lines): Public API with 4 exported functions
- `src/htmx-interception.ts` (50 lines): HTMX integration, completely isolated
- `src/index.test.ts` (45 lines): Test suite

Small, focused modules that are easy to audit — critical for security-sensitive code.

### 2.3 Type Safety — Strong

- Strict TypeScript catches most type errors at compile time
- WebCrypto types (`CryptoKey`, `CryptoKeyPair`) used correctly
- Custom HTMX event interfaces (`HtmxConfigRequestDetail`, `HtmxConfigRequestEvent`)
- Guard function `isVaultForm()` ensures type safety before processing

**Areas for improvement:**
- Loose `as EventListener` cast in `htmx-interception.ts:47` — use a typed handler factory
- No exported type interfaces for `EncryptionResult` or `KeyDerivationParams`
- Consider branded types for sensitive data (`Passphrase`, `PlaintextKey`)

### 2.4 WebCrypto Patterns — Well-Designed (Stubs)

Algorithm choices are correct per current standards:
- **AES-256-GCM** for authenticated encryption
- **PBKDF2** for key derivation (NIST-backed)
- **RSA-OAEP** for trade escrow (asymmetric)

Function signatures already match WebCrypto API patterns with correct return types.

**Implementation considerations for when stubs are replaced:**
- PBKDF2 iterations: 600,000+ (OWASP 2023 recommendation)
- GCM nonce: 96 bits (12 bytes), randomly generated per message, never reused
- Salt: minimum 128 bits (16 bytes), random per user, stored server-side
- Non-extractable `CryptoKey` objects (set `extractable: false`)
- IV reuse protection via WeakMap tracking per key

### 2.5 Error Handling — Basic

- Stubs throw descriptive `Error("not yet implemented")` messages
- HTMX handler uses early return instead of throwing (prevents breaking HTMX flow)

**Areas for improvement:**
- No custom error classes (`VaultError`, `VaultCryptoError`)
- No input validation (passphrase length, salt size)
- No global unhandled rejection handler

### 2.6 Testing — Framework Good, Coverage Limited

- Vitest with happy-dom environment
- Tests validate all 4 public functions throw "not yet implemented"
- WebCrypto availability checks (`crypto.subtle` exists)
- CI runs via `task test:vault` with frozen lockfile

**Areas for improvement:**
- No real crypto tests (encrypt/decrypt round-trip, wrong key fails, different ciphertexts)
- No HTMX integration tests (event dispatch simulation)
- No coverage threshold in vitest.config.ts
- No performance tests for key derivation latency

### 2.7 Browser Compatibility — Appropriate

- ES2022 target covers all modern browsers
- Environment detection: `if (typeof document !== "undefined")` guards non-browser contexts
- IIFE bundle format works everywhere

**Areas for improvement:**
- No feature detection for specific WebCrypto algorithms
- No HTTPS requirement check (`WebCrypto` requires secure context)
- `document.body` may not exist if script loads in `<head>` — add DOMContentLoaded fallback
- No cleanup function to unregister HTMX listener on logout

### 2.8 Security — Solid Foundation

**Strengths:**
- Zero dependencies = zero supply chain risk
- No plaintext logging (only `console.debug` for metadata)
- WebCrypto-only (native browser APIs, no JS crypto libraries)
- Keys as opaque `CryptoKey` objects (not exposed as bytes)
- HTMX handler never calls `fetch()` directly

**Gaps for implementation:**
- No input validation on passphrase/salt
- No IV reuse protection mechanism
- No passphrase strength validation
- No constant-time comparison utility
- HTMX listener not removable (persists after logout)

---

## 3. SQL & Database

### 3.1 Schema (Atlas HCL) — Minimal but Correct

**`schema.hcl`** uses declarative Atlas HCL with:
- UUID primary keys via `gen_random_uuid()`
- Automatic timestamps with `now()`
- PostgreSQL 17 target

**Gaps:**
- Only 1 table (`users`) with 2 columns — needs `game_keys`, `trades`, `game_library`
- No indexes, constraints, or foreign keys beyond the primary key
- Missing `updated_at`, `deleted_at` for soft deletes
- No documentation comments in schema

### 3.2 Migrations — Properly Configured

- Atlas versioned migrations with `atlas.sum` checksums for integrity
- Timestamp-prefixed migration files
- `task migrate:diff` generates migrations from schema changes

**Gaps:**
- Only 1 migration exists
- No rollback strategy documented
- No CI step to validate migrations on fresh database
- No migration testing task

### 3.3 Queries — Secure but Sparse

- Named parameters (`@id`) prevent SQL injection
- sqlc `:one` marker for type-safe single-row queries
- Generated code uses proper `pgtype` types

**Gaps:**
- Only 1 query (`GetUserByID`)
- No pagination, filtering, or batch operation patterns
- No query performance documentation

---

## 4. CI/CD Pipeline

### 4.1 GitHub Actions — Comprehensive

**`.github/workflows/ci.yml`** (408 lines) with 5 jobs:

| Job | Purpose | Quality |
|-----|---------|---------|
| Lint | golangci-lint + ESLint + Prettier + codegen verification | Excellent |
| Check OpenSpec | Verify specs archived before merge | Good |
| Test (Go) | Unit + integration with testcontainers | Excellent |
| Test (vault-js) | Vitest with frozen lockfile | Good |
| Test (E2E) | Playwright with real Postgres | Excellent |

**Security best practices in CI:**
- All action versions pinned with commit hashes
- Minimal permissions per job (`contents: read`)
- No elevated `GITHUB_TOKEN` usage
- sqlc downloaded with SHA256 checksum verification

**Codegen verification** (`ci.yml:81-106`): Runs `task generate` and fails if
`git diff` shows uncommitted changes — ensures generated code is always fresh.

**PR feedback**: Posts unified lint results as PR comments, upserts on repeated runs.

**Areas for improvement:**
- No code coverage reporting (Codecov/Coveralls)
- No security scanning (Trivy, gosec, Dependabot)
- No dependency audit (`go list -json -m all | nancy sleuth`)
- No migration validation in CI
- No performance benchmarks or regression detection

### 4.2 Task Runner (Taskfile.yaml) — Well-Organized

Covers lint, test, build, database, hooks, and dev tasks with proper dependencies.

**Gaps:**
- No `task clean` for build artifacts
- No `task db:seed` for test data
- No `task db:reset` for fresh database
- `task build` doesn't include `build:vault`

### 4.3 Git Hooks (lefthook.yml) — Effective

- Pre-commit hooks lint staged files only
- Parallel execution for speed
- Auto-fix with re-staging (`stage_fixed: true`)
- Language-specific hooks (Go + TypeScript)

**Gaps:**
- No pre-push hooks (tests, build verification)
- No commit-msg hook for message format validation
- Go linter runs full project instead of staged files only

---

## 5. Docker & Deployment

### 5.1 Dockerfile — Best-in-Class Security

```
golang:1.26-bookworm (build) → busybox (wget) → distroless/static:nonroot (runtime)
```

- Multi-stage build minimizes image size
- `CGO_ENABLED=0` + `-trimpath` for production-ready static binary
- Non-root UID 65532, no shell, no package manager
- Docker layer caching for Go modules
- Health check configured (30s interval, 5s timeout)

**Minor improvements:**
- Add build-time version injection (`-ldflags "-X main.Version=..."`)
- Add `go mod verify` after download for integrity checking

### 5.2 Docker Compose — Good for Development

Includes full observability stack (Postgres, Prometheus, Loki, Grafana) with persistent
volumes and sensible defaults.

**Gaps:**
- No health checks on services
- No resource limits (CPU/memory)
- Prometheus target hardcoded to `host.docker.internal:8080`

### 5.3 Monitoring — Minimal

- Prometheus with 15-second scrape interval
- No alerting rules, recording rules, or dashboards provisioned
- No application metrics exported yet

---

## 6. Cross-Cutting Concerns

### 6.1 Documentation — Strong Project Docs, Weak Code Docs

**Strong:**
- `CLAUDE.md` comprehensively documents architecture, tooling, conventions
- `.claude/rules/backend.md` and `.claude/rules/vault-js.md` provide path-scoped guidance
- `Taskfile.yaml` has descriptions on every task

**Weak:**
- No JSDoc on TypeScript functions
- No package-level Go comments
- No API documentation (OpenAPI/Swagger)
- No inline security comments explaining crypto decisions

### 6.2 Observability — Foundation Laid

- Structured logging via `slog` (Go stdlib)
- Health/readiness probes ready
- Monitoring stack in Docker Compose (Prometheus + Grafana + Loki)
- Sentry mentioned but not yet integrated

**Gaps:**
- No application metrics exported
- No distributed tracing (OpenTelemetry)
- No slow query logging
- No error tracking integration (Sentry SDK)

### 6.3 Overall Architecture Patterns

The Ports & Adapters architecture is well-positioned:
- **Interfaces** in `internal/port/` (to be defined)
- **Implementations** in `internal/adapter/` (steam, igdb, itad, manual)
- **Business logic** in `internal/service/` (stateless orchestration)
- **Storage** isolated with sqlc codegen
- **Client crypto** completely separated in `vault-js/`

This is a strong foundation that will scale well as features are added.

---

## Summary Scorecard

| Category | Score | Notes |
|----------|-------|-------|
| **Go Project Structure** | 9/10 | Exemplary layout, minimal deps |
| **Go Error Handling** | 5/10 | Incomplete handler responses, no custom types |
| **Go Testing** | 6/10 | Good patterns, limited coverage |
| **Go Security** | 7/10 | Strong defaults, auth not yet implemented |
| **TypeScript Setup** | 9/10 | Zero deps, strict TS, modern tooling |
| **TypeScript Type Safety** | 8/10 | Strict mode, minor casting issues |
| **TypeScript Security** | 7/10 | Solid foundation, implementation pending |
| **TypeScript Testing** | 6/10 | Framework excellent, no crypto tests |
| **SQL/Database** | 5/10 | Correct patterns, extremely minimal schema |
| **CI/CD Pipeline** | 8/10 | Comprehensive, missing security scanning |
| **Docker** | 9/10 | Best-in-class security practices |
| **Task Runner** | 8/10 | Well-organized, minor gaps |
| **Git Hooks** | 8/10 | Effective, could add pre-push |
| **Monitoring** | 4/10 | Infrastructure exists, no actual metrics |
| **Documentation** | 7/10 | Strong project docs, weak code docs |

**Overall: 7.1/10** — Strong engineering foundation with clear architectural vision.
The codebase is early-stage but the practices in place will scale well. Priority
areas are completing the schema, implementing authentication, and adding error
handling to HTTP handlers.

---

## Top 10 Recommendations (Priority Order)

1. **Fix handler error responses**: Write proper HTTP error status codes when render fails
2. **Expand database schema**: Add tables for game keys, trades, wishlists
3. **Implement authentication**: HttpOnly sessions, password hashing, CSRF protection
4. **Add custom error types**: Domain errors in Go, `VaultError` in TypeScript
5. **Restrict CORS origins**: Change from `"*"` to `"https://bartering.games"`
6. **Add security scanning to CI**: Trivy for containers, gosec for Go
7. **Implement WebCrypto functions**: Replace vault-js stubs with real encryption
8. **Add code coverage reporting**: Codecov integration in CI
9. **Export application metrics**: Prometheus counters/gauges for business operations
10. **Add pre-push git hooks**: Run tests before allowing pushes

## Context

The current architecture serves a SvelteKit static build from nginx and a Go API server behind Connect RPC. In practice, the frontend is minimal scaffolding: a root layout with `<header>/<main>/<footer>`, two placeholder routes (`/`, `/login`), a Connect health client, CSS theming with light/dark mode, and an empty `vault/` directory. The only genuine browser-side concern is the WebCrypto vault — AES-256-GCM encryption, PBKDF2 key derivation, and RSA-OAEP escrow — which is pure JavaScript with zero framework dependencies.

This change replaces the two-runtime architecture with a single Go binary that renders HTML via templ, uses HTMX for SPA-like navigation, and compiles the vault crypto as a standalone TypeScript module via esbuild. The database layer (Atlas, sqlc, pgx) is untouched.

## Goals / Non-Goals

**Goals:**
- Single Go binary that serves HTML, static assets, and API responses — one Dockerfile, one deploy target
- templ components for type-safe, compile-time-checked HTML rendering with Go
- HTMX with `hx-boost` for full-page swaps that preserve JavaScript memory (vault key) across navigations
- Standalone vault-js module compiled by esbuild — zero runtime dependencies, testable in isolation
- Vault form interception via HTMX events (`htmx:configRequest`) — no `fetch()` in vault code
- Simplified CI: remove pnpm, frontend test, proto lint/breaking/codegen jobs; add vault-js test job
- Updated Taskfile with `generate:templ`, `build:vault`, and adjusted lint/test/dev tasks

**Non-Goals:**
- Implementing actual vault crypto operations (encryption, key derivation, escrow) — this change provides the scaffold and build pipeline; vault crypto is a separate story
- Adding real page content or features beyond what the current placeholder routes cover
- Changing the database schema, migrations, or sqlc queries
- Server-side rendering of HTMX partial responses — this change establishes the full-page rendering pattern; HTMX fragment endpoints come with feature stories
- Implementing authentication or session management

## Decisions

### 1. templ over `html/template`

**Decision:** Use `github.com/a-h/templ` for server-side HTML rendering.

**Rationale:** templ compiles `.templ` files to Go code, catching HTML structure errors at compile time. It provides type-safe component composition (`{ children... }` for layouts, component parameters for data), integrates with `context.Context` for middleware values (sessions, auth), and produces `_templ.go` files that fit the project's existing codegen-committed-to-git pattern. Standard `html/template` has no compile-time safety, requires runtime parsing, and makes component composition awkward.

**Alternatives considered:**
- `html/template`: No type safety, stringly-typed, runtime errors for template bugs. Rejected.
- `gomponents`: Pure Go HTML construction — verbose for page-level markup, no separate template files. Rejected for readability.

### 2. HTMX with `hx-boost` + `head-support` for SPA-like navigation

**Decision:** Add `hx-boost="true"` on `<body>` with the `head-support` extension.

**Rationale:** `hx-boost` converts link clicks and form submissions into AJAX requests, swapping the `<body>` content without a full page reload. This preserves JavaScript state in `<head>` scripts — critically, the vault encryption key derived from the user's passphrase stays in memory across navigations. The `head-support` extension merges `<head>` elements between pages (per-page `<title>`, CSS, etc.) without re-executing shared scripts. The server always returns full HTML pages, so the app works without JavaScript (graceful degradation) and requires no conditional rendering logic for HTMX vs non-HTMX requests.

**Alternatives considered:**
- Full SPA (React, Svelte): The whole point of this migration is to eliminate the SPA. Rejected.
- No HTMX (traditional multi-page): Works but requires re-deriving the vault key on every navigation (user re-enters passphrase or we use sessionStorage, which has security trade-offs). Rejected.
- Turbo/Turbolinks: Similar to hx-boost but a larger dependency, less control over form interception. Rejected.

### 3. Vault-js as standalone esbuild module

**Decision:** Create `vault-js/` at the repo root with TypeScript source, compile to a single `backend/static/vault.js` via esbuild.

**Rationale:** The vault needs WebCrypto APIs (browser-only), TypeScript for type safety around crypto operations, and zero runtime dependencies (security-sensitive code should have minimal attack surface). esbuild produces a single IIFE bundle — no module loader, no chunk splitting, no framework. The output is a static asset served by the Go binary. Tests run with Vitest using jsdom or happy-dom for WebCrypto polyfill.

**Alternatives considered:**
- Inline `<script>` tags in templ: No TypeScript, no tests, unmaintainable for crypto code. Rejected.
- Go-compiled WASM for crypto: Overcomplicates, WebCrypto is already fast and well-audited. Rejected.
- Keep the vault in the Go backend: Server must never see plaintext keys — client-side encryption is a core architectural requirement. Rejected.

### 4. Form interception pattern (path C) for vault operations

**Decision:** Vault JS listens to `htmx:configRequest` events on forms that need encryption. It reads plaintext from form fields, runs WebCrypto, and stuffs encrypted results into hidden `<input>` fields before the HTMX request fires.

**Rationale:** This keeps the vault module decoupled from HTMX internals — it only uses the event API, never calls `htmx.ajax()` or `fetch()`. The server receives standard form parameters (some of which happen to be ciphertext). Forms work without JavaScript (they just submit plaintext, which the server can reject if encryption is required). The pattern is testable: mock the event, verify the hidden input values.

**Alternatives considered:**
- Vault calls `fetch()` directly: Tight coupling between vault and API, bypasses HTMX entirely, loses `hx-boost` benefits. Rejected.
- Server-side encryption with vault key transmitted to server: Violates the zero-knowledge architecture. Rejected.

### 5. Single Dockerfile (Go distroless)

**Decision:** Remove `frontend/Dockerfile`. The backend Dockerfile produces the only image, which includes static assets (CSS, JS, HTMX, vault.js) embedded or copied into the image.

**Rationale:** With templ rendering HTML server-side, there is no static SPA build to serve from nginx. The Go binary uses `http.FileServer` to serve `/static/*` assets. One image means one deploy target, simpler docker-compose, simpler CI, and no nginx configuration to maintain.

**Static asset strategy:** During development, serve from the `backend/static/` directory on disk (hot reload). In production, use Go's `embed.FS` to bundle assets into the binary for a single self-contained artifact. The embed approach means the distroless image doesn't need a writable filesystem or the static files copied separately.

### 6. Component directory structure

**Decision:** Place templ components in `backend/internal/components/` with subdirectories for organization:

```
backend/internal/components/
├── layout.templ          # Base HTML layout (html, head, body, hx-boost)
├── nav.templ             # Navigation bar partial
├── footer.templ          # Footer partial
└── pages/
    ├── home.templ        # Home page
    └── login.templ       # Login page
```

**Rationale:** Keeping components under `internal/` follows the Go convention that these are not importable by external packages. The flat structure with a `pages/` subdirectory is sufficient at this stage — further organization (partials, fragments) can be added when HTMX partial endpoints are introduced in feature stories.

### 7. HTMX and static asset vendoring

**Decision:** Vendor HTMX (`htmx.min.js`) and the head-support extension into `backend/static/vendor/` rather than using a CDN.

**Rationale:** Self-hosting avoids CDN availability as a dependency, respects user privacy (no third-party requests), and ensures version pinning. The files are small (~14KB gzipped for HTMX). They get embedded into the Go binary alongside other static assets.

## Risks / Trade-offs

**[Risk] templ is a newer tool with a smaller ecosystem than React/Svelte** → Mitigation: templ compiles to standard Go code, so the worst case is maintaining `_templ.go` files manually. The project has no complex UI requirements that would stress templ's capabilities. The a-h/templ project is actively maintained with 8k+ GitHub stars.

**[Risk] Losing TypeScript type safety for the full frontend** → Mitigation: The only TypeScript that matters is the vault crypto module, which retains full type safety. HTML rendering bugs are caught at compile time by templ. The trade-off is acceptable because the UI is server-rendered with minimal client-side logic.

**[Risk] HTMX form interception adds complexity to vault operations** → Mitigation: The form interception is a well-documented HTMX pattern (`htmx:configRequest`). The vault module is testable in isolation — mock the HTMX event, assert the encrypted output. The pattern degrades gracefully (forms still submit without JS, server rejects unencrypted data).

**[Risk] `hx-boost` breaks third-party scripts that expect full page loads** → Mitigation: There are currently no third-party scripts. If needed in the future, specific links can opt out with `hx-boost="false"`. HTMX also fires `htmx:afterSettle` for reinitializing JavaScript after swaps.

**[Risk] Large deletion scope (frontend/, proto/, backend/gen/) increases merge conflict potential** → Mitigation: The current branch is based on latest main, the frontend/proto directories are pure scaffolding with no in-flight feature work, and the change will be implemented in a single PR. The deletion is clean — no partial removal needed.

**[Trade-off] No hot module replacement for templ** → templ has `--watch` mode for regeneration, but changes require a browser refresh (no HMR). This is acceptable for a server-rendered app with minimal client-side state. `air` or similar tools can be added for Go live reload if needed.

**[Trade-off] esbuild for vault-js means a Node.js dev dependency** → esbuild and TypeScript are dev-only dependencies in `vault-js/`. They don't affect the production Go binary. The vault-js build is a pre-compilation step, similar to how `buf generate` was a pre-compilation step for protobuf. pnpm remains the package manager for vault-js, keeping the toolchain consistent.

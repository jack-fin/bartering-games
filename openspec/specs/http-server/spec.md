## MODIFIED Requirements

### Requirement: Chi router with standard middleware
The server SHALL use `go-chi/chi/v5` as the HTTP router with the following middleware applied in order: RealIP, Logger, Recoverer, Compress, CORS.

#### Scenario: Middleware stack is applied
- **WHEN** a request is received by the server
- **THEN** it passes through RealIP, Logger, Recoverer, Compress, and CORS middleware before reaching the handler

### Requirement: Health endpoint
The server SHALL serve a plain-text health check at `GET /healthz` that returns HTTP 200 with body `ok`. The Connect-based `HealthService` handler SHALL be removed.

#### Scenario: Health check via GET
- **WHEN** a client sends `GET /healthz`
- **THEN** the server responds with status 200 and body `ok`

#### Scenario: Connect health endpoint is removed
- **WHEN** a client sends a Connect request to `/bartering.v1.HealthService/Check`
- **THEN** the server responds with 404

### Requirement: Connect handler integration with middleware
Connect service handlers mounted via `r.Mount()` SHALL pass through the same Chi middleware stack (RealIP, Logger, Recoverer, Compress, CORS) as all other routes.

This requirement is superseded — Connect handlers are removed. All routes (templ pages, static assets, API endpoints) pass through the Chi middleware stack.

#### Scenario: Middleware applies to all routes
- **WHEN** any HTTP request is received (page, static asset, or API)
- **THEN** it passes through the full middleware stack before reaching the handler

### Requirement: Server imports templ components
The server entry point (`cmd/server/main.go`) SHALL import templ components from `github.com/jack-fin/bartering-games/internal/components/pages` (updated module path without `backend/` segment).

#### Scenario: Server imports use updated module path
- **WHEN** `cmd/server/main.go` registers page routes
- **THEN** it imports components from `github.com/jack-fin/bartering-games/internal/components/pages`

## ADDED Requirements

### Requirement: templ page routes
The server SHALL register Chi routes that render templ page components for `GET /` (home) and `GET /login` (login).

#### Scenario: Home page route
- **WHEN** a client sends `GET /`
- **THEN** the server responds with HTML rendered by the home page templ component inside the base layout

#### Scenario: Login page route
- **WHEN** a client sends `GET /login`
- **THEN** the server responds with HTML rendered by the login page templ component inside the base layout

#### Scenario: Content-Type header
- **WHEN** a templ page route responds
- **THEN** the `Content-Type` header is `text/html; charset=utf-8`

### Requirement: Static asset route
The server SHALL mount an `http.FileServer` at `/static/*` to serve CSS, JavaScript (HTMX, vault.js), and other static assets. Vendored scripts are served from `/static/lib/` (renamed from `/static/vendor/`).

#### Scenario: Static files are served
- **WHEN** a client requests `/static/styles.css`
- **THEN** the server returns the CSS file with appropriate `Content-Type`

#### Scenario: Lib scripts are served
- **WHEN** a client requests `/static/lib/htmx.min.js`
- **THEN** the server returns the HTMX JavaScript file

#### Scenario: 404 for missing static files
- **WHEN** a client requests `/static/nonexistent.js`
- **THEN** the server responds with 404

#### Scenario: Old vendor path returns 404
- **WHEN** a client requests `/static/vendor/htmx.min.js`
- **THEN** the server responds with 404 (path has moved to `/static/lib/`)

## REMOVED Requirements

### Requirement: Server main uses rpc import alias
**Reason**: Connect RPC is removed. No generated Connect package exists to import.
**Migration**: Server imports templ components from `backend/internal/components/` instead.

### Requirement: Connect handler integration with middleware
**Reason**: Connect RPC handlers are removed. All routes are plain Chi handlers.
**Migration**: Middleware applies to all routes uniformly via the Chi middleware stack.

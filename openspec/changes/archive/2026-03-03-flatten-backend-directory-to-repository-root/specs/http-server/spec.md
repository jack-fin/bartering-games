## MODIFIED Requirements

### Requirement: Server imports templ components
The server entry point (`cmd/server/main.go`) SHALL import templ components from `github.com/jack-fin/bartering-games/internal/components/pages` (updated module path without `backend/` segment).

#### Scenario: Server imports use updated module path
- **WHEN** `cmd/server/main.go` registers page routes
- **THEN** it imports components from `github.com/jack-fin/bartering-games/internal/components/pages`

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

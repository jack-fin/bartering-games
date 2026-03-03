## MODIFIED Requirements

### Requirement: templ dependency and code generation
The project SHALL use `github.com/a-h/templ` as a dependency. Running `templ generate` from the repository root SHALL produce `_templ.go` files from `.templ` source files. Generated `_templ.go` files SHALL be committed to Git.

#### Scenario: templ generate produces Go files
- **WHEN** a developer runs `templ generate` from the repository root
- **THEN** each `.templ` file produces a corresponding `_templ.go` file in the same directory

#### Scenario: Generated code is committed
- **WHEN** a developer clones the repository
- **THEN** `_templ.go` files exist without needing to run `templ generate`

#### Scenario: Generated code matches source
- **WHEN** `templ generate` runs on unchanged `.templ` files
- **THEN** `git diff` shows no changes

### Requirement: Base HTML layout component
The project SHALL contain a layout component at `internal/components/layout.templ` that renders a complete HTML document with `<html>`, `<head>`, and `<body>` elements. The layout SHALL accept a page title and render child content via `{ children... }`.

#### Scenario: Layout renders full HTML document
- **WHEN** a page component uses the layout
- **THEN** the response contains `<!DOCTYPE html>`, `<html>`, `<head>` with the page title, and `<body>` with the page content

#### Scenario: Layout includes HTMX
- **WHEN** the layout renders
- **THEN** the `<head>` includes a `<script>` tag loading HTMX from `/static/lib/htmx.min.js`
- **AND** the `<head>` includes a `<script>` tag loading the head-support extension from `/static/lib/htmx-ext-head-support.js`

#### Scenario: Layout enables hx-boost
- **WHEN** the layout renders
- **THEN** the `<body>` element has `hx-boost="true"` and `hx-ext="head-support"` attributes

#### Scenario: Layout includes vault script
- **WHEN** the layout renders
- **THEN** the `<head>` includes a `<script>` tag loading `/static/vault.js`

### Requirement: Navigation component
The project SHALL contain a navigation component at `internal/components/nav.templ` that renders site navigation inside a `<nav>` element within the layout's `<header>`.

#### Scenario: Navigation renders
- **WHEN** the layout renders
- **THEN** a `<nav>` element with site navigation links is present inside `<header>`

### Requirement: Footer component
The project SHALL contain a footer component at `internal/components/footer.templ` that renders site footer content.

#### Scenario: Footer renders
- **WHEN** the layout renders
- **THEN** footer content is present inside `<footer>`

### Requirement: Component directory structure
templ components SHALL be organized under `internal/components/` with page-level components in a `pages/` subdirectory.

#### Scenario: Directory structure
- **WHEN** a developer inspects `internal/components/`
- **THEN** layout, nav, and footer components exist at the top level
- **AND** page components exist in the `pages/` subdirectory

### Requirement: Static asset serving
The Go server SHALL serve static files from `/static/*` using `http.FileServer`. In production, static assets SHALL be embedded into the binary using Go's `embed.FS`.

#### Scenario: Static files served in development
- **WHEN** a request is made to `/static/styles.css`
- **THEN** the server returns the CSS file with appropriate content type

#### Scenario: Lib scripts served
- **WHEN** a request is made to `/static/lib/htmx.min.js`
- **THEN** the server returns the HTMX library JavaScript file

#### Scenario: Static assets embedded in production binary
- **WHEN** the Go binary is compiled
- **THEN** static assets are embedded via `//go:embed` and served without requiring the filesystem

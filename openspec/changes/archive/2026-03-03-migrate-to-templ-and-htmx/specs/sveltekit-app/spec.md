## REMOVED Requirements

### Requirement: SvelteKit project initialization
**Reason**: SvelteKit frontend is entirely removed. HTML rendering is handled by Go templ components.
**Migration**: Delete `frontend/` directory. Page routes served by templ components in `backend/internal/components/`.

### Requirement: adapter-static configuration
**Reason**: No static SPA build exists. The Go server renders HTML server-side.
**Migration**: No replacement needed — templ renders full HTML documents directly.

### Requirement: ESLint and Prettier linting and formatting
**Reason**: Frontend TypeScript/Svelte linting is removed. vault-js has its own ESLint config.
**Migration**: vault-js `lint:ts` task replaces the frontend lint step.

### Requirement: CSS theming with custom properties
**Reason**: The CSS theming requirement moves to the templ-server capability. The implementation is a plain CSS file served from `/static/styles.css` instead of a Svelte `app.css`.
**Migration**: Templ-server spec defines the same light/dark mode theming via CSS custom properties.

### Requirement: Semantic HTML layout
**Reason**: The semantic HTML requirement moves to the templ-server capability. The layout templ component provides `<header>`, `<main>`, `<footer>`.
**Migration**: Templ-server spec defines the same semantic HTML structure.

### Requirement: Placeholder routes
**Reason**: SvelteKit routes are removed. Placeholder pages are templ components served by Chi routes.
**Migration**: http-server spec defines `GET /` and `GET /login` routes rendering templ page components.

### Requirement: Vitest configuration
**Reason**: Frontend Vitest is removed. vault-js has its own Vitest setup.
**Migration**: vault-js spec defines Vitest configuration for the vault module.

### Requirement: TypeScript strict mode
**Reason**: Frontend TypeScript is removed. vault-js retains TypeScript strict mode.
**Migration**: vault-js spec defines TypeScript strict mode for the vault module.

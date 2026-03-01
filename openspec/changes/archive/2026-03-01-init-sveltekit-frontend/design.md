## Context

The monorepo scaffold (sc-40) created `frontend/` with empty subdirectories (`src/lib/`, `tests/e2e/`, `gen/`). There is no `package.json`, no SvelteKit config, and no runnable frontend. This change initializes the SvelteKit project so subsequent stories can add Connect RPC integration, auth pages, and trade flows.

## Goals / Non-Goals

**Goals:**
- A buildable, runnable SvelteKit project with Svelte 5 and TypeScript
- Biome configured for linting + formatting (replacing ESLint + Prettier)
- CSS custom properties for light/dark theming with automatic system preference detection
- Semantic HTML layout skeleton ready for future content
- Vitest wired with a passing test
- Taskfile wired for lint, test, and dev commands

**Non-Goals:**
- Connect RPC client setup (future story)
- Authentication UI or flows (future story)
- Playwright E2E test setup (future story)
- i18n library integration (future story — but all strings will be hardcoded in English, easily extractable later)
- Component library or design system (premature at this stage)

## Decisions

### 1. Initialize with `npx sv create` into a temporary directory, then merge

The `frontend/` directory already has scaffold subdirectories (`src/lib/`, `gen/`, `tests/`). Running `sv create` directly into `frontend/` would conflict. Strategy: create into a temp directory, then copy the generated files into `frontend/`, preserving our existing subdirectory structure.

**Alternative considered**: Manually creating all files. More tedious and error-prone — `sv create` gives us known-good SvelteKit boilerplate with correct Svelte 5 + TypeScript config.

### 2. pnpm as package manager

Required by the story and project conventions. pnpm provides strict dependency resolution (no phantom deps), faster installs via content-addressable storage, and monorepo support if needed later.

### 3. Biome for linting + formatting (not ESLint + Prettier)

Biome is a single tool replacing both ESLint and Prettier. Faster (Rust-based), zero-config for common rules, and avoids the ESLint/Prettier conflict headaches. `sv create` may scaffold ESLint — we'll remove it and install Biome instead.

Configuration: `biome.json` at `frontend/` root. Enable recommended linting rules and formatting. Set indent to tabs (Svelte ecosystem convention) or spaces based on preference.

### 4. CSS custom properties for theming

Use CSS custom properties (variables) defined in `:root` and `[data-theme="dark"]` (or `@media (prefers-color-scheme: dark)`). No CSS-in-JS, no Tailwind, no external theme library.

Approach:
- Define color tokens as custom properties in a global CSS file (e.g., `app.css`)
- Use `@media (prefers-color-scheme: dark)` for automatic switching
- Components reference variables like `var(--color-bg)`, `var(--color-text)`

**Alternative considered**: Tailwind CSS. Adds a significant dependency and build step. CSS custom properties are sufficient for theming and keep the stack minimal. Tailwind can be added later if the team wants it.

### 5. adapter-node for Docker deployment

SvelteKit's `adapter-node` builds a standalone Node.js server, which is what we need for Docker container deployment. This is configured in `svelte.config.js`.

### 6. Vitest for unit testing

Vitest is the natural choice for Vite-based projects (SvelteKit uses Vite). It reuses the Vite config for transforms, so Svelte components work without extra setup. The `@testing-library/svelte` package can be added later when we need component tests.

For now: one trivial test (e.g., testing a utility function or a simple assertion) to verify the pipeline works.

### 7. Taskfile commands use pnpm

- `lint:ts` → `pnpm biome check .`
- `test:ts` → `pnpm vitest run`
- `dev:frontend` → `pnpm dev`

## Risks / Trade-offs

- **[sv create output may change across versions]** → Pin to the current `sv` version behavior. If the generated scaffold differs, adapt the merge step. Not a long-term risk since this is a one-time setup.
- **[Biome may not cover all Svelte-specific lint rules]** → Biome has Svelte support but it's newer than ESLint's. Accept the trade-off for speed and simplicity. Can add eslint-plugin-svelte later if needed.
- **[No CSS reset or normalize]** → Browsers have minor rendering differences. Acceptable for now; a CSS reset can be added when we start building real UI components.

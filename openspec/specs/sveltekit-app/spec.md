## ADDED Requirements

### Requirement: SvelteKit project initialization
The frontend SHALL be a SvelteKit project using Svelte 5, TypeScript, and pnpm, with a valid `package.json` at `frontend/`.

#### Scenario: Project builds successfully
- **WHEN** a developer runs `pnpm build` from the `frontend/` directory
- **THEN** the project builds without errors

#### Scenario: Project dependencies install
- **WHEN** a developer runs `pnpm install` from the `frontend/` directory
- **THEN** all dependencies install successfully

### Requirement: adapter-static configuration
The SvelteKit project SHALL use `@sveltejs/adapter-static` in `svelte.config.js` with `fallback: "index.html"` for SPA deployment.

#### Scenario: Build produces static file output
- **WHEN** the project is built with `pnpm build`
- **THEN** the output is a directory of static files (HTML, JS, CSS) suitable for serving from any static file server

### Requirement: ESLint and Prettier linting and formatting
The frontend SHALL use ESLint with eslint-plugin-svelte for linting and Prettier with prettier-plugin-svelte for formatting.

#### Scenario: ESLint passes on clean project
- **WHEN** a developer runs `pnpm eslint .` from the `frontend/` directory
- **THEN** no linting errors are reported

#### Scenario: Prettier check passes on clean project
- **WHEN** a developer runs `pnpm prettier --check .` from the `frontend/` directory
- **THEN** no formatting issues are reported

### Requirement: CSS theming with custom properties
The frontend SHALL define CSS custom properties for theming (colors, spacing) and automatically switch between light and dark themes based on the user's system preference via `prefers-color-scheme`.

#### Scenario: Light mode by default
- **WHEN** a user visits the site with system preference set to light mode
- **THEN** the UI renders with light theme colors

#### Scenario: Dark mode detection
- **WHEN** a user visits the site with system preference set to dark mode
- **THEN** the UI renders with dark theme colors

#### Scenario: Theme tokens used consistently
- **WHEN** a component needs a color value
- **THEN** it references a CSS custom property (e.g., `var(--color-bg)`) rather than a hardcoded color

### Requirement: Semantic HTML layout
The root layout (`+layout.svelte`) SHALL use semantic HTML elements: `<header>`, `<main>`, and `<footer>`.

#### Scenario: Layout renders semantic structure
- **WHEN** any page is loaded
- **THEN** the HTML contains a `<header>`, `<main>`, and `<footer>` element

#### Scenario: Main content receives slot
- **WHEN** a page route renders its content
- **THEN** the page content appears inside the `<main>` element

### Requirement: Placeholder routes
The frontend SHALL include placeholder routes for `/` (home) and `/login`.

#### Scenario: Home route renders
- **WHEN** a user navigates to `/`
- **THEN** a page renders with placeholder content

#### Scenario: Login route renders
- **WHEN** a user navigates to `/login`
- **THEN** a page renders with placeholder content

### Requirement: Vitest configuration
The frontend SHALL have Vitest configured for unit testing, integrated with the Vite config.

#### Scenario: Tests run successfully
- **WHEN** a developer runs `pnpm vitest run` from the `frontend/` directory
- **THEN** the test suite executes and reports results

#### Scenario: Trivial test passes
- **WHEN** the test suite runs
- **THEN** at least one test passes, verifying the test pipeline works

### Requirement: TypeScript strict mode
The frontend SHALL use TypeScript with strict type checking enabled.

#### Scenario: Type checking passes
- **WHEN** a developer runs `pnpm svelte-kit sync && pnpm tsc --noEmit` (or equivalent check)
- **THEN** no type errors are reported

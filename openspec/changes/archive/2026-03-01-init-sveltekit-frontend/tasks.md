## 1. Project Initialization

- [x] 1.1 Scaffold SvelteKit project with `npx sv create` (Svelte 5, TypeScript, minimal template) into a temp directory, then merge into `frontend/` preserving existing subdirectories (`src/lib/`, `gen/`, `tests/`)
- [x] 1.2 Install dependencies with `pnpm install`
- [x] 1.3 Configure `svelte.config.js` to use `@sveltejs/adapter-node`

## 2. Linting & Formatting

- [x] 2.1 Remove any ESLint/Prettier config scaffolded by `sv create` (if present)
- [x] 2.2 Install ESLint + Prettier with Svelte plugins and create configs
- [x] 2.3 Verify `pnpm eslint .` and `pnpm prettier --check .` pass

## 3. Theming & Layout

- [x] 3.1 Create global CSS file (`src/app.css`) with CSS custom properties for light/dark theming using `prefers-color-scheme`
- [x] 3.2 Create `src/routes/+layout.svelte` with semantic HTML skeleton (`<header>`, `<main>`, `<footer>`) and global CSS import
- [x] 3.3 Create placeholder route pages: `src/routes/+page.svelte` (home) and `src/routes/login/+page.svelte`

## 4. Testing

- [x] 4.1 Configure Vitest in `vite.config.ts` (or dedicated `vitest.config.ts`)
- [x] 4.2 Add a trivial passing test to verify the pipeline works
- [x] 4.3 Verify `pnpm vitest run` passes

## 5. Taskfile Updates

- [x] 5.1 Wire `lint:ts` to ESLint + Prettier check (replacing stub)
- [x] 5.2 Wire `test:ts` to `pnpm vitest run` (replacing stub)
- [x] 5.3 Add `dev:frontend` task running `pnpm dev` from `frontend/`

## 6. Verification

- [x] 6.1 Verify `pnpm build` succeeds
- [x] 6.2 Verify `task lint:ts` and `task test:ts` pass

## Why

The frontend directory exists as an empty scaffold. We need a working SvelteKit project so subsequent stories (Connect RPC client, auth flows, trade UI) have a runnable foundation with linting, testing, and theming already in place.

## What Changes

- Initialize SvelteKit project in `frontend/` (Svelte 5, TypeScript, pnpm, adapter-node)
- Install and configure Biome for linting + formatting (`biome.json`)
- Set up CSS custom properties for light/dark theming via `prefers-color-scheme`
- Create basic layout with semantic HTML skeleton (header, main, footer) and theme detection
- Add placeholder routes: `/` and `/login`
- Configure Vitest for unit tests with a trivial passing test
- Update `Taskfile.yaml` to wire `lint:ts`, `test:ts`, and add `dev:frontend`

## Capabilities

### New Capabilities
- `sveltekit-app`: SvelteKit project setup — project structure, Svelte/TS config, Biome linting, CSS theming, semantic layout, placeholder routes, Vitest integration.

### Modified Capabilities
- `task-runner`: Wiring `lint:ts` to Biome, `test:ts` to Vitest, and adding `dev:frontend` task.

## Impact

- **New files**: `frontend/package.json`, `frontend/svelte.config.js`, `frontend/vite.config.ts`, `frontend/tsconfig.json`, `frontend/biome.json`, layout/route files under `frontend/src/`, test file(s)
- **Modified files**: `Taskfile.yaml`
- **Dependencies added**: `@sveltejs/kit`, `@sveltejs/adapter-node`, `svelte`, `vite`, `vitest`, `@biomejs/biome`, `typescript`
- **No breaking changes** — greenfield initialization

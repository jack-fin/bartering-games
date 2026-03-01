## 1. Directory Structure

- [x] 1.1 Create proto directories: `proto/bartering/v1/`
- [x] 1.2 Create backend directories: `cmd/server/`, `internal/{handler,service,port,worker,crypto}/`, `internal/adapter/{steam,igdb,itad,manual}/`, `internal/storage/{query,db}/`, `gen/`, `migrations/`
- [x] 1.3 Create frontend directories: `src/lib/{api,vault,components}/`, `gen/`, `tests/e2e/`
- [x] 1.4 Create `.github/workflows/`

## 2. Git Placeholders

- [x] 2.1 Add empty `.gitkeep` file to every leaf directory that has no other files

## 3. Gitignore

- [x] 3.1 Create root `.gitignore` with Go section (binaries, vendor, test cache)
- [x] 3.2 Add Node/TypeScript section (node_modules, .svelte-kit, build)
- [x] 3.3 Add IDE/OS section (.idea, *.swp, .DS_Store, Thumbs.db — do NOT ignore .vscode)
- [x] 3.4 Add Docker section (docker-compose.override.yml)
- [x] 3.5 Add environment files section (.env, .env.local, .env.*.local)

## 4. Verification

- [x] 4.1 Verify all directories from the monorepo-layout spec exist
- [x] 4.2 Verify every leaf directory contains a `.gitkeep`
- [x] 4.3 Verify `.gitignore` covers all required patterns and does not ignore `.vscode/`

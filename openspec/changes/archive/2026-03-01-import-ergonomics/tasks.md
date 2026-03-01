## 1. Go Import Aliases

- [x] 1.1 Update `backend/internal/handler/health.go`: alias `barteringv1` → `pb`, update all type references
- [x] 1.2 Update `backend/internal/handler/health_test.go`: alias `barteringv1` → `pb` and `barteringv1connect` → `rpc`, update all type references
- [x] 1.3 Update `backend/cmd/server/main.go`: alias `barteringv1connect` → `rpc`, update handler constructor call

## 2. SvelteKit Path Alias

- [x] 2.1 Add `$gen` and `$gen/*` alias to `kit.alias` in `frontend/svelte.config.js`
- [x] 2.2 Update `frontend/src/lib/api/index.ts`: replace relative import with `$gen/bartering/v1/health_pb.js`

## 3. Verification

- [x] 3.1 Run `task test:go` — all tests pass
- [x] 3.2 Run `task test:ts` — all tests pass
- [x] 3.3 Run `task lint` — no lint errors

## 1. Move files from backend/ to repo root

- [x] 1.1 Move `backend/go.mod` and `backend/go.sum` to repo root
- [x] 1.2 Move `backend/cmd/` to repo root
- [x] 1.3 Move `backend/internal/` to repo root
- [x] 1.4 Move `backend/migrations/` to repo root
- [x] 1.5 Move `backend/schema.hcl` and `backend/atlas.hcl` to repo root
- [x] 1.6 Move `backend/Dockerfile` and `backend/.dockerignore` to repo root
- [x] 1.7 Remove the now-empty `backend/` directory

## 2. Rename static/vendor/ to static/lib/

- [x] 2.1 Rename `cmd/server/static/vendor/` to `cmd/server/static/lib/`

## 3. Update Go module path and imports

- [x] 3.1 Update `go.mod` module path from `github.com/jack-fin/bartering-games/backend` to `github.com/jack-fin/bartering-games`
- [x] 3.2 Find and replace all import paths in Go source files (replace `github.com/jack-fin/bartering-games/backend/` with `github.com/jack-fin/bartering-games/`)
- [x] 3.3 Run `go mod tidy` to validate the module

## 4. Update templ components for vendor/ → lib/ rename

- [x] 4.1 Update `internal/components/layout.templ` — change `/static/vendor/` references to `/static/lib/`

## 5. Regenerate code

- [x] 5.1 Run `templ generate` from the repo root to regenerate all `_templ.go` files with updated import paths
- [x] 5.2 Run `sqlc generate` from `internal/storage/` to regenerate db code (relative path `../../migrations/` still resolves correctly)

## 6. Update Taskfile.yaml

- [x] 6.1 Remove `dir: backend` from Go tasks (`lint:go`, `test:go`, `test:int`, `generate:templ`, `build`, `migrate`, `migrate:diff`, `dev:backend`)
- [x] 6.2 Update `generate:sqlc` dir from `backend/internal/storage` to `internal/storage`
- [x] 6.3 Update `docker:build` command from `docker build -t bartering-backend ./backend` to `docker build -t bartering-backend .`
- [x] 6.4 Update `build:vault` output path — esbuild `--outfile` from `../backend/cmd/server/static/vault.js` to `../cmd/server/static/vault.js`

## 7. Update CI workflow

- [x] 7.1 Update `.github/workflows/ci.yml` — change `go-version-file: backend/go.mod` to `go-version-file: go.mod`
- [x] 7.2 Remove or change `working-directory: backend` entries to `.` or omit
- [x] 7.3 Update any other path references in CI that include `backend/`

## 8. Update lefthook config

- [x] 8.1 Update `lefthook.yml` — change `lint-go` glob from `backend/**/*.go` to `**/*.go` and remove `root: backend`

## 9. Update Dockerfile

- [x] 9.1 Dockerfile COPY paths already relative — no changes needed (build context changed from `./backend` to `.`)

## 10. Update vault-js build output path

- [x] 10.1 Update `vault-js/package.json` build script — change `--outfile=../backend/cmd/server/static/vault.js` to `--outfile=../cmd/server/static/vault.js`

## 11. Update documentation

- [x] 11.1 Update `CLAUDE.md` repository structure section — remove `backend/` prefix from all paths, document `lib/` rename
- [x] 11.2 Update `.claude/rules/backend.md` and `.claude/rules/vault-js.md` path references

## 12. Verify

- [x] 12.1 Run `go build -o bin/server ./cmd/server/` to verify the build works
- [x] 12.2 Run `go test ./...` to verify all unit tests pass
- [x] 12.3 Run `task lint` to verify linters pass
- [x] 12.4 Verify `task build:vault` produces output at `cmd/server/static/vault.js`
- [x] 12.5 Verify `task generate` runs cleanly with no git diff

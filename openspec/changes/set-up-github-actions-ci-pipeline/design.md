## Context

The project has working pre-commit hooks (lefthook) for local quality enforcement, but no CI pipeline. The risk: hooks can be bypassed with `--no-verify`, and there's no gate on PRs. All linting tools (`golangci-lint`, `buf`, ESLint, Prettier) already run locally via Taskfile. The CI design reuses those Task targets wherever possible.

Current state of `task test:int`: stubbed — prints a message instead of running integration tests. This must be wired up as part of this change so CI can run them.

## Goals / Non-Goals

**Goals:**
- Enforce lint + freshness + tests on every push and PR via GitHub Actions
- Mirror local dev exactly: CI calls `task lint`, `task test:go`, etc. — no duplicate command definitions
- Add `buf breaking --against .git#branch=main` to both CI and pre-commit hooks, with a PR label bypass mechanism
- Wire up `task test:int` to actually run `go test -tags=integration ./...`
- Cache Go modules, pnpm store, and Docker images to keep CI fast

**Non-Goals:**
- Browser E2E tests in CI (Playwright) — deferred to [sc-120](https://app.shortcut.com/bartering-games/story/120)
- Deployment or release automation — deferred to [sc-121](https://app.shortcut.com/bartering-games/story/121)
- Migrating TypeScript linting from ESLint+Prettier to Biome (Biome has limited Svelte support)
- Atlas migrate lint in CI (requires a dev DB service container — deferred to a follow-up)

## Decisions

### D1: CI calls Task targets for most linters; official action for golangci-lint

CI workflow steps call `task lint:ts`, `task lint:proto`, `task test:go`, `task test:ts`, `task test:int` rather than inlining commands. **Exception**: golangci-lint uses the official `golangci/golangci-lint-action` instead of `task lint:go`.

**Rationale for the exception**: `golangci/golangci-lint-action` provides two benefits not achievable with a plain `golangci-lint run` call:
1. **Analysis cache** — golangci-lint has its own internal cache (separate from Go modules). The action restores/saves it automatically. Without it, CI re-analyzes all files from scratch every run (30s → 3min on a real codebase).
2. **PR annotations** — lint violations appear as inline comments on the PR diff, not just in the log.

For all other linters (buf, ESLint, Prettier), no equivalent official action with meaningful cache benefits exists, so Task targets remain the source of truth.

`task lint:go` continues to work locally — the action runs the same `golangci-lint run ./...` under the hood with the same config.

### D2: Three parallel jobs — lint, test-go, test-ts

The lint job runs all linters plus the generated-code freshness check. `test-go` and `test-ts` run independently in parallel. `test-go` runs unit tests first, then integration tests sequentially within the same job (they share the same Go build cache and Docker environment).

**Rationale**: Lint failures are fast to detect and shouldn't block test jobs. Integration tests need Docker, which is available on `ubuntu-latest` runners.

### D3: Freshness check via generate + diff

After running `task generate` (buf + sqlc), the job runs `git diff --exit-code`. A non-empty diff means generated code was not checked in up to date.

**Rationale**: Generated code is committed to the repo (per CLAUDE.md). This check ensures no one modifies `.proto` or SQL query files without regenerating.

### D4: Unified PR lint comment — updated on re-run, not duplicated

All non-golangci-lint linters (`task lint:ts`, `task lint:proto`, `buf breaking`, freshness check) post their results as a **single unified PR comment** that is updated (not re-created) on each CI run.

**Implementation**:
- Each lint step runs with `continue-on-error: true` and captures stdout/stderr into a step output
- At the end of the lint job, an `actions/github-script` step collects all step outcomes and outputs, formats them into a markdown comment, and upserts it:
  - Search existing bot comments for the hidden marker `<!-- bartering-games-ci-lint -->`
  - If found: call `updateComment`; if not found: call `createComment`
- Comment format uses collapsible `<details>` sections for verbose linter output (readable but not overwhelming)
- On a fully-passing run the comment is updated to show all-green status (not deleted — confirms CI ran cleanly)
- Only runs on `pull_request` events (push to branch without PR has no comment target)

**buf breaking label bypass** is part of this comment: when `buf breaking` fails without the `api:breaking-change` label, the comment section for buf breaking includes instructions for applying the label. The job step then hard-fails. When the label is present, the comment shows a warning but the job continues.

**Rationale**: Surfacing all lint errors in one readable PR comment means reviewers don't have to dig through CI logs. Updating in-place keeps the PR thread clean. golangci-lint is excluded because the official action already provides inline PR diff annotations, which are more useful than a comment for Go lint.

**For pre-commit**: The hook still runs `buf breaking`. Developers with intentional breaking changes can skip just that command with `LEFTHOOK_SKIP=lint-proto-breaking git commit` (documented in spec).

### D5: Keep ESLint + Prettier for TypeScript linting

**Rationale**: Biome has limited Svelte file support. The project uses `.svelte` files extensively. ESLint + Prettier already work correctly for the current stack. CI uses `task lint:ts` to stay consistent with local dev.

### D6: Docker image caching for integration tests

The `test-go` job pre-pulls and caches the Postgres Docker image used by testcontainers before running integration tests. Uses `actions/cache` to persist the image tarball across runs (keyed on the image digest).

**Implementation**:
```
- Restore Docker image cache (keyed by image:tag)
- If cache miss: docker pull postgres:16-alpine && docker save → cache
- If cache hit: docker load
- Run task test:int (testcontainers finds the image already pulled)
```

**Rationale**: testcontainers checks for a locally available image before pulling from the registry. Pre-loading from cache avoids a ~200MB registry pull on every run. The cache key uses the full image tag (including minor version) to invalidate when the image is pinned to a new version.

### D7: Atlas migrate lint — deferred

`atlas migrate lint` requires a running dev database. Adding a Postgres service container is feasible but adds complexity. Deferred to a follow-up change to keep scope focused.

## Risks / Trade-offs

- **`buf breaking` pre-commit is strict on feature branches**: Commits that add a new breaking proto change will be blocked locally. The `LEFTHOOK_SKIP` escape hatch exists but should be rare. Intentional breaks go through the PR label flow. → Acceptable; breaking changes should require explicit acknowledgment.
- **Taskfile hermetic-ness**: Some tasks assume ambient tools are installed. CI must install those tools explicitly in workflow steps. → Mitigation: all required tools (golangci-lint, buf, sqlc, pnpm) installed in setup steps before calling Task targets.
- **Docker cache invalidation**: If testcontainers is updated to use a different Postgres version, the cache key won't match and a fresh pull happens. → Acceptable; version bumps are infrequent and the cache misses gracefully.

## Open Questions

1. **Atlas migrate lint**: Should we add a Postgres service container to the lint job and enable `atlas migrate lint`? If yes, this is a follow-up change.
2. **`task test` aggregate**: Should `task test:int` be added to `task test`? It requires Docker, which isn't always available locally. Currently `task test` only runs unit tests.

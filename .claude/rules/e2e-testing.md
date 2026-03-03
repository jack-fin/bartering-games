---
paths:
  - "internal/components/**/*"
  - "cmd/server/main.go"
  - "e2e/**/*"
---

# E2E Testing

## Keep Tests Current

When adding, removing, or changing HTTP routes or page templates:
- Update or add E2E tests in `e2e/` to cover the new behavior
- If a route is removed, remove its corresponding test assertions
- Smoke test (`e2e/smoke.spec.ts`) should always cover core navigation paths

## Fixtures

- Use the extended `test` from `e2e/fixtures.ts` for tests requiring authentication
- Keep fixture helpers in `e2e/fixtures.ts` — do not scatter setup logic across test files

## Running

- `task test:e2e` runs Playwright (opt-in, not part of `task test`)
- E2E tests target a Go backend on port 3100 (configurable via `E2E_PORT`)

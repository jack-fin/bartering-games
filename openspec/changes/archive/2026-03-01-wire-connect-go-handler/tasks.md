## 1. Backend Health Handler

- [x] 1.1 Create `backend/internal/handler/health.go` implementing `HealthServiceHandler` with `Check` returning `SERVING_STATUS_SERVING`
- [x] 1.2 Wire the handler into `cmd/server/main.go`: import handler package, call `NewHealthServiceHandler`, mount with `r.Mount()`
- [x] 1.3 Remove the `GET /healthz` route from `cmd/server/main.go`

## 2. Backend Tests

- [x] 2.1 Create `backend/internal/handler/health_test.go` with a test that starts `httptest.NewServer` with the Chi router, calls `Check` via `NewHealthServiceClient`, and asserts `SERVING_STATUS_SERVING`
- [x] 2.2 Add a test case that calls the health endpoint using Connect-JSON codec and verifies a valid response

## 3. Frontend Connect Client

- [x] 3.1 Add `@connectrpc/connect` and `@connectrpc/connect-web` dependencies via pnpm (already in package.json)
- [x] 3.2 Create `frontend/src/lib/api/transport.ts` with a `createConnectTransport` configured from an environment variable (default `http://localhost:8080`)
- [x] 3.3 Create `frontend/src/lib/api/index.ts` that exports a typed `HealthService` client using the shared transport

## 4. Verification

- [x] 4.1 Run `task test:go` and confirm all tests pass
- [x] 4.2 Run `task lint` and confirm no lint errors

## Context

The proto definitions for `HealthService` are complete and code generation produces both a Go handler interface (`HealthServiceHandler` in `barteringv1connect`) and TypeScript client types (`HealthService` in `frontend/gen/`). The Chi router is running with middleware but only serves two plain-text endpoints (`/healthz`, `/readyz`). No Connect handlers are mounted yet, so the proto-to-handler-to-client pipeline is unproven.

## Goals / Non-Goals

**Goals:**
- Prove the full pipeline: proto definition → generated Go handler → working Connect endpoint → TypeScript client call
- Establish the pattern for mounting Connect handlers on Chi so future services follow the same approach
- Set up the frontend Connect transport so SvelteKit pages can call backend RPCs
- Replace the plain-text `/healthz` with the Connect-based health check (richer status reporting)

**Non-Goals:**
- Implementing any services beyond health (authentication, trading, etc.)
- Adding gRPC or gRPC-Web protocol support beyond what Connect provides by default
- Production readiness checks in the health handler (database, workers) — that's a future story
- Server-side streaming or bidirectional RPCs
- Frontend UI components that display health status — only the transport client setup

## Decisions

### 1. Mount Connect handler via `r.Mount()` on Chi

Connect's `NewHealthServiceHandler` returns `(path, http.Handler)`. Chi's `r.Mount(path, handler)` delegates an entire subtree to a handler, which is exactly the pattern Connect expects. This avoids manually registering each RPC path.

**Alternative considered:** Using `r.Handle()` with a wildcard — more verbose and fragile if RPCs are added to the service. `r.Mount()` is the idiomatic Chi approach for subtree delegation.

### 2. Remove `/healthz`, keep `/readyz` as plain HTTP

The Connect health handler serves at `/bartering.v1.HealthService/Check`, which replaces the need for `/healthz`. The `/readyz` endpoint stays as a plain `GET` because container orchestration probes (Kubernetes, Docker healthchecks) need a simple HTTP GET endpoint that doesn't require a Connect client or POST request.

**Alternative considered:** Keeping both `/healthz` and the Connect health endpoint. Redundant — two health endpoints diverging over time is worse than one source of truth. Kubernetes probes should use `/readyz`; application health checks should use the Connect RPC.

### 3. Handler implementation in `backend/internal/handler/`

The health handler struct implements `barteringv1connect.HealthServiceHandler`. It lives in `internal/handler/health.go`. For now it returns `SERVING` unconditionally. Future stories will inject dependencies (DB pool, worker status) to make the check meaningful.

The handler does not embed `UnimplementedHealthServiceHandler` — since there's only one method, we implement it directly. If a new RPC is added to the proto, the compiler will catch the missing method.

### 4. Frontend Connect client via `@connectrpc/connect-web`

The frontend uses `createConnectTransport` from `@connectrpc/connect-web` to create an HTTP transport, then `createClient` from `@connectrpc/connect` to instantiate typed service clients. The transport is configured once in `src/lib/api/client.ts` and re-exported for use across the app.

**Alternative considered:** Using `@connectrpc/connect-node` or raw fetch. `connect-web` is purpose-built for browser environments with proper content-type handling and is the recommended approach from the Connect team.

### 5. Go test uses `httptest.NewServer` + Connect client

The test starts an `httptest.NewServer` with the Chi router (including the mounted Connect handler), then uses the generated `NewHealthServiceClient` to call the endpoint. This validates both the Connect binary protocol and the JSON codec in a single test file. No testcontainers needed — this is a pure unit test.

## Risks / Trade-offs

- **Removing `/healthz` breaks existing consumers** → Mitigated: the project is pre-launch with no external consumers. `/readyz` remains for infra probes.
- **Connect's `r.Mount()` path must match exactly** → The generated handler returns the mount path, so we use it directly rather than hardcoding. If the proto package changes, the path updates automatically.
- **Frontend transport hardcodes base URL** → We'll use an environment variable (`PUBLIC_API_URL` or similar) to configure the backend URL, with a sensible default for local dev (`http://localhost:8080`).
- **CORS for Connect requests** → Connect uses POST requests with `application/proto` or `application/json` content types. The existing CORS config allows `POST` and `Content-Type` headers, so this works without changes.

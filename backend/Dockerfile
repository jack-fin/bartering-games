# ── Build stage ───────────────────────────────────────────────────────────────
FROM golang:1.26-bookworm AS build

WORKDIR /app

# Copy dependency manifests first to maximise layer cache hits
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Compile a fully static Linux binary; -trimpath removes local paths from stack traces
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -o /bin/server ./cmd/server/

# ── Wget stage ────────────────────────────────────────────────────────────────
# busybox:musl is statically linked, so wget runs in distroless with no libc
FROM busybox:1-musl AS busybox

# ── Runtime stage ─────────────────────────────────────────────────────────────
# distroless/static:nonroot — no shell, no package manager, runs as UID 65532
FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=build /bin/server /server
COPY --from=busybox /bin/wget /bin/wget
USER 65532:65532

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD ["/bin/wget", "-qO-", "http://localhost:8080/healthz"]

ENTRYPOINT ["/server"]

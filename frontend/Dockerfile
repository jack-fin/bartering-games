# ── Build stage ───────────────────────────────────────────────────────────────
FROM node:22-alpine AS build

WORKDIR /app

RUN npm install -g pnpm

# Copy dependency manifests first to maximise layer cache hits
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm run build

# ── Runtime stage ─────────────────────────────────────────────────────────────
# adapter-node bundles all deps via Vite; only build/ and package.json are needed.
# package.json is required for Node to resolve "type": "module".
FROM node:22-alpine

WORKDIR /app

COPY --from=build /app/build ./build
COPY --from=build /app/package.json ./

USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- http://localhost:3000/ || exit 1

CMD ["node", "build/index.js"]

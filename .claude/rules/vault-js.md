---
paths:
  - "vault-js/**/*"
---

# Vault JS Standards

The vault-js module is a standalone TypeScript package compiled by esbuild into a single
IIFE bundle (`cmd/server/static/vault.js`). It has zero runtime dependencies.

## Security

- Never log plaintext keys, passphrases, or derived key material
- All crypto operations use the WebCrypto API (`crypto.subtle`) — no third-party crypto libraries
- The vault key lives in JS memory only — never persisted to localStorage, sessionStorage, or cookies

## Code Style

- TypeScript uses ESLint + Prettier for linting + formatting
- Strict mode enabled (`"strict": true` in tsconfig.json)
- All exports must be typed — no `any` types in the public API

## HTMX Integration

- Vault JS intercepts HTMX form submissions via `htmx:configRequest` events
- It identifies vault-marked forms by the `data-vault-encrypt` attribute
- The module never calls `fetch()` or `htmx.ajax()` directly — it only modifies form parameters

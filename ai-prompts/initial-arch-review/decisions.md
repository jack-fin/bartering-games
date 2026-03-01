# bartering.games — Architecture Decisions

## Project Overview
A Steam key bartering platform where gamers can trade game keys.
Domain: bartering.games

## Decided

### Tech Stack: TypeScript Frontend (SvelteKit) + Go Backend
- **Frontend**: SvelteKit (Svelte 5) — compiled output, no runtime overhead,
  smallest bundle sizes, excellent mobile performance by default. SSR for game
  pages (SEO), client-side navigation for trading dashboard.
- **Backend**: Go (paired with Connect framework)
- **Rationale**: Go's native concurrency model is ideal for the background sync
  workers (Steam library sync, wishlist sync, bundle scraping) that are
  fundamental to this project. SvelteKit chosen over Next.js for readability,
  lighter bundles, simpler self-hosting, and no Vercel dependency. TypeScript
  frontend handles client-side encryption vault logic.

### Type Sharing: Protobuf + Buf + Connect
- `.proto` files as the single source of truth for API contracts
- `buf generate` produces both Go and TypeScript code
- Connect framework for RPC communication (supports JSON over HTTP/1.1)
- Streaming RPCs for real-time features (trade notifications, sync progress)
- **Rationale**: More concise and readable than OpenAPI YAML. Unified
  communication layer — generated type-safe clients on both sides. Native
  streaming support for trade notifications and sync progress.

### Repository Structure: Monorepo
```
bartering-games/
├── CLAUDE.md               # AI context for the whole project
├── openspec/               # OpenSpec artifacts (changes, specs)
├── proto/                  # Protobuf definitions (source of truth)
│   ├── buf.yaml            # Buf module configuration
│   ├── buf.gen.yaml        # Code generation config
│   └── bartering/v1/       # Versioned API definitions
├── backend/                # Go API server + background workers
│   ├── go.mod
│   ├── cmd/server/         # Entrypoint
│   ├── internal/           # Private packages (Go convention)
│   │   ├── handler/        # Connect RPC handlers
│   │   ├── service/        # Business logic (uses ports, never adapters)
│   │   ├── port/           # Interface definitions (AuthProvider, GameCatalog, etc.)
│   │   ├── adapter/        # Platform implementations
│   │   │   ├── steam/      #   Steam OpenID, Web API, Store API
│   │   │   ├── igdb/       #   IGDB cross-platform game data
│   │   │   ├── itad/       #   IsThereAnyDeal bundle data
│   │   │   └── manual/     #   User-submitted games/bundles
│   │   ├── storage/        # Database access (Postgres)
│   │   ├── worker/         # Background sync goroutines
│   │   └── crypto/         # Server-side crypto utilities
│   ├── gen/                # Generated protobuf Go code
│   ├── migrations/         # Database migrations
│   └── Dockerfile
├── frontend/               # SvelteKit web UI
│   ├── package.json
│   ├── svelte.config.js
│   ├── src/
│   │   ├── lib/
│   │   │   ├── api/        # Connect client setup
│   │   │   ├── vault/      # Client-side encryption logic
│   │   │   └── components/
│   │   └── routes/         # Pages
│   ├── gen/                # Generated protobuf TS code
│   ├── tests/
│   │   ├── unit/
│   │   └── e2e/            # Playwright browser tests
│   └── Dockerfile
├── docker-compose.yaml     # Local dev (Postgres, etc.)
├── Taskfile.yaml           # Task runner
└── .github/workflows/      # CI/CD
```
- **Rationale**: Claude Code / OpenSpec can see entire system in one repo.
  Proto changes + Go handlers + TS client in one commit. One grep finds all usages.

### Generated Code: Checked into Git
- Generated protobuf code (backend/gen/, frontend/gen/) committed to repo
- CI validates generated code is up to date
- **Rationale**: Clone and go — no buf install required to build. Contributors
  can browse generated types on GitHub. Code review shows what changed.

### Task Runner: Taskfile
- Taskfile.yaml (https://taskfile.dev) instead of Makefile
- **Rationale**: Clean YAML syntax, cross-platform, readable. Aligns with
  "readability over cleverness" principle.

### Database: PostgreSQL + Atlas Migrations
- Primary data store for all application data
- **Atlas** for database migrations (SQL-mode schema definitions, not HCL)
- Atlas auto-generates migration SQL by diffing desired schema vs current state
- `atlas migrate lint` in CI to catch destructive/risky changes (valuable for
  open-source PRs)
- Query layer: sqlc + pgx (see "Go Query Layer" section below)

### Deployment: Kamal 2 on Hetzner VPS
- **Kamal 2** for container deployment (zero-downtime deploys, built-in SSL
  via Traefik + Let's Encrypt, Docker-based)
- **Hetzner CX22** (~$5/month) — 2 vCPU, 4GB RAM, 40GB SSD
- **Docker images per service** — separate images for Go backend and SvelteKit frontend
- **GHCR** (GitHub Container Registry) for image storage (free for public repos)
- **PostgreSQL** runs as a Kamal "accessory" (Docker container with persistent volume)
- **OpenTofu** (optional) for server provisioning if reproducibility is needed
- **Rationale**: Cheapest viable deployment (~$5/month total). Zero cloud lock-in —
  swap providers by changing one IP address. Production-proven (37signals runs
  Basecamp/HEY on Kamal). Simple CI/CD — one `kamal deploy` command.

### Platform Abstraction Layer (Ports and Adapters)
- **Ports** (Go interfaces in `internal/port/`):
  - `AuthProvider` — platform login (Steam OpenID 2.0, future OAuth2 for Epic/GOG)
  - `GameCatalog` — game search, details, bulk sync
  - `LibraryProvider` — user's owned games + wishlist from a platform
  - `BundleSource` — bundle data for games
- **Adapters** (implementations in `internal/adapter/`):
  - `steam/` — Steam Web API, Store API, OpenID, undocumented endpoints where needed
  - `igdb/` — IGDB (Twitch) for cross-platform game ID resolution and richer metadata
  - `isthereanydeal/` — bundle/deal data from IsThereAnyDeal API
  - `manual/` — user-submitted games and bundles
- **Composite catalog** — DB is canonical store, falls back to live API, merges user
  submissions. Background workers enrich game data lazily.
- **Rate limiting** — shared HTTP client per adapter with `golang.org/x/time/rate`
- **Canonical game model** — one `games` record per game, linked to multiple
  `game_platform_ids` (steam, epic, gog, etc.) for cross-platform identity
- **IGDB** for cross-platform ID resolution; plan for a data quality layer on top
- **No platform-specific extensions for now**, but architecture supports adding them later
- **Wishlist strategy**: Import from Steam on first sync + periodic background sync.
  Users can also add/remove games from wishlist directly on bartering.games.
  Platform wishlist is merged with local wishlist.
- **Rationale**: Core domain never imports a specific adapter. Tests use mock adapters.
  Adding a new platform = implementing the interfaces, no changes to core logic.

### Game Data Enrichment Strategy
- **Three-tier approach:**
  1. **Bootstrap (one-time at launch):**
     - Import Steam app list (IDs + names + types) — keep games AND DLC (not software/videos)
     - IGDB bulk enrichment: descriptions, images, genres, cross-platform IDs, release dates.
       ~50K items at 500/page, 4 req/sec = minutes, not hours.
     - IsThereAnyDeal: bundle history, pricing, active deals for all tracked games
  2. **Lazy enrichment (on-demand):**
     - User searches for a game → found with full data? Return it.
     - Found with minimal data? Return what we have + queue background enrichment.
     - Not in DB? Live query IGDB + Steam Store API, import + return.
  3. **Priority enrichment (background workers):**
     - HIGH: games with active trades, searched recently, keys stored on platform
     - MEDIUM: games on wishlists, owned by active users, in recent bundles
     - LOW: everything else
     - Freshness: HIGH=7 days, MEDIUM=30 days, LOW=90 days, bundles=daily
- **Enrichment queue**: Postgres-based using `SELECT ... FOR UPDATE SKIP LOCKED`
  (no Redis needed). Table tracks game_id, source, priority, status, attempts.
- **App types**: Import both games AND DLC from Steam. DLC keys are tradeable.
  Users can mark ownership of DLC keys or complete collection keys. Filter out
  non-game items (software, videos, soundtracks, demos, betas, tools).
- **Images**: Use Steam CDN images for Steam games (familiar to users), IGDB images
  as fallback or for non-Steam games. Store image URLs from both sources, display
  based on context.
- **IsThereAnyDeal bundle history**: Import and display bundle history per game.
  Useful signals: "was in 3 bundles → keys likely in circulation," bundle expiration
  dates, active bundles = "keys being minted now," historical low price for trade
  value estimation.
- **Data staleness tracking**: Each game tracks `igdb_enriched_at`, `steam_enriched_at`,
  `itad_enriched_at` timestamps. Priority worker recalculates enrichment_priority
  weekly based on trade activity, search frequency, and wishlist appearances.

### Steam-Specific Notes
- Steam uses OpenID 2.0 (NOT OAuth2) — only auth method Steam supports for third parties
- Steam's wishlist API was removed from public Web API (2023). Use undocumented
  `store.steampowered.com/wishlist/profiles/{id}/wishlistdata/` endpoint or
  community Go libraries
- `ISteamApps/GetAppList` returns ~200K apps with minimal data (ID + name only).
  Enrichment via Store API is rate-limited (~200 req/5min). IGDB is the primary
  bulk enrichment source (72x better rate limits).

### Encryption Architecture: Vault + Asymmetric Escrow

**Overview**: Game keys are encrypted client-side in the browser before reaching the
server. The server NEVER sees plaintext game keys. Auto-reveal on trade acceptance
is achieved via asymmetric escrow — each party encrypts their key for the counterparty
during their action (offer creation or acceptance).

**Per-user cryptographic material:**
- Vault passphrase — known only to the user, never sent to server
- Salt — random, per-user, stored on server
- Vault key — derived via PBKDF2(passphrase, salt) in the browser, never leaves browser
- RSA-OAEP keypair — public key stored on server (plaintext), private key stored on
  server encrypted with vault key (server cannot decrypt it)

**Vault passphrase options (user's choice):**
- **Option 1 (recommended):** Separate vault passphrase — more secure, compromise of
  login doesn't compromise vault. UI should advise this option.
- **Option 2 (convenience):** Use login password as vault passphrase — simpler UX,
  one less thing to remember. Trade-off: if login is compromised, vault is too.
- User chooses during vault setup. Can change later in settings.
- Either way: if passphrase is forgotten/lost, stored keys are irrecoverable (by design).

**Algorithms (all via WebCrypto API, no external libraries):**
- Key derivation: PBKDF2 with SHA-256, 600,000+ iterations, random 128-bit salt
- Symmetric encryption: AES-256-GCM with random IV per encryption
- Asymmetric encryption: RSA-OAEP with SHA-256, 4096-bit keys

**Storing a game key:**
1. Vault unlocked (passphrase entered this session, vault_key in memory)
2. Browser encrypts game key with vault_key via AES-256-GCM
3. Encrypted blob sent to server — server cannot decrypt

**Trade flow (auto-reveal):**
1. Alice creates offer: browser decrypts her key from vault, encrypts it with
   Bob's public key (RSA-OAEP), sends escrow blob to server
2. Bob accepts: browser decrypts his key from vault, encrypts it with Alice's
   public key, sends escrow blob. Server marks trade accepted.
3. Both parties decrypt the escrow blob encrypted for them using their own
   private key → keys revealed. Server never saw plaintext.
4. Counteroffers follow the same pattern — each action that commits keys requires
   the user's browser to create a new escrow blob.

**Fallback when keys not stored in vault:**
- If either party hasn't stored their key, trade falls back to manual exchange.
- Modal shows counterparty's Steam profile link for direct communication.

**Vault session management:**
- vault_key held in JavaScript memory only (NOT localStorage, NOT cookies)
- Survives page navigations via SvelteKit client-side routing (no full page reloads)
- Lost when tab/browser is closed — must re-enter passphrase next visit
- Optional "remember for session" using sessionStorage with defense-in-depth
  (encrypted with a session-specific random key that lives only in memory)

**Security considerations:**
- XSS is the #1 attack surface — vault_key in memory could be stolen. Mitigate with
  CSP headers, input sanitization, SvelteKit's built-in protections.
- Keypair rotation locked while trades are pending (counterparty's escrow blob was
  encrypted with the public key at offer time).
- Escrow blobs stored durably in Postgres with backups. If lost, user can re-create
  from their vault (original encrypted key still there).
- Open-source code makes encryption claims verifiable by anyone.

**Transparency page:**
- Public-facing page explaining how keys are protected
- "We never see your keys. We cannot recover them. View our open-source code."
- Link to the `frontend/src/lib/vault/` source code

**Frontend code location:**
```
frontend/src/lib/vault/
├── crypto.ts       # WebCrypto wrappers (PBKDF2, AES-GCM, RSA-OAEP)
├── vault.ts        # Vault state management (lock/unlock/store/retrieve)
├── escrow.ts       # Trade escrow (encrypt-for-counterparty, decrypt-from)
└── vault.test.ts   # Unit tests (crypto logic is pure functions, very testable)
```
- All crypto is client-side TypeScript. Backend stores and retrieves opaque blobs only.

### Cross-Platform Game Deduplication & Product Model

**Two distinct concepts:**
- **Game identity** — "Portal 2" is the same game across Steam, GOG, Epic. Users
  SEARCH by game identity. One search result for "Portal 2" regardless of platform.
- **Product identity** — "Portal 2 (Steam key)" vs "Portal 2 (GOG key)" are different
  products with different keys. Users TRADE by product identity.

**Parent-child product relationships:**
- Games can have editions and DLC as children in the `games` table:
  - `Elden Ring` (type=game, parent_id=NULL)
  - `Elden Ring Deluxe Edition` (type=edition, parent_id → Elden Ring)
  - `Elden Ring Shadow of the Erdtree` (type=dlc, parent_id → Elden Ring)
- Search "Elden Ring" → shows base game as primary result with editions/DLC
  visible as expandable sub-items.
- When a user stores a key, they select the SPECIFIC product (base game, deluxe,
  GOTY, complete edition, specific DLC, etc.) — the UI must make this easy and clear.
- Steam app IDs naturally distinguish editions (each has its own app ID), so
  platform IDs on the `game_platform_ids` table map to specific products.

**Data model:**
```
games table:
  id            BIGSERIAL PK
  name          TEXT
  normalized_name TEXT       -- for matching (lowercase, stripped, etc.)
  parent_id     BIGINT FK → games (NULL for base games)
  type          TEXT         -- 'game', 'edition', 'dlc'
  igdb_id       BIGINT
  description   TEXT
  header_image  TEXT
  genres        TEXT[]
  release_date  DATE
  source        TEXT         -- 'steam_import', 'igdb_import', 'user_submitted'
  ...enrichment timestamps...

game_platform_ids table:
  game_id       BIGINT FK → games
  platform      TEXT         -- 'steam', 'gog', 'epic', etc.
  platform_id   TEXT         -- Steam app ID, GOG ID, etc.
  UNIQUE(platform, platform_id)
```

**Five-layer dedup quality pipeline:**

1. **IGDB (automated, ~95% confidence)** — IGDB's `external_games` link games
   across platforms. Auto-apply. Handles ~80% of all games.

2. **IsThereAnyDeal cross-reference (automated, ~90% confidence)** — ITAD tracks
   games across storefronts. Fills gaps IGDB misses. Auto-apply.

3. **Normalized name matching (automated, variable confidence)** — For games with
   no IGDB/ITAD cross-reference. Normalization pipeline: lowercase → strip
   trademark symbols → strip leading articles → normalize punctuation → strip
   edition suffixes → normalize roman numerals → collapse whitespace.
   Confidence scoring adds/subtracts based on signals:
   - Same developer (+20%), same release year ±1 (+15%), same genres (+10%)
   - Release years differ 5+ (-30%), different developer (-15%), DLC vs base (-40%)
   - Score >= 85% → auto-apply. Score 50-85% → queue for review. Below 50% → discard.

4. **Community curation (human, variable confidence)** — Users can flag incorrect
   matches or suggest new ones. Voting system (agree/disagree). 3+ agrees with
   0 disagrees → auto-apply. 3+ disagrees → auto-reject. Contested → admin review.

5. **Admin review queue (human, 100% confidence)** — Site operator and trusted
   contributors review flagged items. Final authority on merge/split decisions.

**Tracking table:**
```
game_matches table:
  id, game_id_a, game_id_b, match_type ('same_game'|'edition_of'|'dlc_of'|'not_same'),
  confidence (0.0-1.0), source ('igdb'|'itad'|'name_match'|'user_report'|'admin'),
  source_detail (JSONB evidence), status ('applied'|'pending_review'|'rejected'),
  reviewed_by, reviewed_at

game_match_votes table:
  match_id, user_id, vote ('agree'|'disagree'), UNIQUE(match_id, user_id)
```

**Phased rollout:**
- Phase 1 (launch): IGDB cross-platform IDs only (auto-applied). ~80% coverage.
- Phase 2 (post-launch): Add ITAD cross-ref + name matching + admin review queue. ~95%.
- Phase 3 (community): User voting, match suggestions, trusted contributor role.

### Testing Strategy

**Browser E2E: Playwright**
- SvelteKit's officially recommended browser testing framework
- Multi-browser support: Chromium, Firefox, WebKit
- **Multi-context support** — critical for testing two-user trade flows (Alice creates
  offer in one browser context, Bob accepts in another, both see revealed keys)
- Cross-origin navigation support for Steam OAuth testing (mock Steam callback)
- `playwright codegen` records tests by clicking through the UI — productivity
  multiplier for solo dev and agentic coding
- GitHub Actions integration is trivial (`npx playwright install --with-deps`)

**Full testing stack:**
- **Go unit tests** (`go test`) — business logic, handlers, workers, storage
- **Go integration tests** (`go test` + testcontainers) — DB queries, Steam API client,
  full service flows with real Postgres in Docker
- **TS unit tests** (Vitest) — crypto/vault logic, component logic, pure functions
- **Browser E2E** (Playwright) — full user flows: login, search, trade, vault,
  multi-user trade scenarios
- **CI** (GitHub Actions) — Go lint + test, TS lint + test, buf lint, atlas migrate lint.
  Browser E2E tests NOT in CI initially (per requirements), added later.

**E2E test structure:**
```
frontend/tests/e2e/
├── playwright.config.ts
├── auth/
│   ├── steam-login.spec.ts      # Steam OAuth flow (mocked)
│   └── vault-setup.spec.ts      # Vault passphrase setup
├── trading/
│   ├── create-offer.spec.ts     # Create trade offer
│   ├── accept-trade.spec.ts     # Accept + auto-reveal (multi-context)
│   ├── counteroffer.spec.ts     # Counter flow
│   └── multi-user.spec.ts      # Two users trading simultaneously
├── keys/
│   ├── store-key.spec.ts        # Store encrypted key in vault
│   └── manage-keys.spec.ts      # View, search, filter keys
├── search/
│   └── game-search.spec.ts      # Search, filters, editions/DLC
└── fixtures/
    ├── test-users.ts            # Test user setup helpers
    └── mock-steam.ts            # Steam API mock helpers
```

### Monetization

**Core principles:**
- Free to users — no subscription fees, no transaction fees on trades
- Never gate core features behind payments
- Never sell user data (contradicts encryption/privacy stance)
- Monetization should feel like useful content, not intrusive advertising

**Phase 1 (launch) — target: cover hosting ($5-10/month):**
- **Affiliate links on game pages** — ITAD integration already displays deal/pricing
  data. Append affiliate codes to outbound store URLs. "Where to buy" section on
  game pages with links to Humble Bundle (~5-10%), Fanatical (~5-8%), Green Man
  Gaming (~5%), GOG (~5%). Note: Steam has NO affiliate program, but stores that
  sell Steam keys (Humble, Fanatical, GMG) do. ITAD API provides affiliate-ready
  links as part of their data — nearly free to implement.
- **GitHub Sponsors / Ko-fi** — "Help keep this site running" link in site footer
  and on the GitHub repo page. No fees on GitHub Sponsors (GitHub covers processing).
- Cost to implement: near zero. Intrusiveness: zero — affiliate links are genuinely
  useful content users want (cheapest place to buy a game).

**Phase 2 (growing, 1K+ MAU) — target: $50-200/month:**
- **EthicalAds or Carbon Ads** — single tasteful ad placement per page.
  Privacy-respecting (no tracking), developer/tech audience focused.
  EthicalAds is open-source friendly. ~$2-3 CPM.
- **Additional affiliate partnerships** — apply to more stores as traffic justifies.

### Code Philosophy
- Readability over cleverness, unless performance benefit is significant
- Solo developer, will be open-sourced on release
- Testability is the #1 concern
- Agentic-coding friendly (strong types, good LSP, AI tooling familiarity)

### Go Query Layer: sqlc + pgx
- **sqlc** — write SQL queries in `.sql` files, `sqlc generate` produces type-safe Go
  functions with proper structs for inputs/outputs. SQL is the source of truth.
- **pgx** as escape hatch for dynamic queries (e.g., trade matching with variable
  filters, admin search with optional parameters) where static SQL doesn't fit.
- **Workflow:**
  ```
  atlas (schema.sql)  →  migrations  →  database structure
  sqlc (query/*.sql)  →  db/*.go     →  type-safe query functions
  pgx (fallback)      →  manual      →  dynamic queries when needed
  ```
- **Directory structure:**
  ```
  backend/
  ├── internal/storage/
  │   ├── sqlc.yaml          # sqlc configuration
  │   ├── query/             # Hand-written SQL queries
  │   │   ├── games.sql      # Game CRUD + search
  │   │   ├── users.sql      # User CRUD
  │   │   ├── keys.sql       # Key storage queries
  │   │   ├── trades.sql     # Trade offer queries
  │   │   ├── wishlist.sql   # Wishlist queries
  │   │   └── enrichment.sql # Enrichment queue queries
  │   └── db/                # Generated Go code (sqlc output)
  │       ├── db.go          # DBTX interface
  │       ├── models.go      # Struct types from schema
  │       ├── games.sql.go   # Generated query functions
  │       └── ...
  ```
- **Rationale**: SQL-first approach matches "readability over cleverness" — the actual
  SQL is right there, no ORM abstraction to learn or debug. Complex queries for trade
  matching are written as SQL (the right tool) not ORM builder chains. Generated code
  is fully type-safe. Compile-time errors if schema changes break queries. sqlc supports
  PostgreSQL-specific features (`SELECT ... FOR UPDATE SKIP LOCKED`, array types, JSONB)
  natively. Great fit with Atlas — Atlas manages the schema, sqlc reads it.
- Generated `db/` code checked into Git (same policy as protobuf generated code).

### Go HTTP Router: Chi
- **Chi** (`go-chi/chi`) — lightweight router that extends `net/http` (not a replacement)
- Connect-go generates standard `http.Handler` — Chi mounts them directly via `r.Mount()`
- Connect's own docs and examples frequently use Chi as the de facto pairing
- Built-in middleware: `middleware.Logger`, `middleware.Recoverer`, `middleware.RealIP`,
  `cors.Handler`, `middleware.Compress`, `middleware.Timeout`
- Route groups for admin endpoints (dedup review queue, etc.)
- Chi IS `net/http` — no lock-in, handlers are standard, drop Chi anytime
- **Rationale**: Clean `r.Use()` middleware stacking is more readable than manual
  nesting. Built-in middleware saves writing boilerplate. Needed for admin routes,
  health checks, metrics, webhook endpoints beyond what Connect handles.

### Trade Matching Algorithm

**Core concept:** Set intersection across two dimensions. For users A and B to be a
good match: (A's available keys ∩ B's wishlist) AND (B's available keys ∩ A's wishlist)
must both be non-empty for a mutual match.

**Match quality tiers:**
- **Mutual match (best):** A has something B wants AND B has something A wants. Direct
  trade possible.
- **One-way match:** B has something A wants, but A has nothing B wants. Still shown —
  A can browse B's wishlist or make an open offer.
- **Chain match (future):** No direct trade, but a multi-party cycle solves it.
  A→B→C→A. Phase 3 feature.

**Data model:**
```
user_keys (keys available for trade):
  user_id, game_id (specific product), platform, available (bool),
  has_stored_key (bool), region, expires_at, created_at
  INDEX ON (game_id, available) WHERE available = true
  INDEX ON (user_id, available) WHERE available = true

user_wishlist (games the user wants):
  user_id, game_id (can be base game — matches any edition),
  platform (preferred or 'any'), priority, source ('steam_import'|'manual')
  INDEX ON (game_id, platform)
  INDEX ON (user_id)
```

**Two entry points for users:**
1. **Game-specific search** — User searches "Celeste", sees all users with Celeste
   keys ranked by match quality. Mutual matches highlighted at top ("wants Hades —
   you have this!").
2. **Trade dashboard** — Proactive discovery. Shows all best trade opportunities.
   "You and Bob can trade: you get Celeste, Bob gets Hades."

**Ranking formula:**
- Base: mutual match exists (+100), # games they have I want (+20 each),
  # games I have they want (+20 each)
- Quality bonuses: partner reputation (+0-30), fast response time (+0-10),
  key in vault / auto-reveal possible (+15), region compatible (+10),
  key not expiring soon (+5), high wishlist priority (+0-10)
- Penalties: region incompatible (-50), key expires within 7 days (-20),
  low reputation <70% positive (-30), account <7 days old (-10)

**Performance strategy:**
- Phase 1 (MVP): Live SQL query with proper indexes. Postgres handles 10-50K users
  with <500ms response time for game-specific search.
- Phase 2: Pre-computed `user_match_cache` table for the trade dashboard. Refreshed
  when users add/remove keys or wishlist items, plus hourly full recompute. Dashboard
  query becomes <5ms.

**Match notifications:**
- When a new key is posted matching someone's wishlist, or a new wishlist entry
  matches someone's keys, run a lightweight match check and notify.
- Delivered via Connect server stream (real-time), push notification, or email
  (based on user preferences).

**Phased rollout:**
- Phase 1 (MVP): Game-specific search with mutual match highlighting, live query,
  basic ranking (mutual > one-way), region filtering, reputation display.
- Phase 2: Trade dashboard with proactive match discovery, pre-computed match cache,
  full ranking formula, match notifications on new listings.
- Phase 3: Chain matching — find 2-4 party trade cycles via BFS/DFS on the directed
  graph of "user A has a key user B wants." Pre-compute chains nightly.
  "3-way trade available!" as a differentiating feature.

### Monitoring & Observability

**Stack:**
- **Prometheus** — metrics collection (request latency, worker health, trade volume,
  Steam API rate limit usage, DB connection pool). Runs on the VPS.
- **Grafana** — dashboards and alerting. Visualize Prometheus metrics and Loki logs.
  Runs on the VPS.
- **Loki** — log aggregation. Structured JSON logs from Go backend and SvelteKit
  frontend collected and searchable via Grafana. Runs on the VPS.
- **Sentry** — error tracking (free tier: 5K errors/month). Go SDK for backend,
  SvelteKit SDK for frontend. Stack traces, breadcrumbs, error grouping, alerts.
- **UptimeRobot** — external uptime monitoring (free tier: 50 monitors, 5-min
  intervals). Pings `/healthz` endpoint. Alerts via email/push. Optional public
  status page at status.bartering.games.
- Note: Prometheus + Grafana + Loki consume ~600MB RAM on the VPS. Hetzner CX22
  (4GB) has enough headroom (app uses ~1-1.5GB, monitoring ~600MB, ~2GB free).
  If RAM becomes tight, consider upgrading to CX32 (~$8.50/month) or moving
  monitoring to Grafana Cloud free tier.

**Structured logging:**
- Go's built-in `slog` (since Go 1.21) — JSON output to stdout
- Loki collects from Docker container stdout via Loki Docker driver or Promtail
- Log levels: ERROR (needs attention), WARN (handled but unexpected), INFO (business
  events — trades, syncs, auth), DEBUG (detailed flow, off in production)
- NEVER log: plaintext game keys, vault passphrases, sensitive user data

**Health check endpoints (Chi):**
- `GET /healthz` — is the server running?
- `GET /readyz` — is the server ready? (DB connected, workers healthy)
  Includes worker staleness check from heartbeat table.

**Background worker monitoring:**
- `worker_heartbeats` table: worker_name, last_run_at, last_status, last_error,
  items_processed, next_run_at. Workers update after each run.
- `/readyz` includes worker health — alerts if a worker hasn't reported in too long.

**Key metrics to track in Prometheus:**
- `http_request_duration_seconds` (by route, method, status)
- `background_worker_runs_total` (by worker name, success/fail)
- `steam_api_requests_total` (by endpoint, status)
- `trade_offers_total` (created, accepted, rejected, countered)
- `active_users_gauge`
- `db_connection_pool_size`
- `enrichment_queue_depth`

**Docker Compose addition for monitoring:**
```
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
  grafana:
    image: grafana/grafana
    volumes:
      - grafana_data:/var/lib/grafana
  loki:
    image: grafana/loki
    volumes:
      - loki_data:/loki
```

### Responsive UI Strategy: Adaptive Interactions
- **One responsive layout** with meaningful interaction differences per device:
  - **Mobile**: Touch-first. Swipe gestures for common actions (swipe to reject/counter
    trade offers). Bottom navigation. Large tap targets. Smooth transitions.
  - **Desktop**: Hover states, tooltips, keyboard shortcuts for power users. Sidebar
    navigation. Dense information layout. Right-click context menus where useful.
- SvelteKit handles this via responsive CSS + feature detection (touch vs pointer)
- NOT separate codepaths — same components adapt based on viewport and input type
- **Rationale**: Matches first-prompt requirement ("mobile should feel smooth and
  responsive, desktop should be geared towards mouse and keyboard") without the
  maintenance burden of separate layouts.

### Game Categories
- **Launch categories:**
  - **Owned** — synced from Steam library. Read-only mirror of what Steam reports.
  - **Wishlist** — imported from Steam wishlist + manually added on bartering.games.
    Two-way: Steam sync updates platform-side, user can add/remove locally.
  - **Keys Available** — games the user has keys for and is willing to trade. This is
    the core trading inventory.
  - **Ignored / Blacklisted** — games hidden from suggestions, trade offers, and match
    results. Useful for filtering out games the user will never want.
- Future categories (post-launch, based on user feedback): Completed, Currently Playing,
  Want to Trade (actively seeking), etc. Architecture supports arbitrary user-defined
  lists via a generic `user_game_lists` table.

### Notification System: Web Push + Email
- **Web Push** (browser-native via Web Push API + Service Worker):
  - Free, no third-party dependency for delivery
  - Real-time trade notifications, match alerts, counteroffer updates
  - Prompted during onboarding with clear explanation ("trade notifications only,
    not spammy"). Can enable/disable in user settings anytime.
- **Email** (via Resend — $0 for 3K emails/month, simple REST API):
  - Transactional emails: trade accepted, new match found, key expiring soon
  - Not marketing — only actionable notifications the user opted into
  - User provides email during onboarding (optional) or in settings later
- **User preference model**: Users choose per-channel (push, email, none) and can
  fine-tune by event type in settings. Default: push enabled, email disabled until
  address is provided.
- **Connect streaming** for in-app real-time updates (trade status changes, new
  matches) when the user has the site open — supplements push/email, not a replacement.

### CI/CD Code Quality
- **Go**: `golangci-lint` — runs 50+ linters (staticcheck, errcheck, govet, gosec,
  ineffassign, etc.) in a single pass. `.golangci.yml` config at `backend/`.
- **TypeScript**: `Biome` — replaces ESLint + Prettier in one tool. Formatting + linting.
  Fast (Rust-based). `biome.json` config at `frontend/`.
- **Proto**: `buf lint` — enforces protobuf style guide (naming, package structure).
- **CI pipeline** (GitHub Actions):
  ```
  on: [push, pull_request]
  jobs:
    go:     golangci-lint → go test → go test -tags=integration (testcontainers)
    ts:     biome check → vitest run
    proto:  buf lint → buf breaking (against main)
    db:     atlas migrate lint
  ```
- **Pre-commit hooks** (locally): Run `biome check`, `golangci-lint`, `buf lint` before
  commit. Enforced via a task: `task lint` runs all linters across the monorepo.
- Browser E2E tests (Playwright) NOT in CI initially per requirements — added later.

### PII Column-Level Encryption
- Steam profile data that qualifies as PII (email if exposed, real name, IP addresses)
  encrypted at rest in Postgres using server-side AES-256-GCM.
- Encryption key stored as environment variable, NOT in the database.
- Separate from the client-side vault (which protects game keys). This is server-side
  encryption for data the server needs to read (e.g., email for sending notifications).
- Columns: `users.email_encrypted`, `users.real_name_encrypted`, etc. with corresponding
  `_nonce` columns for GCM IVs.
- **Rationale**: Defense-in-depth. If database backup is leaked or DB access is
  compromised, PII is still protected. Aligns with first-prompt requirement: "if there
  is personal information this should be encrypted."

## User Flows

### Flow 1: Onboarding (New User)
```
┌─────────────────────────────────────────────────────────────┐
│                    ONBOARDING FLOW                          │
└─────────────────────────────────────────────────────────────┘

  Landing Page
       │
       ▼
  ┌──────────────┐
  │ "Sign in     │    Steam OpenID 2.0 redirect
  │  with Steam" │───────────────────────────────────┐
  └──────────────┘                                   │
                                                     ▼
                                              Steam auth page
                                                     │
                                                     ▼
                                              Redirect back
       ┌─────────────────────────────────────────────┘
       ▼
  ┌──────────────────────────────────────┐
  │ Step 1: Welcome + Region Selection   │
  │                                      │
  │  "What region are your Steam keys    │
  │   typically for?"                    │
  │                                      │
  │  [ ] Global        [ ] EU            │
  │  [ ] NA            [ ] Other...      │
  │                                      │
  │  (used to filter incompatible        │
  │   trades by default)                 │
  └──────────────────┬───────────────────┘
                     ▼
  ┌──────────────────────────────────────┐
  │ Step 2: Steam Library Import         │
  │                                      │
  │  "We're importing your Steam         │
  │   library..."                        │
  │                                      │
  │  ✓ 247 owned games imported          │
  │  ✓ 38 wishlist items imported        │
  │                                      │
  │  (background: workers begin sync)    │
  └──────────────────┬───────────────────┘
                     ▼
  ┌──────────────────────────────────────┐
  │ Step 3: Notifications                │
  │                                      │
  │  "Get notified when someone wants    │
  │   to trade with you"                 │
  │                                      │
  │  [Enable Push Notifications]         │
  │                                      │
  │  Email (optional):                   │
  │  [_________________________]         │
  │                                      │
  │  "We only send trade-related         │
  │   notifications. Manage anytime      │
  │   in Settings."                      │
  └──────────────────┬───────────────────┘
                     ▼
  ┌──────────────────────────────────────┐
  │ Step 4: Vault Setup (optional)       │
  │                                      │
  │  "Store game keys securely"          │
  │                                      │
  │  Explains: client-side encryption,   │
  │  we never see your keys, auto-reveal │
  │  on trade, irrecoverable if lost.    │
  │  Links to transparency page.         │
  │                                      │
  │  [Set up vault now]  [Skip for now]  │
  │                                      │
  │  If setup: choose passphrase         │
  │  (separate recommended, or use       │
  │   login password)                    │
  └──────────────────┬───────────────────┘
                     ▼
  ┌──────────────────────────────────────┐
  │ Step 5: Ready!                       │
  │                                      │
  │  "You're all set. Start browsing     │
  │   games to find trade partners."     │
  │                                      │
  │  [Browse Games]  [Add a Key]         │
  └──────────────────────────────────────┘
```

**Notes:**
- Steps are skippable (except Steam login and region). User can complete setup later.
- Region selection is critical for trade filtering — shown early.
- Steam library import happens in background; UI shows progress but doesn't block.
- Vault setup is optional — users can trade manually without it. Prompted here to
  front-load the security explanation.

### Flow 2: Saving a Game Key
```
┌─────────────────────────────────────────────────────────────┐
│                   KEY SAVING FLOW                           │
└─────────────────────────────────────────────────────────────┘

  Search bar (global, always accessible)
       │
       ▼
  Search results (base games, with editions/DLC expandable)
       │
       ▼
  Game page (e.g., "Elden Ring")
       │
       ├── Game info: description, images, genres, platforms
       ├── "Where to buy" (affiliate links — monetization)
       ├── Bundle history (from ITAD)
       ├── Trade partners available (match algorithm preview)
       │
       ▼
  ┌──────────────┐
  │ [Add a Key]  │
  └──────┬───────┘
         ▼
  ┌──────────────────────────────────────┐
  │ Step 1: Select Product               │
  │                                      │
  │  Which version?                      │
  │  ● Elden Ring (base game)            │
  │  ○ Elden Ring Deluxe Edition         │
  │  ○ Elden Ring GOTY Edition           │
  │  ○ Shadow of the Erdtree (DLC)       │
  │                                      │
  │  Platform:                           │
  │  ● Steam  ○ Epic  ○ GOG  ○ Other    │
  └──────────────────┬───────────────────┘
                     ▼
  ┌──────────────────────────────────────┐
  │ Step 2: Key Details                  │
  │                                      │
  │  Do you want to store the key?       │
  │  ● Yes, store securely in vault      │
  │  ○ No, I'll keep it elsewhere        │
  │    (just mark as "I own this key")   │
  │                                      │
  │  If storing:                         │
  │  Key: [XXXXX-XXXXX-XXXXX]           │
  │  (vault must be unlocked)            │
  │                                      │
  │  Source bundle (optional):           │
  │  [▼ Humble Choice Feb 2026      ]   │
  │  [▼ Fanatical Platinum Bundle   ]   │
  │  [▼ Not from a bundle           ]   │
  │                                      │
  │  (selecting bundle prefills below)   │
  │                                      │
  │  Region: [▼ Global             ]    │
  │  Expires: [▼ 2026-04-15        ]    │
  └──────────────────┬───────────────────┘
                     ▼
  ┌──────────────────────────────────────┐
  │ Step 3: Confirmation                 │
  │                                      │
  │  ✓ Elden Ring (Steam, Global)        │
  │  ✓ Key stored in vault               │
  │  ✓ Expires: Apr 15, 2026            │
  │  ✓ Available for trading             │
  │                                      │
  │  [Confirm]  [Edit]                   │
  └──────────────────────────────────────┘
```

**Notes:**
- Product selection (edition/DLC) is critical — users must clearly identify what
  their key is for. UI uses the parent-child game model.
- Bundle dropdown is populated from ITAD data. Selecting a bundle prefills region
  and expiration date where known.
- "I own this key" (no vault storage) still makes the user visible in trade matching
  — they just exchange keys manually via Steam chat.
- Vault must be unlocked to store a key. If not set up, prompt vault setup.

### Flow 3: Trade Lifecycle

**Trade offer state machine:**
```
┌─────────────────────────────────────────────────────────────┐
│                 TRADE STATE MACHINE                         │
└─────────────────────────────────────────────────────────────┘

                    Alice creates offer
                    (selects keys to offer & request)
                           │
                           ▼
                    ┌─────────────┐
           ┌───────│   PENDING   │───────┐
           │       └──────┬──────┘       │
           │              │              │
      Alice withdraws   Bob acts    Timer expires
           │              │              │
           ▼         ┌────┴────┐         ▼
      WITHDRAWN      │         │     EXPIRED
      (terminal)     │         │     (terminal)
                     ▼         ▼
               ┌──────┐  ┌────────┐  ┌──────────┐
               │ACCEPT│  │COUNTER │  │ REJECT   │
               └──┬───┘  └───┬────┘  └──────────┘
                  │          │        (terminal)
                  │          ▼
                  │    ┌─────────────┐
                  │    │   PENDING   │ (new round, same offer thread)
                  │    │  (countered)│
                  │    └──────┬──────┘
                  │           │
                  │    (same states: accept/counter/reject/
                  │     withdraw/expire — cycle continues
                  │     until terminal state)
                  │
                  ▼
           ┌─────────────┐
           │  ACCEPTED   │
           │             │
           │ Both keys   │──── Auto-reveal if both in vault
           │ in vault?   │──── Manual exchange modal if not
           └──────┬──────┘
                  │
                  ▼
           ┌─────────────┐
           │  FEEDBACK   │
           │             │
           │ Each party  │
           │ rates the   │
           │ other:      │
           │ +1 / -1     │
           │ + comment   │
           └──────┬──────┘
                  │
                  ▼
           ┌─────────────┐
           │  COMPLETED  │
           │  (terminal) │
           └─────────────┘
```

**States:**
- `PENDING` — waiting for counterparty to respond
- `ACCEPTED` — both parties agreed, keys being exchanged
- `COUNTERED` — creates a new PENDING round within the same offer thread
- `REJECTED` — counterparty declined (terminal)
- `WITHDRAWN` — sender canceled before response (terminal)
- `EXPIRED` — no response within the configured expiry period (terminal)
- `COMPLETED` — trade finished, feedback submitted (terminal)

**Expiry rules:**
- Default expiry: configurable by sender (e.g., 7 days, 14 days, 30 days)
- Expiry resets on each counter (new round, new timer)
- Approaching-expiry notification sent at ~24 hours remaining
- Expired offers can be "re-sent" (creates a new offer with same parameters)

**Escrow integration (from Encryption Architecture):**
- When Alice creates an offer AND has key in vault: browser creates escrow blob
  encrypted with Bob's public key. Attached to the offer.
- When Bob accepts AND has key in vault: browser creates escrow blob encrypted
  with Alice's public key. Trade marked ACCEPTED. Both decrypt.
- Counteroffers: previous escrow blobs are discarded. New blobs created for
  the new terms.
- If either party doesn't have key in vault: manual exchange modal with Steam
  profile link for direct communication.

**Data model:**
```
trade_offers table:
  id              BIGSERIAL PK
  thread_id       BIGINT          -- groups offer + counters into one thread
  round           INT             -- 1 = original, 2+ = counters
  sender_id       BIGINT FK → users
  receiver_id     BIGINT FK → users
  status          TEXT            -- pending, accepted, countered, rejected,
                                     withdrawn, expired, completed
  expires_at      TIMESTAMPTZ
  created_at      TIMESTAMPTZ
  resolved_at     TIMESTAMPTZ     -- when status became terminal

trade_offer_items table:
  id              BIGSERIAL PK
  offer_id        BIGINT FK → trade_offers
  direction       TEXT            -- 'offered' (sender gives) or 'requested' (sender wants)
  user_key_id     BIGINT FK → user_keys
  escrow_blob     BYTEA           -- RSA-encrypted key for counterparty (NULL if no vault)

trade_feedback table:
  id              BIGSERIAL PK
  offer_id        BIGINT FK → trade_offers (must be COMPLETED)
  reviewer_id     BIGINT FK → users
  reviewee_id     BIGINT FK → users
  rating          TEXT            -- 'positive' or 'negative'
  comment         TEXT
  created_at      TIMESTAMPTZ
  UNIQUE(offer_id, reviewer_id)   -- one review per user per trade
```

### Flow 4: User Profile
```
┌─────────────────────────────────────────────────────────────┐
│                    USER PROFILE PAGE                        │
└─────────────────────────────────────────────────────────────┘

  ┌───────────────────────────────────────────────────────┐
  │  [Steam Avatar]  Username                             │
  │  ★ 94% positive feedback (142 trades)                 │
  │  🔗 Steam Profile                                    │
  │  Member since: Jan 2026                               │
  │                                                       │
  │  Feedback breakdown:                                  │
  │  Past 7 days:   +12  -0   (100%)                     │
  │  Past 30 days:  +38  -2   (95%)                      │
  │  Past 1 year:   +134 -8   (94%)                      │
  └───────────────────────────────────────────────────────┘

  Tabs:
  ┌──────────┬──────────┬──────────┬──────────────────┐
  │ Keys (47)│Wishlist  │ Owned    │ Trade History    │
  │          │ (23)     │ (247)    │ (142)            │
  └──────────┴──────────┴──────────┴──────────────────┘

  Filters:
  [Platform ▼] [Region ▼] [Genre ▼] [Search...]

  Keys tab shows: games with available keys, platform, region,
  expiration status. Other users see this to initiate trades.

  Wishlist tab shows: games the user wants. Other users can
  check if they have matching keys.

  Trade History tab (own profile only): past trades with
  feedback given/received.
```

**Public vs private:**
- Public: username, avatar, feedback scores, keys available, wishlist, owned games
- Private (own profile only): trade history detail, vault contents, notification
  settings, email, stored key values
- Ignored/blacklisted games list is always private

### Internationalization (i18n)
- English-only at launch
- Plan for translations in the future — UI strings should be extractable, not hardcoded
- SvelteKit: use a library like `sveltekit-i18n` or `paraglide-js` (compile-time,
  tree-shakeable) — choose when we start building frontend
- Go backend: user-facing error messages and notification text should use message keys
  or templates, not hardcoded English strings
- Database content (game names, descriptions) stays in source language — no translation
- **Rationale**: Extracting strings later is painful. Wrapping them from day one is
  low effort if we pick the tooling early.

### Session Management: Server-Side Sessions with Hashed Tokens
- **Approach**: Server-side sessions stored in Postgres with hashed tokens in
  HttpOnly cookies. Industry best practice as of 2025-2026 — the "Lucia pattern."
- **Token lifecycle:**
  1. Generate 32 bytes from `crypto/rand` → base64url encode → `token`
  2. Hash: `SHA-256(token)` → `token_hash`
  3. Store: `INSERT INTO sessions (token_hash, user_id, ...)`
  4. Cookie: `Set-Cookie: session=token` (HttpOnly, Secure, SameSite=Lax)
- **On each request:** Read cookie → SHA-256(token) → look up `token_hash` in sessions table
- **Why hash?** If the database is compromised (backup leak, SQL injection), hashed
  tokens are useless — attacker can't reverse SHA-256 to forge cookies. Same principle
  as password hashing, but no salt needed since tokens are already high-entropy.
- **Schema:**
  ```sql
  sessions:
    token_hash  TEXT PK (SHA-256 of the session token)
    user_id     BIGINT FK → users NOT NULL
    ip_address  TEXT
    user_agent  TEXT
    created_at  TIMESTAMPTZ DEFAULT NOW()
    expires_at  TIMESTAMPTZ NOT NULL (30 days from creation)
    last_seen   TIMESTAMPTZ (updated periodically, not every request)
  ```
- **Session lifecycle:**
  - Created on Steam OpenID callback (after identity verified)
  - Rotated on privilege escalation (vault unlock triggers new session ID)
  - Absolute timeout: 30 days. Idle timeout: 7 days since last_seen.
  - Revoked instantly via DELETE (logout, password change, suspicious activity)
- **Performance:** pgx pool makes session lookup ~0.2ms. Optional in-memory LRU
  cache (5 min TTL) reduces to ~0 for repeat requests. At single-server scale with
  <50K users, DB lookup per request is negligible.
- **User-facing features enabled by session table:**
  - "Active sessions" page in settings (view all devices, revoke individually)
  - "Log out everywhere" button
  - Last login IP/timestamp on profile
- **Connect compatibility:** Connect over HTTP/1.1 with JSON sends cookies natively.
  Streaming connections carry the cookie on initial handshake.
- **Rationale**: JWTs were evaluated but rejected — they solve a distributed systems
  problem (stateless auth across multiple servers) that a single-server monolith
  doesn't have. JWT revocation requires a blocklist (effectively a session table),
  negating the stateless benefit. Server-side sessions are simpler, more secure
  (instant revocation), and enable user-facing session management features for free.

### Tooling Versions
- **Go**: 1.26 (latest stable as of March 2026)
- **Frontend package manager**: pnpm (strict dependency resolution, fast installs,
  popular in SvelteKit ecosystem)
- **Node**: LTS version current at time of scaffolding

## Not Yet Decided

### Search Implementation
- Game search is central to the UX — the search bar is the primary entry point for
  finding games, adding keys, and discovering trade partners.
- Options to investigate: Postgres full-text search (GIN indexes, `ts_vector`,
  `pg_trgm` for fuzzy), Meilisearch (typo-tolerant, fast, self-hosted), or
  Typesense (similar to Meilisearch).
- Considerations: search-as-you-type latency, fuzzy matching for game names (users
  misspell "Civilization" often), result ranking (games with active trades first?),
  and whether Postgres is "good enough" at our scale or if a dedicated engine is
  worth the operational overhead.

### Remaining Open Items
- Database backup strategy (automated Postgres backups, retention, restore process)
- API rate limiting (protecting our endpoints from abuse, especially search and
  trade creation)
- Detailed search UI design (filters, sorting, result layout)
- User settings page layout (notifications, vault, region, Steam sync controls)
- Admin panel design (dedup review queue, reported users, site stats)
- Mobile-specific navigation patterns (bottom nav items, gesture mapping)
- Additional search criteria for trade matching (first-prompt line 63 asks to
  collaborate on this)
- Other game categories beyond the launch set (based on user feedback post-launch)
- Exact Steam profile fields to store and which qualify as PII for column encryption

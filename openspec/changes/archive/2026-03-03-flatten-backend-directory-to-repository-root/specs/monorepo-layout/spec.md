## MODIFIED Requirements

### Requirement: Complete directory tree exists
The repository SHALL contain the following directory tree for the monorepo:
- cmd/server/
- internal/handler/
- internal/service/
- internal/port/
- internal/adapter/steam/
- internal/adapter/igdb/
- internal/adapter/itad/
- internal/adapter/manual/
- internal/components/
- internal/components/pages/
- internal/storage/query/
- internal/storage/db/
- internal/worker/
- internal/crypto/
- migrations/
- vault-js/src/
- .github/workflows/

#### Scenario: All directories are present after flattening
- **WHEN** the flatten-backend change is applied
- **THEN** every directory listed above SHALL exist at the repository root (no `backend/` prefix)
- **AND** the `backend/` directory SHALL NOT exist

## REMOVED Requirements

### Requirement: Empty directories are preserved in Git
**Reason**: All leaf directories now contain real source files; `.gitkeep` files were removed as real content was added per the project convention.
**Migration**: No action needed — directories are preserved by their contents.

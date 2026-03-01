## ADDED Requirements

### Requirement: Complete directory tree exists
The repository SHALL contain the following directory tree for the monorepo:

```
bartering-games/
├── proto/bartering/v1/
├── backend/cmd/server/
├── backend/internal/handler/
├── backend/internal/service/
├── backend/internal/port/
├── backend/internal/adapter/steam/
├── backend/internal/adapter/igdb/
├── backend/internal/adapter/itad/
├── backend/internal/adapter/manual/
├── backend/internal/storage/query/
├── backend/internal/storage/db/
├── backend/internal/worker/
├── backend/internal/crypto/
├── backend/gen/
├── backend/migrations/
├── frontend/src/lib/api/
├── frontend/src/lib/vault/
├── frontend/src/lib/components/
├── frontend/gen/
├── frontend/tests/e2e/
└── .github/workflows/
```

#### Scenario: All directories are present after setup
- **WHEN** the init-monorepo-structure change is applied
- **THEN** every directory listed above SHALL exist in the repository

### Requirement: Empty directories are preserved in Git
Every leaf directory that contains no source files SHALL contain a `.gitkeep` file so that Git tracks the directory.

#### Scenario: .gitkeep files exist in empty leaf directories
- **WHEN** the directory tree is created
- **THEN** each leaf directory SHALL contain a `.gitkeep` file

#### Scenario: .gitkeep is the only file in placeholder directories
- **WHEN** a directory has no other files
- **THEN** it SHALL contain exactly one `.gitkeep` file (empty, zero bytes)

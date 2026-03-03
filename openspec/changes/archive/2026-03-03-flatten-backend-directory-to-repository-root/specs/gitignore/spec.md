## MODIFIED Requirements

### Requirement: Root .gitignore covers Go artifacts
The `.gitignore` at the repository root SHALL ignore Go build and test artifacts.

#### Scenario: Go binaries and build output are ignored
- **WHEN** a Go binary is built via `go build -o bin/server ./cmd/server/`
- **THEN** the `bin/` directory at the repo root SHALL be excluded from Git tracking
- **AND** the `vendor/` directory SHALL be ignored (Go vendoring; this also means `cmd/server/static/vendor/` would be ignored, which is why it was renamed to `lib/`)

---
paths:
  - "backend/**/*"
---

# Backend Standards

## Code Style

- Go code follows standard Go conventions (gofmt, effective Go)
- Go uses golangci-lint

## sqlc Query Conventions

- Use named parameters (`@param_name`) instead of positional (`$1`, `$2`) in query files
- Run `go mod tidy` after `sqlc generate` if new imports are introduced — sqlc-generated
  code can promote indirect deps to direct

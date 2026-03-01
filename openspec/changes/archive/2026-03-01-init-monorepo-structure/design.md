## Context

The bartering-games repo currently contains only config files and a README. The planned monorepo directory structure needs to be materialized so that subsequent scaffolding stories (Go module init, SvelteKit init, protobuf setup, CI config) have well-known paths to target.

## Goals / Non-Goals

**Goals:**
- Create every directory in the planned monorepo structure
- Preserve empty directories in Git via `.gitkeep` files
- Provide a `.gitignore` that covers Go, Node/TypeScript, IDE, OS, and Docker artifacts

**Non-Goals:**
- Initializing `go.mod`, `package.json`, or any dependency manifests
- Adding real source files, config files (Taskfile, docker-compose, Dockerfile), or CI workflows
- Setting up codegen tooling (buf, sqlc)

## Decisions

### 1. Use `.gitkeep` for empty directories

**Decision**: Place a `.gitkeep` file in every leaf directory that would otherwise be empty.

**Rationale**: Git doesn't track empty directories. `.gitkeep` is the widely-understood convention (over `.keep` or empty `.gitignore`). Once real files land in a directory, the `.gitkeep` can be removed — but that cleanup is each story's responsibility, not this one's.

### 2. Single root `.gitignore` (not per-directory)

**Decision**: One `.gitignore` at the repo root covering all languages and tools.

**Alternatives considered**:
- Per-directory `.gitignore` (e.g., `backend/.gitignore`, `frontend/.gitignore`) — adds flexibility but unnecessary complexity for a monorepo where the tech stack is fixed. Easier to maintain one file.

**Rationale**: A single file is simpler to audit and update. Language-specific sections are clearly labeled with comments.

### 3. Directory tree matches the monorepo-layout spec exactly

**Decision**: The directory tree SHALL match the structure defined in the `monorepo-layout` spec with no additions or omissions.

**Rationale**: The spec is the canonical reference for this change. Future structure changes should go through a new change proposal.

## Risks / Trade-offs

- **[Premature structure]** Creating directories for features not yet built (e.g., `adapter/itad/`, `worker/`) may suggest completeness that doesn't exist. → Acceptable: `.gitkeep` files make it clear these are placeholders, and the structure was already decided in project planning.
- **[`.gitignore` gaps]** The initial `.gitignore` may miss edge cases for specific tools added later. → Low risk: it's easy to append rules as new tooling is introduced.

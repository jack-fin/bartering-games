## Why

The project has no directory structure yet — just config files. Before any feature work can begin, we need the monorepo skeleton in place so that codegen, linting, testing, and CI can all target well-known paths. Setting this up first avoids path churn and merge conflicts as multiple workstreams start in parallel.

## What Changes

- Create the full directory tree for `proto/`, `backend/`, `frontend/`, and `.github/workflows/`
- Add `.gitkeep` files to preserve empty directories in Git
- Create a comprehensive `.gitignore` covering Go, Node.js/SvelteKit, IDE files, OS files, and Docker artifacts

## Capabilities

### New Capabilities
- `monorepo-layout`: Directory structure and `.gitkeep` placement for the bartering-games monorepo
- `gitignore`: `.gitignore` rules for Go, Node/TypeScript, IDE, OS, and Docker artifacts

### Modified Capabilities
_(none — greenfield project)_

## Impact

- **Code**: All future code depends on these paths existing. No runtime code is introduced.
- **CI/CD**: `.github/workflows/` directory created but empty — CI setup is a separate story.
- **Dependencies**: None added. No `go.mod`, `package.json`, or lockfiles — those belong to their own scaffolding stories.

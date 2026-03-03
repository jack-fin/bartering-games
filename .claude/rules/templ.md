---
paths:
  - "backend/internal/components/**/*"
---

# Templ Component Standards

## Accessibility

These concerns are first-class requirements in every templ component, not follow-up tasks:

- **Semantic HTML**: Use `<button>`, `<nav>`, `<dialog>`, `<main>`, etc. — not `<div>` with click handlers
- **Logical heading hierarchy**: h1 → h2 → h3 (never skip levels)
- **ARIA**: Only when semantic HTML is insufficient. All interactive elements keyboard-reachable
- **Contrast**: WCAG 2.1 AA (4.5:1 normal text, 3:1 large text)
- **Focus indicators**: Visible focus styles on all interactive elements

## Theming

- Use CSS custom properties (`var(--color-bg)`, `var(--space-md)`) — never hardcode colors or spacing
- Light and dark mode via `prefers-color-scheme` in `styles.css`

## Component Patterns

- **Layout**: Use `{ children... }` for page content slots
- **Pages**: Import and use `@components.Layout("Title") { ... }` for consistent structure
- **Generated files**: `_templ.go` files are generated — never edit manually. Run `templ generate` after editing `.templ` files.

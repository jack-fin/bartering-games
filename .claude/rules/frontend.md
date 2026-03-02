---
paths:
  - "frontend/**/*"
---

# Frontend Standards

These three concerns are first-class requirements in every UI component, not follow-up tasks:

- **Accessibility (a11y)**: Semantic HTML (`<button>`, `<nav>`, `<dialog>`, not `<div>` with
  click handlers). Logical heading hierarchy. ARIA only when semantic HTML is insufficient.
  All interactive elements keyboard-reachable and operable. Visible focus indicators.
  WCAG 2.1 AA contrast (4.5:1 normal text, 3:1 large text). Never convey info through
  color alone. `aria-live` for dynamic content (trade updates, sync progress).
- **Internationalization (i18n)**: English-only at launch, but all user-facing strings must
  go through the i18n function — no hardcoded text. Date/number formatting via `Intl` APIs.
  Backend returns error codes, frontend maps to localized messages.
- **Responsive UI**: Single adaptive layout (not separate mobile/desktop). CSS custom
  properties for theming (light/dark via `prefers-color-scheme`). Interactions adapt by
  input method (`pointer: coarse` vs `fine`), not screen size. Touch targets min 44px.

## Code Style

- TypeScript uses ESLint + Prettier for linting + formatting

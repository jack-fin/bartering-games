import { test as base, type Page } from "@playwright/test";

/**
 * Extended test fixtures for bartering.games E2E tests.
 *
 * Usage:
 *   import { test, expect } from "./fixtures";
 *   test("logged-in user sees dashboard", async ({ authenticatedPage }) => { ... });
 */

type Fixtures = {
  /** A page with an authenticated session (logged-in user). */
  authenticatedPage: Page;
};

export const test = base.extend<Fixtures>({
  authenticatedPage: async ({ browser }, use) => {
    const context = await browser.newContext();
    const page = await context.newPage();

    // TODO: Implement real login flow once Steam OAuth is wired up.
    // For now, navigate to /login as a placeholder to prove the fixture works.
    await page.goto("/login");

    await use(page);
    await context.close();
  },
});

export { expect } from "@playwright/test";

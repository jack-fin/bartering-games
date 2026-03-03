import { defineConfig, devices } from "@playwright/test";

const port = Number(process.env.E2E_PORT ?? 3100);
const serverCommand = process.env.CI
  ? `PORT=${port} ./bin/server`
  : `PORT=${port} go run ./cmd/server/`;

export default defineConfig({
  testDir: "e2e",
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: "html",

  use: {
    baseURL: `http://localhost:${port}`,
    screenshot: "only-on-failure",
    trace: "on-first-retry",
  },

  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],

  webServer: {
    command: serverCommand,
    url: `http://localhost:${port}/healthz`,
    reuseExistingServer: !process.env.CI,
    timeout: 30_000,
  },
});

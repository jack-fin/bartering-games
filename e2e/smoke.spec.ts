import { test, expect } from "@playwright/test";

test.describe("smoke", () => {
  test("homepage loads with expected content", async ({ page }) => {
    const response = await page.goto("/");
    expect(response?.status()).toBe(200);

    await expect(page.locator("h1")).toHaveText("bartering.games");
    await expect(
      page.getByText("Steam key bartering platform"),
    ).toBeVisible();
  });

  test("health endpoint returns ok", async ({ request }) => {
    const response = await request.get("/healthz");
    expect(response.status()).toBe(200);
    expect(await response.text()).toBe("ok");
  });

  test("TEMP: deliberately failing test to verify CI artifact upload", async ({
    page,
  }) => {
    await page.goto("/");
    await expect(page.locator("h1")).toHaveText("this will never match");
  });
});

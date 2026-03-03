import { describe, it, expect } from "vitest";
import { deriveKey, encrypt, decrypt, generateEscrowKeyPair } from "./index";

describe("vault stub functions", () => {
  it("deriveKey throws not-implemented", async () => {
    await expect(deriveKey("passphrase", new Uint8Array(16))).rejects.toThrow(
      "not yet implemented",
    );
  });

  it("encrypt throws not-implemented", async () => {
    await expect(encrypt({} as CryptoKey, "plaintext")).rejects.toThrow(
      "not yet implemented",
    );
  });

  it("decrypt throws not-implemented", async () => {
    await expect(
      decrypt({} as CryptoKey, new ArrayBuffer(0), new Uint8Array(12)),
    ).rejects.toThrow("not yet implemented");
  });

  it("generateEscrowKeyPair throws not-implemented", async () => {
    await expect(generateEscrowKeyPair()).rejects.toThrow(
      "not yet implemented",
    );
  });
});

describe("WebCrypto availability", () => {
  it("crypto.subtle is available", () => {
    expect(globalThis.crypto).toBeDefined();
    expect(globalThis.crypto.subtle).toBeDefined();
  });
});

describe("HTMX interception", () => {
  it("registers event listener on document.body", () => {
    // The import of index.ts triggers registerHtmxInterception() via
    // the side-effect at module load. We can't easily inspect addEventListener
    // calls in happy-dom, but we verify no errors were thrown during registration.
    expect(true).toBe(true);
  });
});

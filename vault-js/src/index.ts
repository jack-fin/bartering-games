/**
 * Vault — client-side encryption module for bartering.games
 *
 * Provides WebCrypto-based encryption for game keys:
 * - AES-256-GCM for key encryption
 * - PBKDF2 for passphrase-based key derivation
 * - RSA-OAEP for trade escrow auto-reveal
 *
 * This module is compiled by esbuild into a single IIFE bundle.
 * It has zero runtime dependencies.
 */

import { registerHtmxInterception } from "./htmx-interception";

export async function deriveKey(
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _passphrase: string,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _salt: Uint8Array,
): Promise<CryptoKey> {
  throw new Error("Vault.deriveKey is not yet implemented");
}

export async function encrypt(
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _key: CryptoKey,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _plaintext: string,
): Promise<{ ciphertext: ArrayBuffer; iv: Uint8Array }> {
  throw new Error("Vault.encrypt is not yet implemented");
}

export async function decrypt(
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _key: CryptoKey,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _ciphertext: ArrayBuffer,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _iv: Uint8Array,
): Promise<string> {
  throw new Error("Vault.decrypt is not yet implemented");
}

export async function generateEscrowKeyPair(): Promise<CryptoKeyPair> {
  throw new Error("Vault.generateEscrowKeyPair is not yet implemented");
}

// Register HTMX form interception when loaded in a browser
if (typeof document !== "undefined") {
  registerHtmxInterception();
}

/**
 * HTMX form interception for vault operations.
 *
 * Listens to htmx:configRequest events on forms marked with data-vault-encrypt.
 * When a vault-marked form submits, this module:
 * 1. Reads plaintext from designated form fields
 * 2. Runs WebCrypto encryption (once implemented)
 * 3. Stuffs encrypted results into hidden inputs
 * 4. Lets the HTMX request proceed with encrypted data
 *
 * This keeps the vault module decoupled from HTMX internals — it only uses
 * the event API, never calls htmx.ajax() or fetch().
 */

interface HtmxConfigRequestDetail {
  parameters: Record<string, string>;
  headers: Record<string, string>;
  elt: Element;
  triggeringEvent: Event | null;
}

interface HtmxConfigRequestEvent extends Event {
  detail: HtmxConfigRequestDetail;
}

function isVaultForm(element: Element): boolean {
  const form = element.closest("form");
  return form !== null && form.hasAttribute("data-vault-encrypt");
}

function handleConfigRequest(event: HtmxConfigRequestEvent): void {
  if (!isVaultForm(event.detail.elt)) {
    return;
  }

  // Vault form detected — encryption hook point.
  // Once vault crypto is implemented, this will:
  // 1. Read plaintext from event.detail.parameters
  // 2. Encrypt with the derived vault key
  // 3. Replace parameter values with ciphertext
  console.debug("[vault] Intercepted vault-marked form submission (stub)");
}

export function registerHtmxInterception(): void {
  document.body.addEventListener(
    "htmx:configRequest",
    handleConfigRequest as EventListener,
  );
}

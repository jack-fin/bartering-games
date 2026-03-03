"use strict";
var Vault = (() => {
  var __defProp = Object.defineProperty;
  var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
  var __getOwnPropNames = Object.getOwnPropertyNames;
  var __hasOwnProp = Object.prototype.hasOwnProperty;
  var __export = (target, all) => {
    for (var name in all)
      __defProp(target, name, { get: all[name], enumerable: true });
  };
  var __copyProps = (to, from, except, desc) => {
    if (from && typeof from === "object" || typeof from === "function") {
      for (let key of __getOwnPropNames(from))
        if (!__hasOwnProp.call(to, key) && key !== except)
          __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
    }
    return to;
  };
  var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

  // src/index.ts
  var index_exports = {};
  __export(index_exports, {
    decrypt: () => decrypt,
    deriveKey: () => deriveKey,
    encrypt: () => encrypt,
    generateEscrowKeyPair: () => generateEscrowKeyPair
  });

  // src/htmx-interception.ts
  function isVaultForm(element) {
    const form = element.closest("form");
    return form !== null && form.hasAttribute("data-vault-encrypt");
  }
  function handleConfigRequest(event) {
    if (!isVaultForm(event.detail.elt)) {
      return;
    }
    console.debug("[vault] Intercepted vault-marked form submission (stub)");
  }
  function registerHtmxInterception() {
    document.body.addEventListener(
      "htmx:configRequest",
      handleConfigRequest
    );
  }

  // src/index.ts
  async function deriveKey(_passphrase, _salt) {
    throw new Error("Vault.deriveKey is not yet implemented");
  }
  async function encrypt(_key, _plaintext) {
    throw new Error("Vault.encrypt is not yet implemented");
  }
  async function decrypt(_key, _ciphertext, _iv) {
    throw new Error("Vault.decrypt is not yet implemented");
  }
  async function generateEscrowKeyPair() {
    throw new Error("Vault.generateEscrowKeyPair is not yet implemented");
  }
  if (typeof document !== "undefined") {
    registerHtmxInterception();
  }
  return __toCommonJS(index_exports);
})();

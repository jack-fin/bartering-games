import { createConnectTransport } from "@connectrpc/connect-web";
import { env } from "$env/dynamic/public";

export const transport = createConnectTransport({
	baseUrl: env.PUBLIC_API_URL ?? "http://localhost:8080",
});

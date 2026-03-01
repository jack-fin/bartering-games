import adapter from "@sveltejs/adapter-node";

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		adapter: adapter(),
		alias: {
			$gen: "./gen",
			"$gen/*": "./gen/*",
		},
	},
};

export default config;

<script lang="ts">
	import "../app.css";
	import { resolve } from "$app/paths";
	import favicon from "$lib/assets/favicon.svg";

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
</svelte:head>

<div class="app">
	<header>
		<nav aria-label="Main navigation">
			<a href={resolve("/")}>bartering.games</a>
		</nav>
	</header>

	<main>
		{@render children()}
	</main>

	<footer>
		<p>&copy; {new Date().getFullYear()} bartering.games</p>
	</footer>
</div>

<style>
	.app {
		display: flex;
		flex-direction: column;
		min-height: 100vh;
	}

	header {
		padding: var(--space-md) var(--space-xl);
		border-bottom: 1px solid var(--color-border);
	}

	nav a {
		font-weight: 700;
		color: var(--color-text);
	}

	main {
		flex: 1;
		padding: var(--space-xl);
		width: 100%;
		max-width: var(--max-width);
		margin: 0 auto;
	}

	footer {
		padding: var(--space-md) var(--space-xl);
		border-top: 1px solid var(--color-border);
		color: var(--color-text-secondary);
		font-size: 0.875rem;
		text-align: center;
	}
</style>

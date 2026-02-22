#!/usr/bin/env bash
# this is in its own file because javascript likes to become outdated fast
# instead, a generator is used

set -e
define(){ IFS=$'\n' read -r -d '' ${1} || true; }

define patch <<'EOF'
diff -ruN client-original/package.json client/package.json
--- client-original/package.json	2026-02-22 10:34:30.629006638 -0500
+++ client/package.json	2026-02-22 10:34:30.630945119 -0500
@@ -1,5 +1,5 @@
 {
-	"name": "client",
+	"name": "rename-me",
 	"private": true,
 	"version": "0.0.1",
 	"type": "module",
diff -ruN client-original/svelte.config.js client/svelte.config.js
--- client-original/svelte.config.js	2026-02-22 10:34:30.629006638 -0500
+++ client/svelte.config.js	2026-02-22 10:34:30.631155568 -0500
@@ -1,6 +1,6 @@
 import adapter from '@sveltejs/adapter-static';

 /** @type {import('@sveltejs/kit').Config} */
-const config = { kit: { adapter: adapter() } };
+const config = { kit: { adapter: adapter({ fallback: '200.html' }) } };

 export default config;
diff -ruN client-original/vite.config.ts client/vite.config.ts
--- client-original/vite.config.ts	2026-02-22 10:34:30.629006638 -0500
+++ client/vite.config.ts	2026-02-22 10:36:42.246213575 -0500
@@ -5,6 +5,11 @@

 export default defineConfig({
 	plugins: [tailwindcss(), sveltekit()],
+	server: {
+		proxy: {
+			'/api': 'http://localhost:8080'
+		}
+	},
 	test: {
 		expect: { requireAssertions: true },
 		projects: [
@@ -15,7 +20,7 @@
 					browser: {
 						enabled: true,
 						provider: playwright(),
-						instances: [{ browser: 'chromium', headless: true }]
+						instances: [{ browser: 'firefox', headless: true }]
 					},
 					include: ['src/**/*.svelte.{test,spec}.{js,ts}'],
 					exclude: ['src/lib/server/**']

EOF

if [ $# -eq 0 ]; then
    echo "$0 init-client|create-patch-folder|get-patch|uninit"
    exit 1
fi

if [[ "$1" == "init-client" ]]; then
    npx sv create --template minimal --types ts --add prettier eslint tailwindcss="plugins:none" sveltekit-adapter="adapter:static" vitest="usages:unit,component" --install npm client
    cp client/.gitignore client/.dockerignore
    patch --directory=client/ --strip=1 --ignore-whitespace <<< "$patch"
elif [[ "$1" == "create-patch-folder" ]]; then
    npx sv create --template minimal --types ts --add prettier eslint tailwindcss="plugins:none" sveltekit-adapter="adapter:static" vitest="usages:unit,component" --no-install client
    cp client/.gitignore client/.dockerignore
    cp -R client client-original
    patch --directory=client/ --strip=1 --ignore-whitespace <<< "$patch"
elif [[ "$1" == "get-patch" ]]; then
    diff -ruN client-original/ client/
elif [[ "$1" == "uninit" ]]; then
    rm -rf client/ client-original/
fi

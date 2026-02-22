#!/usr/bin/env bash
# this is in its own file because javascript likes to become outdated fast
# instead, a generator is used

set -e
define(){ IFS=$'\n' read -r -d '' ${1} || true; }

define patch <<'EOF'
diff -ruN client-original/svelte.config.js client/svelte.config.js
--- client-original/svelte.config.js	2026-02-22 09:59:52.744416885 -0500
+++ client/svelte.config.js	2026-02-22 09:59:52.746984245 -0500
@@ -1,6 +1,6 @@
 import adapter from '@sveltejs/adapter-static';

 /** @type {import('@sveltejs/kit').Config} */
-const config = { kit: { adapter: adapter() } };
+const config = { kit: { adapter: adapter({ fallback: '200.html' }) } };

 export default config;
diff -ruN client-original/vite.config.ts client/vite.config.ts
--- client-original/vite.config.ts	2026-02-22 09:59:52.744877626 -0500
+++ client/vite.config.ts	2026-02-22 10:02:05.304107455 -0500
@@ -15,7 +15,7 @@
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

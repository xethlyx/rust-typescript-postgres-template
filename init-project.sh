#!/usr/bin/env bash
# this is in its own file because javascript likes to become outdated fast
# instead, a generator is used

set -e
define(){ IFS=$'\n' read -r -d '' ${1} || true; }

define patch <<'EOF'
diff -ruN client-original/svelte.config.js client/svelte.config.js
--- client-original/svelte.config.js    2026-02-21 16:04:04.702379902 -0500
+++ client/svelte.config.js     2026-02-21 16:04:04.704257934 -0500
@@ -1,6 +1,6 @@
 import adapter from '@sveltejs/adapter-static';

 /** @type {import('@sveltejs/kit').Config} */
-const config = { kit: { adapter: adapter() } };
+const config = { kit: { adapter: adapter({ fallback: '200.html' }) } };

 export default config;
EOF

if [ $# -eq 0 ]; then
    echo "$0 init-client|create-patch-folder|get-patch|uninit"
    exit 1
fi

if [[ "$1" == "init-client" ]]; then
    npx sv create --template minimal --types ts --add prettier eslint tailwindcss="plugins:none" sveltekit-adapter="adapter:static" vitest="usages:unit,component" --install npm client
    cp client/.gitignore client/.dockerignore
    patch --directory=client/ --strip=1 <<< "$patch"
elif [[ "$1" == "create-patch-folder" ]]; then
    npx sv create --template minimal --types ts --add prettier eslint tailwindcss="plugins:none" sveltekit-adapter="adapter:static" vitest="usages:unit,component" --no-install client
    cp client/.gitignore client/.dockerignore
    cp -R client client-original
    patch --directory=client/ --strip=1 <<< "$patch"
elif [[ "$1" == "get-patch" ]]; then
    diff -ruN client-original/ client/
elif [[ "$1" == "uninit" ]]; then
    rm -rf client/ client-original/
fi

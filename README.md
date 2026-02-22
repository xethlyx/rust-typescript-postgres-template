# TypeScript (Sveltekit), Rust (Axum) and Postgres template

This is my own minimal boilerplate for TypeScript and Rust web project that uses Postgres. This is intended for development on Linux systems only, though it may work in any other environment with Bash installed. To get started:
 - clone this repo and remove `.git` (or run `npx degit <repo url>`)
 - replace all instances of "rename-me" with your project name
 - run `./init-project.js init-client`
 - remove `init-project.sh` script and any `README.md` files

There are a couple convenience scripts located at the root of this directory if you have podman installed.
 - `postgres.sh`: start a local postgres server on port 5432 and expose the app (if started in podman) on port 8081 (you are responsible for a properly configured firewall)
 - `run-local.sh`: build and run a local server with podman

For environment variables, create `server/.env.sh` and `source .env.sh` before `cargo run`, or install a dotfiles crate

All the source code in this repository is licensed under MIT:

```
Copyright 2026 xethlyx

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
#!/usr/bin/env bash
set -e
podman build --label "autoremove=true" -t rename-me .
podman image prune --filter "label=autoremove=true" --force
podman run --rm -it --network="container:postgres-dev" -e POSTGRES_URL=postgres://postgres:postgres@localhost:5432 -e BIND_ADDR=[::]:8081 "$@" rename-me

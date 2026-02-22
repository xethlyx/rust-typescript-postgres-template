#!/usr/bin/env bash
podman run \
    --rm \
    --name postgres-dev \
    -e POSTGRES_PASSWORD=postgres \
    -p 5432:5432 \
    -p 8081:8081 \
    docker.io/postgres:18-alpine

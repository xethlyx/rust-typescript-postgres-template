FROM node:24-trixie-slim as client-builder
WORKDIR /app/client

COPY client/package*.json ./
RUN npm ci

COPY client/ .
RUN npm run build

FROM rust:1.93-trixie AS server-builder

WORKDIR /app

COPY ./server/Cargo.lock ./server/Cargo.toml ./
RUN echo "fn main() {}" > dummy.rs \
    && sed -i 's#src/main.rs#dummy.rs#' Cargo.toml \
    && cargo build --release \
    && sed -i 's#dummy.rs#src/main.rs#' Cargo.toml

COPY server/ .
RUN cargo build --release

FROM gcr.io/distroless/cc-debian13 AS runtime
WORKDIR /app
COPY --from=server-builder /app/target/release/rename-me /app
COPY --from=client-builder /app/client/build /app/client
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/app/rename-me"]
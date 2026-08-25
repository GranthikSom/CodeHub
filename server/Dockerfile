# Multi-stage Dockerfile for CodeHub Rust Axum API Server & Embedded P2P Storage Peer

FROM rust:1.80 as builder
WORKDIR /usr/src/codehub

# Copy workspace manifests and code
COPY . .

# Build release binary
RUN cargo build --release -p codehub_server

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates libssl-dev && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=builder /usr/src/codehub/target/release/codehub_server /app/codehub_server

EXPOSE 8080 4001
ENV HOST=0.0.0.0
ENV PORT=8080

CMD ["/app/codehub_server"]

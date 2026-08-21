# Build Stage
FROM rust:1.75-slim as builder
WORKDIR /usr/src/codehub_control_plane
COPY . .
RUN cargo build --release

# Runtime Stage
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates libssl-dev && rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/src/codehub_control_plane/target/release/codehub_control_plane /usr/local/bin/
EXPOSE 8080
CMD ["codehub_control_plane"]

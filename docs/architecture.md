# CodeHub Monorepo Architecture Specification

## Overview

CodeHub is structured as a single monorepo repository divided into distinct packages:

```
codehub/
├── apps/flutter_app/      # Flutter Desktop/Mobile UI Application & Dart FFI bridge
├── native/p2p_engine/     # Rust p2p_engine shared library (rust-libp2p, SHA-256 Git blockstore)
├── server/                # Modular Rust Axum Central Control Plane API server
├── protocols/             # Shared Protobuf protocol specifications
├── infrastructure/        # Docker Compose, Caddy reverse proxy & Prometheus monitoring
├── docs/                  # Architecture & operational guides
└── scripts/               # Build & development scripts
```

## Hybrid Data & Control Split

- **Data Plane (Decentralized)**: Handled by `native/p2p_engine/` over `rust-libp2p`. Stores immutable Git commit DAGs, blob blocks, and tree objects.
- **Control Plane (Centralized)**: Handled by `server/` over Axum & PostgreSQL. Manages user authentication (JWT), repository permissions, issue tracking, pull requests, and bootstrap peer discovery.

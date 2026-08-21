# CodeHub — Decentralized P2P Git Platform (Monorepo)

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.12-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Rust-2021-000000?logo=rust&logoColor=white" alt="Rust" />
  <img src="https://img.shields.io/badge/p2p-rust--libp2p-3FB950?logo=p2p&logoColor=white" alt="libp2p" />
  <img src="https://img.shields.io/badge/Backend-Axum-58A6FF?logo=rust&logoColor=white" alt="Axum" />
  <img src="https://img.shields.io/badge/Database-PostgreSQL%2016-336791?logo=postgresql&logoColor=white" alt="PostgreSQL" />
  <img src="https://img.shields.io/badge/Cache-Redis%207-DC382D?logo=redis&logoColor=white" alt="Redis" />
  <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License" />
</p>

---

## 📌 Executive Summary

**CodeHub** is an enterprise-grade, decentralized code-hosting platform structured as a clean, unified **Monorepo**. By coupling a **Flutter** client interface with a native **Rust (`rust-libp2p`)** engine, CodeHub enables content-addressed Git repository object replication across a peer-to-peer swarm while retaining centralized authentication, metadata indexing, and social collaboration features via a **Rust Axum** backend API.

---

## 📂 Monorepo Structure

```
codehub/
│
├── apps/                         # Frontend Client Applications
│   └── flutter_app/              # Flutter Desktop & Mobile Client (Dart FFI bridge)
│
├── native/                       # Native Core Engines
│   └── p2p_engine/               # Rust P2P Storage Engine (rust-libp2p & SHA-256 blockstore)
│
├── server/                       # Modular Central Control Plane API Server (Rust Axum)
│   ├── src/
│   │   ├── main.rs               # Axum server router
│   │   ├── api/                  # API response standards
│   │   ├── auth/                 # JWT token generation
│   │   ├── repository/           # Repository & issue metadata index
│   │   ├── search/               # Search index query engine
│   │   └── discovery/            # Bootstrap peer discovery service
│   └── migrations/               # PostgreSQL schema 0001_init.sql
│
├── protocols/                    # Shared Protocol Buffers Specification
│   ├── repository.proto          # Repo metadata & DAG object sync
│   ├── peer.proto                # Node identity & telemetry
│   └── sync.proto                # Gossipsub replication protocol
│
├── infrastructure/               # DevOps & Deployment Assets
│   ├── docker/                   # docker-compose.yml & Axum Dockerfile
│   ├── nginx/                    # Caddyfile / Nginx reverse proxy configs
│   └── monitoring/               # prometheus.yml config
│
├── docs/                         # Project Documentation
│   └── architecture.md           # Monorepo architecture specification
│
├── scripts/                      # Developer Tooling & Helper Scripts
│   ├── build_native.sh           # Builds Rust p2p_engine shared library
│   └── dev_start.sh              # Launches local development environment
│
└── README.md                     # Monorepo root documentation
```

---

## ✨ Feature Highlights & Capabilities

- 🎨 **Modern Cross-Platform UI (`apps/flutter_app/`)**:
  - **Dynamic Theme Management**: Seamless, real-time toggling between Light and Dark themes.
  - **Multi-Tab Workspace**: Swarm Overview, Repository Catalog, Git DAG Visualizer, P2P Network Topology Map, and Local Node Storage Quota.
  - **Live Swarm Telemetry**: Real-time bandwidth upload/download speeds, active peer seeders, and node health indicators.
- ⚙️ **Native Rust Engine (`native/p2p_engine/`)**:
  - **Content-Addressed Git Blockstore**: SHA-256 object hashing for `Commit`, `Tree`, and `Blob` payloads.
  - **High-Performance Storage**: Fast disk block persistence with automated checksum validation.
  - **Dart FFI Integration**: Dynamic C-ABI bridge bindings (`package_ffi`) linking Flutter directly to native Rust logic.
- 🌐 **P2P Swarm Engine (`rust-libp2p`)**:
  - Multi-transport layer over **QUIC** and **TCP** with **Noise TLS** encryption.
  - **Kademlia DHT** for decentralized peer routing and Git object location lookup.
  - **Gossipsub** pub/sub for real-time repository DAG state announcements.
- 🛡️ **Modular Control Server (`server/`)**:
  - Secure **JWT & Refresh Token** authentication.
  - Repository metadata index, branch tracking, and role-based access control (`owner`, `maintainer`, `write`, `read`).
  - Full social collaboration suite: Issues, Pull Requests, Comments, and Notifications.

---

## 🏛️ CodeHub Hybrid Architecture

CodeHub employs a hybrid architecture balancing **decentralized, content-addressed storage** with **fast, centralized metadata indexing**:

```
                                 CODEHUB
                                    │
                       ┌────────────┴────────────┐
                       │                         │
                    CONTROL                   P2P DATA
                    PLANE                      PLANE
                       │                         │
                 ┌─────┼─────┐            ┌─────┼─────┐
                 │     │     │            │     │     │
                Auth  DB   Search        Peer   Peer  Peer
                 │     │     │            │     │     │
                 └─────┴─────┘            └─────┴─────┘
```

### 🛡️ Central Control Plane
- **Identity & Authentication**: JWT tokens, Argon2id password hashing, public key user credentials.
- **Relational Metadata Index (PostgreSQL)**:
  - Repository index, user access permissions.
  - Issues tracker, Pull Requests metadata, Comments, Labels, Milestones.
  - Social Graph: Stars, Followers, Watchers, Notifications.
- **Central Search Index**: GIN full-text index for fast repository metadata/topic filtering and code search without scanning P2P nodes.
- **Bootstrap & Rendezvous Discovery**: Facilitates initial peer discovery for new nodes entering the swarm.

### 🌐 P2P Data Plane
- **Content-Addressed Git Blockstore**: SHA-256 object hashing for `Commit`, `Tree`, `Blob`, and `Tag` objects.
- **Decentralized Sync Protocol**: direct peer-to-peer chunk transfers (`ANNOUNCE_REPOSITORY`, `REQUEST_CHUNK`, `SEND_CHUNK`).
- **Replication Guarantees**: Swarm replica health monitoring enforcing minimum copy count policies (e.g. 3/3 healthy replicas).
- **Zero-Trust Encryption**: Noise TLS 1.3 connection security and AES-GCM payload encryption for private repositories.

---

## 🌐 NAT Traversal & Circuit Relay Fallback Architecture

To guarantee reliable connectivity for nodes behind restrictive **NAT**, **CGNAT**, **Mobile Networks**, or **Corporate Firewalls**, CodeHub maintains a dual connection strategy:

```
                       Direct P2P Connection (STUN / AutoNAT)
                   Peer A ════════════════════════════════► Peer B
                               (Public IP / Unrestricted)

                                        OR

                      Fallback via Circuit Relay v2 (NAT / CGNAT)
                   Peer A ────────► Relay Node ────────► Peer B
                              (relay1.codehub.com)
```

1. **Direct P2P Traversal**: Enabled via `libp2p-autonat` and `libp2p-dcutr` (DCUtR hole punching).
2. **Circuit Relay v2 Fallback**: When direct socket binding fails due to symmetric firewalls, traffic is encapsulated via `libp2p-relay` through dedicated relay servers (`relay1.codehub.com`, `relay2.codehub.com`).

---

## 🚀 Production Server Deployment Architecture

### Phase 1: Single-Node Lean MVP Architecture
```
Internet → Cloudflare → Caddy/Nginx → Axum Control Server (API, Auth, Bootstrap)
                                              │
                                       ┌──────┴──────┐
                                       ▼             ▼
                                  PostgreSQL       Redis
```
- **Independent P2P Bootstrap Rendezvous Seeders**:
  - `p2p1.codehub.com`
  - `p2p2.codehub.com`
  - `p2p3.codehub.com`

---

### Phase 2: High-Availability Scale-Out Enterprise Topology
```
                                 Internet
                                    │
                                Cloudflare
                                    │
                              Load Balancer
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
                  API 1           API 2           API 3
                    │               │               │
                    └───────────────┼───────────────┘
                                    │
                             ┌──────┴──────┐
                             ▼             ▼
                        PostgreSQL       Redis
```

---

## 🌐 Sovereign Infrastructure Domains

- **`app.codehub.com`**: Web & Desktop Client Application
- **`api.codehub.com`**: Central Control Plane REST API (`https://api.codehub.com`)
- **`auth.codehub.com`**: Identity & JWT Token Service (`https://auth.codehub.com`)
- **`registry.codehub.com`**: Repository Metadata Index & Search (`https://registry.codehub.com`)
- **`p2p.codehub.com`**: libp2p Bootstrap Discovery Node (`/dns4/p2p.codehub.com/tcp/4001`)

---

## 🚀 Quickstart Guide

### Running the Flutter Application
```bash
cd apps/flutter_app
flutter pub get
flutter run -d linux
```

### Launching Control Server Infrastructure (Docker)
```bash
cd infrastructure/docker
docker-compose up --build -d
```

---

## 📄 License & Credits

Designed & Maintained by **Soham Mondal** for the CodeHub Decentralized Git Hosting Platform. Distributed under the MIT License.

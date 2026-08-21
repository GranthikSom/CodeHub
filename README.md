# CodeHub — Decentralized P2P Git Platform

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

**CodeHub** is an enterprise-grade, decentralized code-hosting platform engineered to replace centralized Git platforms with a resilient hybrid architecture. By coupling a **Flutter** client interface with a native **Rust (`rust-libp2p`)** engine, CodeHub enables content-addressed Git repository object replication across a peer-to-peer swarm while retaining centralized authentication, metadata indexing, and social collaboration features via a **Rust Axum** backend API.

---

## ✨ Key Features & Capabilities

- 🎨 **Modern Cross-Platform UI (Desktop & Mobile)**:
  - **Dynamic Theme Management**: Seamless, real-time toggling between Light and Dark themes.
  - **Multi-Tab Workspace**: Swarm Overview, Repository Catalog, Git DAG Visualizer, P2P Network Topology Map, and Local Node Storage Quota.
  - **Live Swarm Telemetry**: Real-time bandwidth upload/download speeds, active peer seeders, and node health indicators.
- ⚙️ **Native Rust Engine (`codehub_core`)**:
  - **Content-Addressed Git Blockstore**: SHA-256 object hashing for `Commit`, `Tree`, and `Blob` payloads.
  - **High-Performance Storage**: Fast disk block persistence with automated checksum validation.
  - **Dart FFI Integration**: Dynamic C-ABI bridge bindings (`package_ffi`) linking Flutter directly to native Rust logic.
- 🌐 **P2P Swarm Engine (`rust-libp2p`)**:
  - Multi-transport layer over **QUIC** and **TCP** with **Noise TLS** encryption.
  - **Kademlia DHT** for decentralized peer routing and Git object location lookup.
  - **Gossipsub** pub/sub for real-time repository DAG state announcements.
- 🛡️ **Hybrid Control Server (Rust `axum`)**:
  - Secure **JWT & Refresh Token** authentication.
  - Repository metadata index, branch tracking, and role-based access control (`owner`, `maintainer`, `write`, `read`).
  - Full social collaboration suite: Issues, Pull Requests, Comments, and Notifications.

---

## 🏛️ Architecture & Domain Layout

CodeHub uses a clear separation between the **Central Control Plane** and the **Decentralized Data Plane**, hosted under its sovereign subdomains:

```
               +-----------------------------------+
               |       CADDY REVERSE PROXY         |
               |      (Automatic TLS / SSL)        |
               +-----------------------------------+
                  │             │              │
        ┌─────────┘             │              └─────────┐
        ▼                       ▼                        ▼
  api.codehub.com       registry.codehub.com      p2p.codehub.com
  auth.codehub.com              │                        │
        │                       │                        │
        ▼                       ▼                        ▼
┌───────────────┐       ┌───────────────┐        ┌───────────────┐
│ Axum API      │       │ PostgreSQL DB │        │ libp2p Relay  │
│ (Auth & Repos)│       │ Index Store   │        │ Bootstrap Node│
└───────────────┘       └───────────────┘        └───────────────┘
```

| Subdomain | Service Purpose |
| :--- | :--- |
| **`app.codehub.com`** | Primary Web & Desktop Client Application |
| **`api.codehub.com`** | Central Control Plane REST API (`https://api.codehub.com`) |
| **`auth.codehub.com`** | Identity & JWT Token Service (`https://auth.codehub.com`) |
| **`registry.codehub.com`** | Repository Metadata Index & Search (`https://registry.codehub.com`) |
| **`p2p.codehub.com`** | libp2p Bootstrap Discovery Node (`/dns4/p2p.codehub.com/tcp/4001`) |

---

## 💻 Full Stack Technology Matrix

| Component | Technology | Primary Function |
| :--- | :--- | :--- |
| **UI Framework** | Flutter | Cross-platform UI for Linux, Windows, macOS, Android, and iOS |
| **Language** | Dart & Rust | Frontend state management & high-performance native engine |
| **Native P2P Engine** | Rust (`codehub_core`) | Content-addressed SHA-256 blockstore & Dart FFI bridge |
| **P2P Networking** | `rust-libp2p` | QUIC/TCP transport, Noise security, Kademlia DHT, Gossipsub |
| **Control Server** | Rust (`axum`) | REST API for authentication, metadata, issues, and PRs |
| **Database** | PostgreSQL 16 | Relational store for users, permissions, metadata, and comments |
| **Cache** | Redis 7 | Session token caching, rate limiting, and pub/sub queues |
| **Authentication** | JWT + Refresh Tokens | Token-based identity verification and API security |
| **Repository Model** | Git-compatible SHA-256 | Content-addressed object DAG model (Commits, Trees, Blobs) |
| **Reverse Proxy** | Caddy | Automatic HTTPS SSL certificate management & virtual host proxy |
| **Containers** | Docker & Compose | Multi-container environment orchestration |
| **Monitoring & Logs** | Prometheus & Grafana | Telemetry metrics, cluster monitoring, and node log aggregation |

---

## 📁 Repository Directory Structure

```
codehub/
├── lib/                             # Flutter Client UI Application
│   ├── config/api_config.dart       # CodeHub domain infrastructure endpoints
│   ├── dashboard/landing_page.dart  # Main multi-tab platform interface
│   ├── models/                      # GitObject, P2PNode, CodeRepository data models
│   ├── native/native_bindings.dart  # Dart FFI bindings for codehub_core
│   ├── services/codehub_state.dart  # Reactive state & telemetry provider
│   └── widgets/                     # DAG visualizer, header, topology & quota panels
├── native/codehub_core/             # Native Rust P2P & Blockstore Engine
│   ├── Cargo.toml                   # cdylib crate target with libp2p & sha2
│   └── src/
│       ├── blockstore.rs            # SHA-256 Git content-addressed block storage
│       ├── p2p_swarm.rs             # libp2p Swarm (QUIC, Noise, Kademlia DHT)
│       └── ffi_api.rs               # C-ABI exported functions for Flutter FFI
├── server/                          # Central Control Plane Backend Infrastructure
│   ├── codehub_control_plane/       # Rust Axum API Server
│   │   ├── Cargo.toml
│   │   ├── Dockerfile
│   │   └── src/main.rs              # REST API (Auth, Repos, Issues, PRs, Peers)
│   ├── migrations/0001_init.sql     # PostgreSQL database schemas
│   └── Caddyfile                    # Caddy reverse proxy domain configuration
└── docker-compose.yml               # Multi-container Docker Compose orchestration
```

---

## 🚀 Getting Started & Local Development

### Prerequisites
- **Flutter SDK**: `^3.12.2`
- **Rust Toolchain**: Rust 2021 Edition (`cargo` & `rustc`)
- **Docker & Docker Compose**: For local containerized infrastructure

### 1. Launch Flutter Desktop Client
```bash
# Clone the repository
git clone https://github.com/GranthikSom/CodeHub.git
cd codehub

# Fetch dependencies and run on Linux Desktop
flutter pub get
flutter run -d linux
```

### 2. Launch Control Server Infrastructure (Docker)
```bash
# Build and launch Axum API, PostgreSQL, Redis, and Caddy
docker-compose up --build -d
```
The Axum API server will be online at `http://localhost:8080` (health check at `http://localhost:8080/health`).

---

## 📄 License & Credits

Designed & Maintained by **Soham Mondal** for the CodeHub Decentralized Git Hosting Platform. Distributed under the MIT License.

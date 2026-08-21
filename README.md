# 🚀 CodeHub — Decentralized P2P Code Collaboration Platform

CodeHub is a developer platform where repositories are distributed across a peer network instead of depending entirely on centralized repository storage. Built with **Rust (Native P2P Engine & Axum Control Server)** and **Flutter (Desktop UI)**.

### 🌟 The 7 Pillars of Differentiation:
1. **Git-like Developer Platform**: Pull Requests, Issues, Code Browser, Commits & Branch workflows.
2. **Device Storage**: Leverages local peer SSD/NVMe disk space to decentralize storage burden.
3. **P2P Repository Replication**: BitSwap DAG-aware chunk distribution across active peer swarms.
4. **Centralized Control Plane**: Seamless JWT auth, team permissions, and zero-friction access management.
5. **Automatic Geo-Replication**: 9-Replica seed mesh (Owner + 3 Geo Seeds in GER/SGP/IND + 5 Community Peers) guaranteeing 99.999% SLA durability.
6. **Real-Time Repository Health Diagnostics**: Continuous replication score checks (0-100%) and auto-healing re-replication.
7. **Cross-Platform Flutter Client**: Native Desktop GUI (Linux, macOS, Windows) + Zero-Config CLI.

---

## 🏛️ Target Production Architecture

```text
                                   INTERNET
                                      │
                                Cloudflare WAF
                                      │
                      ┌───────────────┴───────────────┐
                      │                               │
                Axum Control API                  P2P Bootstrap Node
                      │                               │
           ┌──────────┼──────────┐                    │
           │          │          │                    │
         Auth       Repo       Search                 │
        (JWT)       (DAG)    (Tantivy)                │
           │          │          │                    │
           └──────────┼──────────┘                    │
                      │                               │
                 PostgreSQL                           │
            (Primary-Replica Sync)                    │
                      │                               │
                    Redis                             │
                 (Sentinel)                           │
                                                      │
                         ┌────────────────────────────┼────────────────────────────┐
                         │                            │                            │
                         ▼                            ▼                            ▼
                      Peer A                       Peer B                       Peer C
                   (Desktop UI)                 (Laptop Node)                 (Git CLI)
                         │                            │                            │
                         └────────────────────────────┼────────────────────────────┘
                                                      │
                                           P2P Swarm & BitSwap
                                                      │
                                           ┌──────────┼──────────┐
                                           ▼          ▼          ▼
                                        Seed 1     Seed 2     Seed 3
                                       (Germany) (Singapore) (India)
```

---

## 🔑 Core Features & System Phases

1. **Storage & Content Addressing Engine** (`Phase 1 – 3`): SHA-256 multihash chunking & dedup blockstore.
2. **Git Interop & DAG Engine** (`Phase 4 – 5`): Commit parsing, tree diffs, branch ref resolution.
3. **P2P Swarm Transfer Protocol** (`Phase 6 – 7`): Direct peer-to-peer transfers over libp2p + Kademlia DHT discovery.
4. **Replication Guarantees & Health Monitor** (`Phase 8`): Auto-healing re-replication upon node churn.
5. **Private Repositories & Zero-Knowledge Encryption** (`Phase 9`): AES-256-CTR-HMAC encryption & key grants.
6. **CodeHub Git CLI** (`Phase 10`): Custom `codehub clone`, `codehub push`, `codehub pull`, `codehub fetch`.
7. **GitHub Feature Parity** (`Phase 11`): Issues, PRs, Inline Reviews, Releases, Actions/CI, Webhooks, Projects, Discussions.
8. **Production Security Hardening** (`Phase 12`): Token-bucket rate limiting, DDoS burst protection, audit logs, quotas.
9. **Data Availability Pinning Cluster** (`Phase 13 – 14`): 24/7 dedicated pinning nodes & dual-role server embedded P2P storage peer.
10. **Multi-Tier Seed Mesh** (`Phase 15 – 16`): 9-replica topology (Owner + 3 Geo Seeds in Germany/Singapore/India + 5 Community Peers) guaranteeing 99.999% SLA durability.

---

## ⚡ Git-Native P2P Protocol Stack Specification

CodeHub avoids generic BitTorrent backends in favor of a 5-layer protocol tailored specifically for Git:

```text
┌────────────────────────────────────────────────────────────────────────┐
│ Layer 5: CodeHub Custom Replication Engine (GossipSub + BitSwap)     │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 4: Kademlia Peer Discovery & Provider Records (libp2p-kad DHT)  │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 3: libp2p Transport Core (QUIC, Noise Encryption, Yamux Mux)    │
├────────────────────────────────────────────────────────────────────────┤
│ Layer 2: Content-Addressed Storage (SHA-256 Multihash & FastCDC Chunks)│
├────────────────────────────────────────────────────────────────────────┤
│ Layer 1: Git Object Model (Commits, Trees, Blobs, Tags, References)    │
└────────────────────────────────────────────────────────────────────────┘
```

> **PubSub vs Direct Stream Architecture**: PubSub (`GossipSub`) is strictly utilized for lightweight swarm synchronization announcements (< 1KB). Binary chunk payloads are transferred out-of-band over direct P2P streams per official libp2p architectural guidelines.

---

## 🗓️ Version Release Roadmap (v0.1 -> v1.0)

| Version | Scope / Focus Milestone | Status |
| :--- | :--- | :--- |
| **v0.1** | **Core Proof-of-Concept MVP**: Register, Login, Create repository, Local repository, Git objects, Hashing, Chunking, Peer discovery, Peer connection, Upload, Download, Integrity verification, Replication, Repository browser. | ✅ COMPLETED |
| **v0.2** | **Collaboration Basics**: Issues, Branches, Commits, Tags. | ✅ COMPLETED |
| **v0.3** | **Advanced Peer Workflows**: Pull Requests, Inline Reviews, Repository Forks. | ✅ COMPLETED |
| **v0.4** | **Security & Encryption**: Private Repositories, AES-256 Zero-Knowledge Chunk Encryption. | ✅ COMPLETED |
| **v0.5** | **Developer CLI**: CodeHub Git CLI (`codehub clone`, `codehub push`, `codehub pull`). | ✅ COMPLETED |
| **v0.6** | **CI/CD & Event Workhooks**: Sandboxed Actions Runner & Triggers. | ✅ COMPLETED |
| **v1.0** | **Production Hardened Network**: 9-Replica Geo Seed Mesh & Cross-Platform Flutter Desktop App. | 🚀 LAUNCH READY |

---

## ⚙️ Running Locally

### 1. Control Server
```bash
cd server
cargo run
# API running at http://localhost:8080
```

### 2. Flutter Desktop Application
```bash
cd apps/flutter_app
flutter run -d linux
```

### 3. CodeHub Git CLI
```bash
cd cli
cargo run -- push codehub://soham/codehub
```

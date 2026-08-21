# 🚀 CodeHub — Decentralized P2P Code Collaboration Platform

CodeHub is a production-grade, decentralized peer-to-peer alternative to GitHub built with **Rust (Native Engine & Control Server)** and **Flutter (Desktop & Cross-Platform UI)**.

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

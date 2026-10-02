# 🌐 CodeHub Production Deployment & Operations Guide

## 1. System Overview & Architecture

CodeHub is a sovereign, decentralized peer-to-peer developer platform engineered with a hybrid data/control split:

```
                            ┌────────────────────────────────────────┐
                            │          Edge Reverse Proxy            │
                            │           (Caddy / Nginx)              │
                            └──────────────────┬─────────────────────┘
                                               │
                       ┌───────────────────────┴───────────────────────┐
                       ▼                                               ▼
     ┌──────────────────────────────────┐            ┌──────────────────────────────────┐
     │      Axum Control Plane API      │            │       Flutter Web Client         │
     │      (Port 8080 & 4001 P2P)      │            │         (Port 3000)              │
     └─────────┬──────────────┬─────────┘            └──────────────────────────────────┘
               │              │
               ▼              ▼
     ┌──────────────────┐   ┌──────────────────┐
     │   PostgreSQL 16  │   │     Redis 7      │
     │  (Metadata DB)   │   │  (PubSub/Cache)  │
     └──────────────────┘   └──────────────────┘
```

- **Decentralized Data Plane**: Local SSD/NVMe content-addressed storage using SHA-256 multihashes, FastCDC chunking, and direct out-of-band transfers over libp2p BitSwap streams.
- **Centralized Control Plane**: Rust Axum REST API + WebSockets handling JWT authentication, team authorization, repository index registry, and Kademlia DHT bootstrap coordination.
- **Clients**: Native Flutter Desktop (Linux, macOS, Windows) equipped with Dart C-ABI FFI directly to the native Rust engine, plus zero-install Web SPA.

---

## 2. Environment Configuration

All environment configurations are unified through `.env` (development) or `.env.production` (production):

| Variable | Description | Default / Example |
| :--- | :--- | :--- |
| `ENVIRONMENT` | Target environment mode | `production` |
| `DATABASE_URL` | PostgreSQL connection string | `postgres://codehub:secret@postgres:5432/codehub_db` |
| `REDIS_URL` | Redis cache & pubsub connection string | `redis://:secret@redis:6379` |
| `JWT_SECRET` | 32+ character HMAC key for auth tokens | *(Generate with `openssl rand -base64 48`)* |
| `P2P_NODE_PRIVATE_KEY` | 32-byte Base64 Ed25519 secret seed for persistent Peer ID | *(Generate with `openssl rand -base64 32`)* |
| `HOST` / `PORT` | Control plane server listen address | `0.0.0.0` / `8080` |
| `API_BASE_URL` | Client HTTP endpoint | `https://api.codehub.p2p/api/v1` |
| `SOCKET_WS_URL` | Client WebSocket endpoint | `wss://api.codehub.p2p/api/v1/events/ws` |
| `P2P_BOOTSTRAP_RELAY_MULTIADDR` | Libp2p relay rendezvous address | `/dns4/p2p.codehub.p2p/tcp/4001/p2p/...` |
| `CADDY_ACME_EMAIL` | Contact email for Let's Encrypt / ACME SSL certificate issuance | `sohammondal1304@gmail.com` |

### DNS & Hostname Configuration

Configure the following DNS `A` records (or `/etc/hosts` entries) pointing to your production server IP:

```
YOUR_SERVER_IP codehub.p2p
YOUR_SERVER_IP app.codehub.p2p
YOUR_SERVER_IP api.codehub.p2p
YOUR_SERVER_IP p2p.codehub.p2p
```

| Subdomain | Target | Reverse Proxy Mapping |
| :--- | :--- | :--- |
| `codehub.p2p` | `YOUR_SERVER_IP` | `web:80` (Web Landing & UI) |
| `app.codehub.p2p` | `YOUR_SERVER_IP` | `web:80` (Flutter Web SPA) |
| `api.codehub.p2p` | `YOUR_SERVER_IP` | `control_plane:8080` (REST & WebSockets) |
| `p2p.codehub.p2p` | `YOUR_SERVER_IP` | `control_plane:4001` (Libp2p Swarm Relay) |

---

## 3. Production Deployment with Docker Compose

To launch the full production stack:

```bash
# 1. Copy and populate production secrets
cp .env.example .env.production

# 2. Build and start containers in detached mode
docker compose --env-file .env.production up -d --build

# 3. Check health status
docker compose ps
curl http://localhost:8080/health
```

The stack provisions:
- `codehub_control_plane`: High-throughput Axum server + P2P rendezvous peer.
- `codehub_web`: Flutter Web application served via high-performance Nginx with gzip & security headers.
- `codehub_postgres`: PostgreSQL 16 with pre-migrated schema and healthchecks.
- `codehub_redis`: Redis 7 with password enforcement.
- `codehub_caddy`: Automatic HTTPS reverse proxy and TLS edge gateway.
- `codehub_prometheus`: Prometheus metrics scraper on port 9090.

---

## 4. Continuous Integration & Delivery (CI/CD)

Automated GitHub Actions workflows are provided under `.github/workflows/`:

1. **`ci.yml`**:
   - Compiles and checks the complete Rust workspace (`p2p_engine`, `codehub_server`, `codehub_cli`).
   - Runs `cargo test --workspace` and `cargo fmt --check`.
   - Executes `flutter analyze`, `flutter test`, and builds release targets for Linux and Web.
   - Validates all Docker Compose configurations.

2. **`docker.yml`**:
   - Builds multi-stage production Docker containers for the server and web frontend.
   - Pushes versioned and latest images to GitHub Container Registry (`ghcr.io`).

3. **`release.yml`**:
   - Triggers on tag pushes (`v*.*.*`).
   - Packages Linux desktop tarballs (`codehub-desktop-linux-x64.tar.gz`), CLI standalone binaries (`codehub-cli-linux-x64`), and web archives (`codehub-web.zip`).
   - Generates cryptographic SHA-256 checksums (`SHA256SUMS.txt`) and publishes a GitHub Release.

---

## 5. Development & Testing Scripts

- **Full Monorepo Build**: `bash scripts/build_all.sh`
- **Run All Tests**: `bash scripts/test_all.sh`
- **Native Library Build**: `bash scripts/build_native.sh`
- **Launch Dev Environment**: `bash scripts/dev_start.sh`

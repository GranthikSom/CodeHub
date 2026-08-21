use axum::{
    extract::Path,
    routing::{get, post},
    Json, Router,
};
use std::net::SocketAddr;
use tower_http::cors::{Any, CorsLayer};

pub mod api;
pub mod auth;
pub mod discovery;
pub mod repository;
pub mod search;

use api::{ApiResponse, HealthStatus};
use auth::{generate_jwt_token, AuthRequest, AuthResponse};
use discovery::{get_bootstrap_peers, PeerDiscoveryNode};
use repository::{IssueItem, PullRequestItem, RepoIndexItem};

#[tokio::main]
async fn main() {
    tracing_subscriber::fmt::init();

    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods(Any)
        .allow_headers(Any);

    let app = Router::new()
        .route("/health", get(health_check))
        .route("/api/v1/auth/register", post(register_user))
        .route("/api/v1/auth/login", post(login_user))
        .route("/api/v1/repos", get(list_repositories).post(create_repository))
        .route("/api/v1/repos/:id/issues", get(list_issues))
        .route("/api/v1/repos/:id/pulls", get(list_pulls))
        .route("/api/v1/swarm/peers", get(list_swarm_peers))
        .layer(cors);

    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    println!("🚀 CodeHub Monorepo Control Server running at http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn health_check() -> Json<ApiResponse<HealthStatus>> {
    Json(ApiResponse {
        success: true,
        message: "CodeHub Monorepo Server Operational".to_string(),
        data: Some(HealthStatus {
            status: "online".to_string(),
            version: "1.0.0".to_string(),
            active_swarm_peers: 14,
            total_indexed_repos: 42,
        }),
    })
}

async fn register_user(Json(payload): Json<AuthRequest>) -> Json<ApiResponse<AuthResponse>> {
    let token = generate_jwt_token(&payload.username);
    Json(ApiResponse {
        success: true,
        message: format!("User '{}' registered", payload.username),
        data: Some(AuthResponse { token, expires_in: 86400 }),
    })
}

async fn login_user(Json(payload): Json<AuthRequest>) -> Json<ApiResponse<AuthResponse>> {
    let token = generate_jwt_token(&payload.username);
    Json(ApiResponse {
        success: true,
        message: format!("User '{}' logged in", payload.username),
        data: Some(AuthResponse { token, expires_in: 86400 }),
    })
}

async fn list_repositories() -> Json<ApiResponse<Vec<RepoIndexItem>>> {
    let repos = vec![
        RepoIndexItem {
            id: "repo-1".to_string(),
            name: "codehub-core-p2p".to_string(),
            owner: "GranthikSom".to_string(),
            root_commit_hash: "commit_e4b0c2a1f8e9d7c6b5a4f3e2d1c0b9a8f7e6d5c4".to_string(),
            total_objects: 1420,
            seed_count: 4,
            is_private: false,
        },
    ];

    Json(ApiResponse {
        success: true,
        message: "Repositories retrieved".to_string(),
        data: Some(repos),
    })
}

async fn create_repository(Json(payload): Json<RepoIndexItem>) -> Json<ApiResponse<RepoIndexItem>> {
    Json(ApiResponse {
        success: true,
        message: format!("Repository '{}' created", payload.name),
        data: Some(payload),
    })
}

async fn list_issues(Path(repo_id): Path<String>) -> Json<ApiResponse<Vec<IssueItem>>> {
    let issues = vec![
        IssueItem {
            id: "issue-101".to_string(),
            repo_id,
            issue_number: 1,
            title: "Support QUIC multiplexing over libp2p".to_string(),
            author: "GranthikSom".to_string(),
            status: "open".to_string(),
        },
    ];
    Json(ApiResponse {
        success: true,
        message: "Issues retrieved".to_string(),
        data: Some(issues),
    })
}

async fn list_pulls(Path(repo_id): Path<String>) -> Json<ApiResponse<Vec<PullRequestItem>>> {
    let pulls = vec![
        PullRequestItem {
            id: "pr-201".to_string(),
            repo_id,
            pr_number: 1,
            title: "feat: implement Kademlia DHT peer discovery".to_string(),
            author: "GranthikSom".to_string(),
            source_branch: "feature/dht-routing".to_string(),
            target_branch: "main".to_string(),
            status: "open".to_string(),
        },
    ];
    Json(ApiResponse {
        success: true,
        message: "Pull requests retrieved".to_string(),
        data: Some(pulls),
    })
}

async fn list_swarm_peers() -> Json<ApiResponse<Vec<PeerDiscoveryNode>>> {
    Json(ApiResponse {
        success: true,
        message: "Swarm bootstrap peers retrieved".to_string(),
        data: Some(get_bootstrap_peers()),
    })
}

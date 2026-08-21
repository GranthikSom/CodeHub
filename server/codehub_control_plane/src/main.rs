use axum::{
    extract::Path,
    routing::{get, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;
use tower_http::cors::{Any, CorsLayer};

#[derive(Serialize, Deserialize)]
pub struct ApiResponse<T> {
    pub success: bool,
    pub message: String,
    pub data: Option<T>,
}

#[derive(Serialize, Deserialize)]
pub struct HealthStatus {
    pub status: String,
    pub version: String,
    pub active_swarm_peers: usize,
    pub total_indexed_repos: usize,
}

#[derive(Serialize, Deserialize)]
pub struct AuthRequest {
    pub username: String,
    pub public_key: String,
}

#[derive(Serialize, Deserialize)]
pub struct AuthResponse {
    pub token: String,
    pub expires_in: u64,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct RepoIndexItem {
    pub id: String,
    pub name: String,
    pub owner: String,
    pub root_commit_hash: String,
    pub total_objects: usize,
    pub seed_count: usize,
    pub is_private: bool,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct IssueItem {
    pub id: String,
    pub repo_id: String,
    pub issue_number: usize,
    pub title: String,
    pub author: String,
    pub status: String, // "open" | "closed"
}

#[derive(Serialize, Deserialize, Clone)]
pub struct PullRequestItem {
    pub id: String,
    pub repo_id: String,
    pub pr_number: usize,
    pub title: String,
    pub author: String,
    pub source_branch: String,
    pub target_branch: String,
    pub status: String, // "open" | "merged" | "closed"
}

#[derive(Serialize, Deserialize, Clone)]
pub struct MemberPermission {
    pub username: String,
    pub role: String, // "owner" | "maintainer" | "write" | "read"
}

#[derive(Serialize, Deserialize, Clone)]
pub struct NotificationItem {
    pub id: String,
    pub message: String,
    pub is_read: bool,
}

#[derive(Serialize, Deserialize, Clone)]
pub struct PeerDiscoveryNode {
    pub node_id: String,
    pub multiaddr: String,
    pub nat_type: String,
    pub is_seeding: bool,
}

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
        .route("/api/v1/repos/:id/issues", get(list_issues).post(create_issue))
        .route("/api/v1/repos/:id/pulls", get(list_pulls).post(create_pull))
        .route("/api/v1/repos/:id/members", get(list_members))
        .route("/api/v1/notifications", get(list_notifications))
        .route("/api/v1/swarm/peers", get(list_swarm_peers))
        .layer(cors);

    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    println!("🚀 CodeHub Central Control Plane API running at http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn health_check() -> Json<ApiResponse<HealthStatus>> {
    Json(ApiResponse {
        success: true,
        message: "CodeHub Control Plane Operational".to_string(),
        data: Some(HealthStatus {
            status: "online".to_string(),
            version: "1.0.0".to_string(),
            active_swarm_peers: 14,
            total_indexed_repos: 42,
        }),
    })
}

async fn register_user(Json(payload): Json<AuthRequest>) -> Json<ApiResponse<AuthResponse>> {
    Json(ApiResponse {
        success: true,
        message: format!("User '{}' registered successfully", payload.username),
        data: Some(AuthResponse {
            token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.codehub.p2p.sample.token".to_string(),
            expires_in: 86400,
        }),
    })
}

async fn login_user(Json(payload): Json<AuthRequest>) -> Json<ApiResponse<AuthResponse>> {
    Json(ApiResponse {
        success: true,
        message: format!("User '{}' authenticated", payload.username),
        data: Some(AuthResponse {
            token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.codehub.p2p.sample.token".to_string(),
            expires_in: 86400,
        }),
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
        RepoIndexItem {
            id: "repo-2".to_string(),
            name: "flutter-dag-visualizer".to_string(),
            owner: "GranthikSom".to_string(),
            root_commit_hash: "commit_8f2a1b9c4d3e5f6a7b8c9d0e1f2a3b4c5d6e7f8a".to_string(),
            total_objects: 380,
            seed_count: 3,
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
        message: format!("Repository '{}' registered in index", payload.name),
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

async fn create_issue(Path(repo_id): Path<String>, Json(payload): Json<IssueItem>) -> Json<ApiResponse<IssueItem>> {
    let mut item = payload;
    item.repo_id = repo_id;
    Json(ApiResponse {
        success: true,
        message: format!("Issue #{} created", item.issue_number),
        data: Some(item),
    })
}

async fn list_pulls(Path(repo_id): Path<String>) -> Json<ApiResponse<Vec<PullRequestItem>>> {
    let pulls = vec![
        PullRequestItem {
            id: "pr-201".to_string(),
            repo_id,
            pr_number: 1,
            title: "feat: implement Kademlia DHT peer discovery routing".to_string(),
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

async fn create_pull(Path(repo_id): Path<String>, Json(payload): Json<PullRequestItem>) -> Json<ApiResponse<PullRequestItem>> {
    let mut item = payload;
    item.repo_id = repo_id;
    Json(ApiResponse {
        success: true,
        message: format!("Pull request #{} created", item.pr_number),
        data: Some(item),
    })
}

async fn list_members(Path(_repo_id): Path<String>) -> Json<ApiResponse<Vec<MemberPermission>>> {
    let members = vec![
        MemberPermission {
            username: "GranthikSom".to_string(),
            role: "owner".to_string(),
        },
        MemberPermission {
            username: "SohamMondal".to_string(),
            role: "maintainer".to_string(),
        },
    ];
    Json(ApiResponse {
        success: true,
        message: "Repository members & roles retrieved".to_string(),
        data: Some(members),
    })
}

async fn list_notifications() -> Json<ApiResponse<Vec<NotificationItem>>> {
    let notifications = vec![
        NotificationItem {
            id: "notif-1".to_string(),
            message: "Your node is currently seeding codehub-core-p2p to 4 swarm peers".to_string(),
            is_read: false,
        },
    ];
    Json(ApiResponse {
        success: true,
        message: "Notifications retrieved".to_string(),
        data: Some(notifications),
    })
}

async fn list_swarm_peers() -> Json<ApiResponse<Vec<PeerDiscoveryNode>>> {
    let peers = vec![
        PeerDiscoveryNode {
            node_id: "12D3KooWDeviceALaptop456".to_string(),
            multiaddr: "/ip4/192.168.1.104/tcp/4001/p2p/12D3KooWDeviceALaptop456".to_string(),
            nat_type: "Full Cone NAT".to_string(),
            is_seeding: true,
        },
        PeerDiscoveryNode {
            node_id: "12D3KooWDeviceBDesktop890".to_string(),
            multiaddr: "/ip4/10.0.4.18/tcp/4001/p2p/12D3KooWDeviceBDesktop890".to_string(),
            nat_type: "UPnP Traversed".to_string(),
            is_seeding: true,
        },
    ];

    Json(ApiResponse {
        success: true,
        message: "Swarm bootstrap peers retrieved".to_string(),
        data: Some(peers),
    })
}

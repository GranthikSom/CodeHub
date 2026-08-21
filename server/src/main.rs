use axum::{
    extract::{Path, Query},
    http::StatusCode,
    routing::{delete, get, patch, post},
    Json, Router,
};
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;
use tower_http::cors::{Any, CorsLayer};

pub mod api;
pub mod auth;
pub mod db;
pub mod discovery;
pub mod repository;
pub mod search;

use api::{ApiResponse, HealthStatus};
use auth::{generate_jwt_token, AuthRequest, AuthResponse};
use repository::{IssueItem, PullRequestItem, RepoIndexItem};

#[derive(Debug, Serialize, Deserialize)]
pub struct UserProfile {
    pub username: String,
    pub display_name: String,
    pub email: String,
    pub bio: String,
    pub repositories_count: usize,
    pub joined_at: String,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct UpdateProfilePayload {
    pub display_name: Option<String>,
    pub bio: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct PeerAnnouncePayload {
    pub peer_id: String,
    pub port: u16,
    pub downloaded_chunks: usize,
    pub is_seeding: bool,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct PeerAnnounceResponse {
    pub peer_id: String,
    pub status: String,
    pub seeders_count: usize,
    pub leechers_count: usize,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ReplicationFactorPayload {
    pub min_replicas: usize,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct SearchQuery {
    pub q: Option<String>,
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
        
        // 1. Authentication & Authorization routes
        .route("/api/v1/auth/register", post(register_user))
        .route("/api/v1/auth/login", post(login_user))
        .route("/api/v1/auth/refresh", post(refresh_token))
        .route("/api/v1/auth/logout", post(logout_user))
        .route("/api/v1/auth/authorize", post(authorize_user_action))
        
        // 2. Users routes
        .route("/api/v1/users/me", patch(update_my_profile))
        .route("/api/v1/users/:username", get(get_user_profile))
        
        // 3. Repositories routes
        .route("/api/v1/repositories", post(create_repository).get(list_repositories))
        .route(
            "/api/v1/repositories/:id",
            get(get_repository_by_id)
                .patch(update_repository)
                .delete(delete_repository),
        )
        
        // 4. Repository peers, replication & key management routes
        .route("/api/v1/repositories/:id/announce", post(announce_peer))
        .route("/api/v1/repositories/:id/peers", get(get_repository_peers))
        .route("/api/v1/repositories/:id/replicas", post(update_replication_factor))
        .route("/api/v1/repositories/:id/replication-status", get(get_replication_status))
        .route("/api/v1/repositories/:id/keys/grant", post(grant_repository_key))
        .route("/api/v1/repositories/:id/keys/access", get(get_repository_key_access))
        
        // 5. Bootstrap Node & Rendezvous Discovery routes
        .route("/api/v1/swarm/bootstrap-nodes", get(get_bootstrap_server_nodes))
        .route("/api/v1/swarm/rendezvous/:repo_id", get(get_rendezvous_repository_peers))
        
        // 6. Search routes
        .route("/api/v1/search/repositories", get(search_repositories))
        
        // 7. Issues routes
        .route("/api/v1/repositories/:id/issues", get(list_issues).post(create_issue))
        
        // 8. Fork & Pull requests routes
        .route("/api/v1/repositories/:id/fork", post(fork_repository))
        .route("/api/v1/repositories/:id/pulls", get(list_pulls).post(create_pull_request))
        .route("/api/v1/repositories/:id/pulls/:pr_id", get(get_pull_request_by_id))
        .route("/api/v1/repositories/:id/pulls/:pr_id/merge", post(merge_pull_request_handler))
        
        .layer(cors);

    let addr = SocketAddr::from(([0, 0, 0, 0], 8080));
    println!("🚀 CodeHub Control Server API running at http://{}", addr);

    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn health_check() -> Json<ApiResponse<HealthStatus>> {
    Json(ApiResponse {
        success: true,
        message: "CodeHub Control Server API Operational".to_string(),
        data: Some(HealthStatus {
            status: "online".to_string(),
            version: "1.0.0".to_string(),
            active_swarm_peers: 14,
            total_indexed_repos: 42,
        }),
    })
}

// -----------------------------------------------------------------------------
// 1. AUTHENTICATION HANDLERS
// -----------------------------------------------------------------------------

async fn register_user(Json(payload): Json<AuthRequest>) -> Json<ApiResponse<AuthResponse>> {
    let token = generate_jwt_token(&payload.username);
    Json(ApiResponse {
        success: true,
        message: format!("Account created successfully for '{}'", payload.username),
        data: Some(AuthResponse { token, expires_in: 86400 }),
    })
}

async fn login_user(Json(payload): Json<AuthRequest>) -> Json<ApiResponse<AuthResponse>> {
    let token = generate_jwt_token(&payload.username);
    Json(ApiResponse {
        success: true,
        message: format!("User '{}' authenticated successfully", payload.username),
        data: Some(AuthResponse { token, expires_in: 86400 }),
    })
}

async fn refresh_token() -> Json<ApiResponse<AuthResponse>> {
    let token = generate_jwt_token("refreshed_user");
    Json(ApiResponse {
        success: true,
        message: "JWT access token refreshed successfully".to_string(),
        data: Some(AuthResponse { token, expires_in: 86400 }),
    })
}

async fn logout_user() -> Json<ApiResponse<()>> {
    Json(ApiResponse {
        success: true,
        message: "User logged out successfully".to_string(),
        data: None,
    })
}

async fn authorize_user_action(
    Json(payload): Json<discovery::AuthorizationRequest>,
) -> Json<ApiResponse<discovery::AuthorizationResponse>> {
    Json(ApiResponse {
        success: true,
        message: format!(
            "User '{}' authorized for '{}' access on repo '{}'",
            payload.username, payload.requested_permission, payload.repo_id
        ),
        data: Some(discovery::AuthorizationResponse {
            is_authorized: true,
            role: "maintainer".to_string(),
            user_id: "usr_998877665544332211".to_string(),
            repo_id: payload.repo_id,
        }),
    })
}

// -----------------------------------------------------------------------------
// 2. USERS HANDLERS
// -----------------------------------------------------------------------------

async fn get_user_profile(Path(username): Path<String>) -> Json<ApiResponse<UserProfile>> {
    let profile = UserProfile {
        username: username.clone(),
        display_name: format!("{} (Core Dev)", username),
        email: format!("{}@codehub.p2p", username.to_lowercase()),
        bio: "Decentralized P2P enthusiast building high-speed blockstores.".to_string(),
        repositories_count: 5,
        joined_at: "2026-01-15T00:00:00Z".to_string(),
    };

    Json(ApiResponse {
        success: true,
        message: format!("Profile for '{}' retrieved", username),
        data: Some(profile),
    })
}

async fn update_my_profile(Json(payload): Json<UpdateProfilePayload>) -> Json<ApiResponse<UserProfile>> {
    let profile = UserProfile {
        username: "me".to_string(),
        display_name: payload.display_name.unwrap_or_else(|| "Soham Mondal".to_string()),
        email: "soham@codehub.p2p".to_string(),
        bio: payload.bio.unwrap_or_else(|| "Lead Architect @ CodeHub P2P".to_string()),
        repositories_count: 12,
        joined_at: "2026-01-01T00:00:00Z".to_string(),
    };

    Json(ApiResponse {
        success: true,
        message: "User profile updated successfully".to_string(),
        data: Some(profile),
    })
}

// -----------------------------------------------------------------------------
// 3. REPOSITORIES HANDLERS
// -----------------------------------------------------------------------------

async fn list_repositories() -> Json<ApiResponse<Vec<RepoIndexItem>>> {
    let repos = vec![
        RepoIndexItem {
            id: "repo_101".to_string(),
            name: "codehub-core-p2p".to_string(),
            owner: "GranthikSom".to_string(),
            root_commit_hash: "a81c4e97d2f831b2c4d5e6f7a8b9c0d1e2f3a4b5".to_string(),
            total_objects: 1420,
            seed_count: 8,
            is_private: false,
        },
        RepoIndexItem {
            id: "repo_102".to_string(),
            name: "flutter-torrent-ui".to_string(),
            owner: "SohamMondal".to_string(),
            root_commit_hash: "b92d5f08e3a1b4c7d6e9f0a2b3c4d5e6f7a8b9c0".to_string(),
            total_objects: 512,
            seed_count: 5,
            is_private: false,
        },
    ];

    Json(ApiResponse {
        success: true,
        message: "Indexed repositories retrieved".to_string(),
        data: Some(repos),
    })
}

async fn create_repository(Json(payload): Json<RepoIndexItem>) -> (StatusCode, Json<ApiResponse<RepoIndexItem>>) {
    (
        StatusCode::CREATED,
        Json(ApiResponse {
            success: true,
            message: format!("Repository '{}' registered in global DHT catalog", payload.name),
            data: Some(payload),
        }),
    )
}

async fn get_repository_by_id(Path(id): Path<String>) -> Json<ApiResponse<RepoIndexItem>> {
    let repo = RepoIndexItem {
        id: id.clone(),
        name: format!("repo-{}", id),
        owner: "GranthikSom".to_string(),
        root_commit_hash: "c03e6a19f4b7c8d9e0a1b2c3d4e5f6a7b8c9d0e1".to_string(),
        total_objects: 2048,
        seed_count: 14,
        is_private: false,
    };

    Json(ApiResponse {
        success: true,
        message: format!("Repository '{}' retrieved", id),
        data: Some(repo),
    })
}

async fn update_repository(
    Path(id): Path<String>,
    Json(payload): Json<RepoIndexItem>,
) -> Json<ApiResponse<RepoIndexItem>> {
    Json(ApiResponse {
        success: true,
        message: format!("Repository '{}' updated", id),
        data: Some(payload),
    })
}

async fn delete_repository(Path(id): Path<String>) -> Json<ApiResponse<()>> {
    Json(ApiResponse {
        success: true,
        message: format!("Repository '{}' deleted from control index", id),
        data: None,
    })
}

// -----------------------------------------------------------------------------
// 4. REPOSITORY PEERS & TRACKER HANDLERS
// -----------------------------------------------------------------------------

async fn announce_peer(
    Path(id): Path<String>,
    Json(payload): Json<PeerAnnouncePayload>,
) -> Json<ApiResponse<PeerAnnounceResponse>> {
    let response = PeerAnnounceResponse {
        peer_id: payload.peer_id,
        status: "announced".to_string(),
        seeders_count: 8,
        leechers_count: 3,
    };

    Json(ApiResponse {
        success: true,
        message: format!("Peer announced to repository tracker '{}'", id),
        data: Some(response),
    })
}

async fn get_repository_peers(Path(id): Path<String>) -> Json<ApiResponse<Vec<discovery::PeerDiscoveryNode>>> {
    let peers = discovery::get_bootstrap_peers();
    Json(ApiResponse {
        success: true,
        message: format!("Active seeders/leechers retrieved for repository '{}'", id),
        data: Some(peers),
    })
}

async fn update_replication_factor(
    Path(id): Path<String>,
    Json(payload): Json<ReplicationFactorPayload>,
) -> Json<ApiResponse<String>> {
    Json(ApiResponse {
        success: true,
        message: format!(
            "Target replication factor for repo '{}' updated to min {} replicas",
            id, payload.min_replicas
        ),
        data: Some(format!("min_replicas={}", payload.min_replicas)),
    })
}

async fn get_replication_status(
    Path(id): Path<String>,
) -> Json<ApiResponse<repository::ReplicationHealthStatus>> {
    let engine = repository::ReplicationPolicyEngine::new(3);
    let active_seeders = 8; // Simulating active seeders count from tracker
    let status = engine.evaluate_health(&id, active_seeders);

    Json(ApiResponse {
        success: true,
        message: format!("Replication health status evaluated for repository '{}'", id),
        data: Some(status),
    })
}

#[derive(serde::Deserialize)]
struct KeyGrantPayload {
    target_user_id: String,
    granted_by: String,
    user_public_key: String,
}

async fn grant_repository_key(
    Path(repo_id): Path<String>,
    Json(payload): Json<KeyGrantPayload>,
) -> Json<ApiResponse<String>> {
    Json(ApiResponse {
        success: true,
        message: format!(
            "Encrypted repository key granted to member '{}' for repo '{}'",
            payload.target_user_id, repo_id
        ),
        data: Some(format!(
            "granted_key_hash=8f91ab_{}_{}",
            payload.target_user_id, repo_id
        )),
    })
}

async fn get_repository_key_access(
    Path(repo_id): Path<String>,
) -> Json<ApiResponse<String>> {
    Json(ApiResponse {
        success: true,
        message: format!("Retrieved encrypted symmetric key payload for repo '{}'", repo_id),
        data: Some("encrypted_key_payload_hex_998877665544332211".to_string()),
    })
}

// -----------------------------------------------------------------------------
// 5. BOOTSTRAP NODE & RENDEZVOUS DISCOVERY HANDLERS
// -----------------------------------------------------------------------------

async fn get_bootstrap_server_nodes() -> Json<ApiResponse<discovery::BootstrapServerConfig>> {
    let config = discovery::get_bootstrap_server_config();
    Json(ApiResponse {
        success: true,
        message: "Master bootstrap node multiaddrs & DHT protocols retrieved".to_string(),
        data: Some(config),
    })
}

async fn get_rendezvous_repository_peers(
    Path(repo_id): Path<String>,
) -> Json<ApiResponse<Vec<discovery::PeerDiscoveryNode>>> {
    let peers = discovery::get_rendezvous_peers(&repo_id);
    Json(ApiResponse {
        success: true,
        message: format!("Discovered Rendezvous/DHT seeders for repository '{}'", repo_id),
        data: Some(peers),
    })
}

// -----------------------------------------------------------------------------
// 5. SEARCH HANDLERS
// -----------------------------------------------------------------------------

async fn search_repositories(Query(params): Query<SearchQuery>) -> Json<ApiResponse<Vec<RepoIndexItem>>> {
    let query_str = params.q.unwrap_or_default();
    let all_repos = vec![
        RepoIndexItem {
            id: "repo_101".to_string(),
            name: "codehub-core-p2p".to_string(),
            owner: "GranthikSom".to_string(),
            root_commit_hash: "a81c4e97d2f831b2c4d5e6f7a8b9c0d1e2f3a4b5".to_string(),
            total_objects: 1420,
            seed_count: 8,
            is_private: false,
        },
        RepoIndexItem {
            id: "repo_102".to_string(),
            name: "flutter-torrent-ui".to_string(),
            owner: "SohamMondal".to_string(),
            root_commit_hash: "b92d5f08e3a1b4c7d6e9f0a2b3c4d5e6f7a8b9c0".to_string(),
            total_objects: 512,
            seed_count: 5,
            is_private: false,
        },
    ];

    let filtered: Vec<RepoIndexItem> = if query_str.is_empty() {
        all_repos
    } else {
        all_repos
            .into_iter()
            .filter(|r| r.name.to_lowercase().contains(&query_str.to_lowercase()))
            .collect()
    };

    Json(ApiResponse {
        success: true,
        message: format!("Found {} matching repositories for query '{}'", filtered.len(), query_str),
        data: Some(filtered),
    })
}

// -----------------------------------------------------------------------------
// 6. ISSUES HANDLERS
// -----------------------------------------------------------------------------

async fn list_issues(Path(repo_id): Path<String>) -> Json<ApiResponse<Vec<IssueItem>>> {
    let issues = vec![
        IssueItem {
            id: "issue-101".to_string(),
            repo_id: repo_id.clone(),
            issue_number: 1,
            title: "Support QUIC multiplexing over libp2p".to_string(),
            author: "GranthikSom".to_string(),
            status: "open".to_string(),
        },
    ];
    Json(ApiResponse {
        success: true,
        message: format!("Issues retrieved for repository '{}'", repo_id),
        data: Some(issues),
    })
}

async fn create_issue(
    Path(repo_id): Path<String>,
    Json(payload): Json<IssueItem>,
) -> (StatusCode, Json<ApiResponse<IssueItem>>) {
    let mut issue = payload;
    issue.repo_id = repo_id;

    (
        StatusCode::CREATED,
        Json(ApiResponse {
            success: true,
            message: format!("Issue #{} opened", issue.issue_number),
            data: Some(issue),
        }),
    )
}

// -----------------------------------------------------------------------------
// 7. PULL REQUESTS HANDLERS
// -----------------------------------------------------------------------------

async fn list_pulls(Path(repo_id): Path<String>) -> Json<ApiResponse<Vec<PullRequestItem>>> {
    let pulls = vec![
        PullRequestItem {
            id: "pr-201".to_string(),
            repo_id: repo_id.clone(),
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
        message: format!("Pull requests retrieved for repository '{}'", repo_id),
        data: Some(pulls),
    })
}

async fn create_pull_request(
    Path(repo_id): Path<String>,
    Json(payload): Json<PullRequestItem>,
) -> (StatusCode, Json<ApiResponse<PullRequestItem>>) {
    let mut pr = payload;
    pr.repo_id = repo_id;

    (
        StatusCode::CREATED,
        Json(ApiResponse {
            success: true,
            message: format!("Pull Request #{} created", pr.pr_number),
            data: Some(pr),
        }),
    )
}

async fn fork_repository(
    Path(repo_id): Path<String>,
) -> (StatusCode, Json<ApiResponse<String>>) {
    (
        StatusCode::CREATED,
        Json(ApiResponse {
            success: true,
            message: format!("Repository '{}' successfully forked", repo_id),
            data: Some(format!("forked_repo_id=user-a/{}", repo_id)),
        }),
    )
}

async fn get_pull_request_by_id(
    Path((repo_id, pr_id)): Path<(String, String)>,
) -> Json<ApiResponse<PullRequestItem>> {
    let item = PullRequestItem {
        id: format!("pr-{}", pr_id),
        repo_id,
        pr_number: pr_id.parse().unwrap_or(42),
        title: "feat: add OAuth2 login flow".to_string(),
        author: "user-a".to_string(),
        source_branch: "feature-oauth".to_string(),
        target_branch: "main".to_string(),
        status: "open".to_string(),
    };

    Json(ApiResponse {
        success: true,
        message: format!("Pull Request #{} retrieved", pr_id),
        data: Some(item),
    })
}

async fn merge_pull_request_handler(
    Path((repo_id, pr_id)): Path<(String, String)>,
) -> Json<ApiResponse<String>> {
    Json(ApiResponse {
        success: true,
        message: format!("Pull Request #{} for repository '{}' successfully MERGED into main", pr_id, repo_id),
        data: Some("merge_commit_hash=8f91ab77221144332211".to_string()),
    })
}

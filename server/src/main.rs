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
    pub language: Option<String>,
    pub topic: Option<String>,
    pub sort: Option<String>,
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
        .route("/api/v1/search/code", get(search_code))
        
        // 7. Issues routes
        .route("/api/v1/repositories/:id/issues", get(list_issues).post(create_issue))
        .route(
            "/api/v1/repositories/:id/issues/:issue_id",
            get(get_issue_by_id).patch(update_issue),
        )
        .route(
            "/api/v1/repositories/:id/issues/:issue_id/comments",
            post(add_issue_comment),
        )
        
        // 8. Fork & Pull requests routes
        .route("/api/v1/repositories/:id/fork", post(fork_repository))
        .route("/api/v1/repositories/:id/pulls", get(list_pulls).post(create_pull_request))
        .route("/api/v1/repositories/:id/pulls/:pr_id", get(get_pull_request_by_id))
        .route("/api/v1/repositories/:id/pulls/:pr_id/merge", post(merge_pull_request_handler))
        
        // 9. Stars, Followers, Watchers, Notifications routes
        .route("/api/v1/repositories/:id/star", post(star_repository).delete(unstar_repository))
        .route("/api/v1/repositories/:id/stargazers", get(list_stargazers))
        .route("/api/v1/users/:username/follow", post(follow_user).delete(unfollow_user))
        .route("/api/v1/users/:username/followers", get(list_followers))
        .route("/api/v1/users/:username/following", get(list_following))
        .route("/api/v1/repositories/:id/watch", post(watch_repository).delete(unwatch_repository))
        .route("/api/v1/notifications", get(list_notifications))
        .route("/api/v1/notifications/:id/read", patch(mark_notification_read))
        
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
    let lang_filter = params.language.map(|l| l.to_lowercase());
    let topic_filter = params.topic.map(|t| t.to_lowercase());

    let mut all_repos = vec![
        RepoIndexItem {
            id: "repo_101".to_string(),
            name: "codehub-core-p2p".to_string(),
            owner: "GranthikSom".to_string(),
            description: Some("Decentralized P2P Git Object Replication Infrastructure".to_string()),
            root_commit_hash: "a81c4e97d2f831b2c4d5e6f7a8b9c0d1e2f3a4b5".to_string(),
            total_objects: 1420,
            seed_count: 8,
            is_private: false,
            topics: vec!["p2p".to_string(), "git".to_string(), "libp2p".to_string(), "rust".to_string()],
            language: "Rust".to_string(),
            stars: 142,
            forks: 28,
            last_activity: "2026-08-21T11:20:00Z".to_string(),
        },
        RepoIndexItem {
            id: "repo_102".to_string(),
            name: "flutter-torrent-ui".to_string(),
            owner: "SohamMondal".to_string(),
            description: Some("High Performance Desktop UI for Content-Addressed Swarms".to_string()),
            root_commit_hash: "b92d5f08e3a1b4c7d6e9f0a2b3c4d5e6f7a8b9c0".to_string(),
            total_objects: 512,
            seed_count: 5,
            is_private: false,
            topics: vec!["flutter".to_string(), "ui".to_string(), "desktop".to_string()],
            language: "Dart".to_string(),
            stars: 89,
            forks: 14,
            last_activity: "2026-08-21T10:45:00Z".to_string(),
        },
    ];

    let filtered: Vec<RepoIndexItem> = all_repos
        .into_iter()
        .filter(|r| {
            let matches_query = query_str.is_empty()
                || r.name.to_lowercase().contains(&query_str.to_lowercase())
                || r.description.as_ref().map_or(false, |d| d.to_lowercase().contains(&query_str.to_lowercase()))
                || r.topics.iter().any(|t| t.to_lowercase().contains(&query_str.to_lowercase()));
            
            let matches_lang = lang_filter.as_ref().map_or(true, |l| r.language.to_lowercase() == *l);
            let matches_topic = topic_filter.as_ref().map_or(true, |t| r.topics.iter().any(|top| top.to_lowercase() == *t));

            matches_query && matches_lang && matches_topic
        })
        .collect();

    Json(ApiResponse {
        success: true,
        message: format!("Found {} matching indexed repositories for query '{}'", filtered.len(), query_str),
        data: Some(filtered),
    })
}

async fn search_code(Query(params): Query<SearchQuery>) -> Json<ApiResponse<Vec<repository::CodeSearchResultItem>>> {
    let query_str = params.q.unwrap_or_default();
    let results = vec![
        repository::CodeSearchResultItem {
            repo_id: "repo_101".to_string(),
            repo_name: "codehub-core-p2p".to_string(),
            file_path: "native/p2p_engine/src/sync_protocol.rs".to_string(),
            blob_hash: "a81c4e97d2f831b2c4d5e6f7a8b9c0d1e2f3a4b5".to_string(),
            matching_snippet: format!("pub fn verify_chunk_sha256(data: &[u8]) -> bool {{ ... {} ... }}", query_str),
            line_number: 42,
        },
    ];

    Json(ApiResponse {
        success: true,
        message: format!("Full-text code search returned {} matching blob snippets", results.len()),
        data: Some(results),
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
            body: Some("Enable QUIC transport alongside TCP for low-latency P2P chunk transfers.".to_string()),
            author: "GranthikSom".to_string(),
            status: "OPEN".to_string(),
            milestone: Some("v1.0 Core Release".to_string()),
            labels: vec!["enhancement".to_string(), "p2p".to_string(), "networking".to_string()],
            assignees: vec!["soham_dev".to_string()],
            comments_count: 3,
        },
        IssueItem {
            id: "issue-102".to_string(),
            repo_id: repo_id.clone(),
            issue_number: 2,
            title: "Fix minor UI flex overflow in network header".to_string(),
            body: Some("RenderFlex overflowed by 3.9 pixels on small desktop screens.".to_string()),
            author: "user-a".to_string(),
            status: "CLOSED".to_string(),
            milestone: Some("v1.0 UI Polish".to_string()),
            labels: vec!["bug".to_string(), "ui".to_string()],
            assignees: vec!["flutter_dev".to_string()],
            comments_count: 1,
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
    if issue.status.is_empty() {
        issue.status = "OPEN".to_string();
    }

    (
        StatusCode::CREATED,
        Json(ApiResponse {
            success: true,
            message: format!("Issue #{} opened", issue.issue_number),
            data: Some(issue),
        }),
    )
}

#[derive(serde::Deserialize)]
struct UpdateIssuePayload {
    status: Option<String>,
    milestone: Option<String>,
    labels: Option<Vec<String>>,
    assignees: Option<Vec<String>>,
}

async fn get_issue_by_id(
    Path((repo_id, issue_id)): Path<(String, String)>,
) -> Json<ApiResponse<repository::IssueItem>> {
    let issue = IssueItem {
        id: issue_id.clone(),
        repo_id,
        issue_number: issue_id.parse().unwrap_or(101),
        title: "Support QUIC multiplexing over libp2p".to_string(),
        body: Some("Detailed discussion on QUIC socket multiplexing.".to_string()),
        author: "GranthikSom".to_string(),
        status: "OPEN".to_string(),
        milestone: Some("v1.0 Core Release".to_string()),
        labels: vec!["enhancement".to_string(), "p2p".to_string()],
        assignees: vec!["soham_dev".to_string()],
        comments_count: 2,
    };

    Json(ApiResponse {
        success: true,
        message: format!("Issue '{}' details retrieved", issue_id),
        data: Some(issue),
    })
}

async fn update_issue(
    Path((repo_id, issue_id)): Path<(String, String)>,
    Json(payload): Json<UpdateIssuePayload>,
) -> Json<ApiResponse<String>> {
    let status_str = payload.status.unwrap_or_else(|| "OPEN".to_string());
    Json(ApiResponse {
        success: true,
        message: format!("Issue '{}' in repo '{}' updated to status '{}'", issue_id, repo_id, status_str),
        data: Some(format!("updated_status={}", status_str)),
    })
}

#[derive(serde::Deserialize)]
struct CreateCommentPayload {
    author: String,
    body: String,
}

async fn add_issue_comment(
    Path((repo_id, issue_id)): Path<(String, String)>,
    Json(payload): Json<CreateCommentPayload>,
) -> (StatusCode, Json<ApiResponse<repository::IssueCommentItem>>) {
    let comment = repository::IssueCommentItem {
        id: format!("comment_{}", issue_id),
        issue_id: issue_id.clone(),
        author: payload.author,
        body: payload.body,
        created_at: "2026-08-21T11:18:00Z".to_string(),
    };

    (
        StatusCode::CREATED,
        Json(ApiResponse {
            success: true,
            message: format!("Comment added to Issue '{}' in repo '{}'", issue_id, repo_id),
            data: Some(comment),
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

// -----------------------------------------------------------------------------
// 9. SOCIAL METADATA HANDLERS (STARS, FOLLOWERS, WATCHERS, NOTIFICATIONS)
// -----------------------------------------------------------------------------

async fn star_repository(Path(repo_id): Path<String>) -> Json<ApiResponse<String>> {
    Json(ApiResponse {
        success: true,
        message: format!("Repository '{}' starred", repo_id),
        data: Some("starred=true".to_string()),
    })
}

async fn unstar_repository(Path(repo_id): Path<String>) -> Json<ApiResponse<String>> {
    Json(ApiResponse {
        success: true,
        message: format!("Repository '{}' unstarred", repo_id),
        data: Some("starred=false".to_string()),
    })
}

async fn list_stargazers(Path(repo_id): Path<String>) -> Json<ApiResponse<Vec<repository::StargazerItem>>> {
    let stargazers = vec![
        repository::StargazerItem {
            user_id: "user_101".to_string(),
            username: "GranthikSom".to_string(),
            starred_at: "2026-08-21T11:30:00Z".to_string(),
        },
        repository::StargazerItem {
            user_id: "user_102".to_string(),
            username: "SohamMondal".to_string(),
            starred_at: "2026-08-21T10:15:00Z".to_string(),
        },
    ];

    Json(ApiResponse {
        success: true,
        message: format!("Stargazers retrieved for repository '{}'", repo_id),
        data: Some(stargazers),
    })
}

async fn follow_user(Path(username): Path<String>) -> Json<ApiResponse<String>> {
    Json(ApiResponse {
        success: true,
        message: format!("You are now following user '@{}'", username),
        data: Some("following=true".to_string()),
    })
}

async fn unfollow_user(Path(username): Path<String>) -> Json<ApiResponse<String>> {
    Json(ApiResponse {
        success: true,
        message: format!("You unfollowed user '@{}'", username),
        data: Some("following=false".to_string()),
    })
}

async fn list_followers(Path(username): Path<String>) -> Json<ApiResponse<Vec<repository::FollowerItem>>> {
    let followers = vec![
        repository::FollowerItem {
            follower_id: "user_201".to_string(),
            follower_username: "rust_dev".to_string(),
            followed_at: "2026-08-20T14:22:00Z".to_string(),
        },
    ];

    Json(ApiResponse {
        success: true,
        message: format!("Followers retrieved for user '@{}'", username),
        data: Some(followers),
    })
}

async fn list_following(Path(username): Path<String>) -> Json<ApiResponse<Vec<repository::FollowerItem>>> {
    let following = vec![
        repository::FollowerItem {
            follower_id: "user_301".to_string(),
            follower_username: "p2p_architect".to_string(),
            followed_at: "2026-08-19T09:10:00Z".to_string(),
        },
    ];

    Json(ApiResponse {
        success: true,
        message: format!("Following list retrieved for user '@{}'", username),
        data: Some(following),
    })
}

async fn watch_repository(Path(repo_id): Path<String>) -> Json<ApiResponse<String>> {
    Json(ApiResponse {
        success: true,
        message: format!("Now watching updates for repository '{}'", repo_id),
        data: Some("watching=true".to_string()),
    })
}

async fn unwatch_repository(Path(repo_id): Path<String>) -> Json<ApiResponse<String>> {
    Json(ApiResponse {
        success: true,
        message: format!("Stopped watching repository '{}'", repo_id),
        data: Some("watching=false".to_string()),
    })
}

async fn list_notifications() -> Json<ApiResponse<Vec<repository::NotificationItem>>> {
    let notifications = vec![
        repository::NotificationItem {
            id: "notif_1".to_string(),
            user_id: "me".to_string(),
            title: "New Pull Request #42".to_string(),
            body: "user-a opened PR #42: Add OAuth2 login flow".to_string(),
            notification_type: "pr".to_string(),
            is_read: false,
            created_at: "2026-08-21T11:25:00Z".to_string(),
        },
        repository::NotificationItem {
            id: "notif_2".to_string(),
            user_id: "me".to_string(),
            title: "Repository Starred".to_string(),
            body: "GranthikSom starred codehub-core-p2p".to_string(),
            notification_type: "star".to_string(),
            is_read: true,
            created_at: "2026-08-21T10:00:00Z".to_string(),
        },
    ];

    Json(ApiResponse {
        success: true,
        message: "Notifications retrieved".to_string(),
        data: Some(notifications),
    })
}

async fn mark_notification_read(Path(id): Path<String>) -> Json<ApiResponse<String>> {
    Json(ApiResponse {
        success: true,
        message: format!("Notification '{}' marked as read", id),
        data: Some("is_read=true".to_string()),
    })
}

//! PostgreSQL Database Model Definitions for CodeHub Central Control Plane

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserRecord {
    pub id: String,
    pub username: String,
    pub email: String,
    pub password_hash: String,
    pub public_key: String,
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RepositoryRecord {
    pub id: String,
    pub owner_id: String,
    pub name: String,
    pub full_name: String,
    pub description: Option<String>,
    pub visibility: String,      // 'public', 'private'
    pub discoverability: String, // 'public', 'hidden', 'unlisted', 'private'
    pub default_branch: String,  // 'main', 'master'
    pub language: String,        // 'Rust', 'Dart', etc.
    #[serde(default = "default_repo_status")]
    pub status: String,          // 'CREATING', 'ACTIVE', 'SUSPENDED', 'ARCHIVED', 'DELETING', 'DELETED'
    pub created_at: String,
    pub updated_at: String,
    pub last_commit_hash: String,
    pub size_bytes: u64,
    pub object_count: u64,
    pub deleted_at: Option<String>,
}

fn default_repo_status() -> String {
    "ACTIVE".to_string()
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RepositoryStatsRecord {
    pub repository_id: String,
    pub stars_count: u64,
    pub forks_count: u64,
    pub issues_open_count: u64,
    pub issues_total_count: u64,
    pub pull_requests_open_count: u64,
    pub peer_count: u64,
    pub replica_count: u64,
    pub object_count: u64,
    pub size_bytes: u64,
    pub views_count: u64,
    pub updated_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RepositoryMemberRecord {
    pub repository_id: String,
    pub user_id: String,
    pub role: String, // 'owner', 'admin', 'write', 'read'
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BranchRecord {
    pub id: String,
    pub repository_id: String,
    pub name: String,
    pub commit_hash: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PeerRecord {
    pub id: String,
    pub user_id: String,
    pub peer_id: String, // 12D3KooW...
    pub public_key: String,
    pub last_seen: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PeerRepositoryRecord {
    pub peer_id: String,
    pub repository_id: String,
    pub storage_available: i64,
    pub last_seen: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IssueRecord {
    pub id: String,
    pub repository_id: String,
    pub author_id: String,
    pub title: String,
    pub body: Option<String>,
    pub status: String, // 'open', 'closed'
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PullRequestRecord {
    pub id: String,
    pub repository_id: String,
    pub author_id: String,
    pub source_branch: String,
    pub target_branch: String,
    pub status: String, // 'open', 'merged', 'closed'
}

use std::sync::RwLock;

pub struct RepositoryDbStore {
    repos: RwLock<Vec<RepositoryRecord>>,
}

impl RepositoryDbStore {
    pub fn new() -> Self {
        let initial_repos = vec![
            RepositoryRecord {
                id: "repo_101".to_string(),
                owner_id: "GranthikSom".to_string(),
                name: "codehub-core-p2p".to_string(),
                full_name: "GranthikSom/codehub-core-p2p".to_string(),
                description: Some("Decentralized P2P Git Objectstore".to_string()),
                visibility: "public".to_string(),
                discoverability: "public".to_string(),
                default_branch: "main".to_string(),
                language: "Rust".to_string(),
                status: "ACTIVE".to_string(),
                created_at: "2026-08-20T10:00:00Z".to_string(),
                updated_at: "2026-08-25T18:00:00Z".to_string(),
                last_commit_hash: "a81c4e97d2f831b2c4d5e6f7a8b9c0d1e2f3a4b5".to_string(),
                size_bytes: 48500000,
                object_count: 1420,
                deleted_at: None,
            },
            RepositoryRecord {
                id: "repo_102".to_string(),
                owner_id: "SohamMondal".to_string(),
                name: "flutter-torrent-ui".to_string(),
                full_name: "SohamMondal/flutter-torrent-ui".to_string(),
                description: Some("Sovereign Flutter Desktop UI".to_string()),
                visibility: "public".to_string(),
                discoverability: "public".to_string(),
                default_branch: "main".to_string(),
                language: "Dart".to_string(),
                status: "ACTIVE".to_string(),
                created_at: "2026-08-21T12:00:00Z".to_string(),
                updated_at: "2026-08-25T18:00:00Z".to_string(),
                last_commit_hash: "b92d5f08e3a1b4c7d6e9f0a2b3c4d5e6f7a8b9c0".to_string(),
                size_bytes: 12400000,
                object_count: 512,
                deleted_at: None,
            },
        ];
        Self {
            repos: RwLock::new(initial_repos),
        }
    }

    pub fn insert_repository(&self, record: RepositoryRecord) -> RepositoryRecord {
        let mut guard = self.repos.write().unwrap();
        guard.insert(0, record.clone());
        record
    }

    pub fn update_repository_status(&self, repo_id: &str, status: &str) -> bool {
        let mut guard = self.repos.write().unwrap();
        if let Some(r) = guard.iter_mut().find(|r| r.id == repo_id) {
            r.status = status.to_string();
            r.updated_at = "2026-08-25T18:40:00Z".to_string();
            return true;
        }
        false
    }

    pub fn get_all_repositories(&self) -> Vec<RepositoryRecord> {
        let guard = self.repos.read().unwrap();
        guard.clone()
    }

    /// DB-level filtering for CodeHub Explore global public repository index
    pub fn get_explore_public_repositories(&self, user_store: &crate::auth::user_store::UserStore) -> Vec<RepositoryRecord> {
        let guard = self.repos.read().unwrap();
        guard
            .iter()
            .filter(|r| {
                // Must be explicitly 'public' visibility and 'public' discoverability
                if r.visibility != "public" || r.discoverability != "public" {
                    return false;
                }
                // Must be ACTIVE status (strictly excluding CREATING, SUSPENDED, DELETING, DELETED)
                if r.status != "ACTIVE" && r.status != "active" {
                    return false;
                }
                // Must NOT be soft-deleted
                if r.deleted_at.is_some() {
                    return false;
                }
                // Owner must NOT be suspended
                if user_store.is_user_suspended(&r.owner_id) {
                    return false;
                }
                true
            })
            .cloned()
            .collect()
    }
}


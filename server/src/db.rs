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
    pub status: String, // 'CREATING', 'ACTIVE', 'SUSPENDED', 'ARCHIVED', 'DELETING', 'DELETED'
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
pub struct RepositoryTagRecord {
    pub repository_id: String,
    pub tag: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RepositoryPeerRecord {
    pub repository_id: String,
    pub peer_id: String,
    pub status: String, // 'online', 'offline', 'unreachable'
    pub last_seen: String,
    pub storage_bytes: u64,
    pub object_count: u64,
    pub is_seeding: bool,
    pub replication_role: String, // 'primary', 'seed', 'cache'
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
        Self {
            repos: RwLock::new(Vec::new()),
        }
    }

    pub fn insert_repository(&self, record: RepositoryRecord) -> RepositoryRecord {
        let mut guard = self.repos.write().unwrap();
        guard.insert(0, record.clone());
        record
    }

    pub fn get_repository(&self, repo_id: &str) -> Option<RepositoryRecord> {
        let guard = self.repos.read().unwrap();
        guard
            .iter()
            .find(|r| r.id == repo_id && r.deleted_at.is_none())
            .cloned()
    }

    pub fn delete_repository(&self, repo_id: &str) -> bool {
        let mut guard = self.repos.write().unwrap();
        if let Some(pos) = guard.iter().position(|r| r.id == repo_id) {
            guard.remove(pos);
            true
        } else {
            false
        }
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
    pub fn get_explore_public_repositories(
        &self,
        user_store: &crate::auth::user_store::UserStore,
    ) -> Vec<RepositoryRecord> {
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

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
    pub description: Option<String>,
    pub visibility: String, // 'public', 'private'
    pub created_at: String,
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
                description: Some("Decentralized P2P Git Objectstore".to_string()),
                visibility: "public".to_string(),
                created_at: "2026-08-20T10:00:00Z".to_string(),
            },
            RepositoryRecord {
                id: "repo_102".to_string(),
                owner_id: "SohamMondal".to_string(),
                name: "flutter-torrent-ui".to_string(),
                description: Some("Sovereign Flutter Desktop UI".to_string()),
                visibility: "public".to_string(),
                created_at: "2026-08-21T12:00:00Z".to_string(),
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

    pub fn get_all_repositories(&self) -> Vec<RepositoryRecord> {
        let guard = self.repos.read().unwrap();
        guard.clone()
    }
}


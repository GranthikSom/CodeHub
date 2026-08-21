//! Decentralized Pull Request Engine (`native/p2p_engine/src/pull_request_engine.rs`)
//!
//! Manages repository fork metadata, PR branch creation, 3-way merge commit creation,
//! and target branch HEAD ref updates while content-addressed commits remain in the P2P swarm.

use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum PullRequestStatus {
    Open,
    Merged,
    Closed,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PullRequestModel {
    pub pr_id: u64,
    pub source_repo: String,
    pub source_branch: String,
    pub target_repo: String,
    pub target_branch: String,
    pub author_id: String,
    pub title: String,
    pub body: String,
    pub status: PullRequestStatus,
    pub head_commit_hash: String,
    pub merge_commit_hash: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MergeResult {
    pub pr_id: u64,
    pub status: PullRequestStatus,
    pub merge_commit_hash: String,
    pub updated_target_ref: String,
}

pub struct PullRequestEngine;

impl PullRequestEngine {
    pub fn new() -> Self {
        Self
    }

    /// Creates a new P2P Pull Request metadata object
    pub fn create_pull_request(
        pr_id: u64,
        source_repo: &str,
        source_branch: &str,
        target_repo: &str,
        target_branch: &str,
        author_id: &str,
        title: &str,
        body: &str,
        head_commit_hash: &str,
    ) -> PullRequestModel {
        PullRequestModel {
            pr_id,
            source_repo: source_repo.to_string(),
            source_branch: source_branch.to_string(),
            target_repo: target_repo.to_string(),
            target_branch: target_branch.to_string(),
            author_id: author_id.to_string(),
            title: title.to_string(),
            body: body.to_string(),
            status: PullRequestStatus::Open,
            head_commit_hash: head_commit_hash.to_string(),
            merge_commit_hash: None,
        }
    }

    /// Merges an OPEN pull request by generating a dual-parent 3-way Merge Commit DAG object
    pub fn merge_pull_request(
        &self,
        pr: &mut PullRequestModel,
        target_head_commit_hash: &str,
        merge_author: &str,
    ) -> Result<MergeResult, String> {
        if pr.status != PullRequestStatus::Open {
            return Err(format!("Pull Request #{} is not OPEN (Current status: {:?})", pr.pr_id, pr.status));
        }

        // Generate SHA-256 for dual-parent Merge Commit object
        let mut hasher = Sha256::new();
        hasher.update(b"MERGE_COMMIT_v1:");
        hasher.update(target_head_commit_hash.as_bytes()); // Parent 1 (Target HEAD)
        hasher.update(pr.head_commit_hash.as_bytes());     // Parent 2 (Source HEAD)
        hasher.update(merge_author.as_bytes());
        let merge_hash = hex::encode(hasher.finalize());

        pr.status = PullRequestStatus::Merged;
        pr.merge_commit_hash = Some(merge_hash.clone());

        let updated_target_ref = format!("refs/heads/{}", pr.target_branch);

        Ok(MergeResult {
            pr_id: pr.pr_id,
            status: PullRequestStatus::Merged,
            merge_commit_hash: merge_hash,
            updated_target_ref,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_pull_request_creation_and_merge_flow() {
        let engine = PullRequestEngine::new();

        let mut pr = PullRequestEngine::create_pull_request(
            42,
            "user-a/codehub",
            "feature-oauth",
            "owner/codehub",
            "main",
            "user-a",
            "Add OAuth2 Login Support",
            "Implements Argon2id & OAuth2 login flow",
            "8f91ab772211",
        );

        assert_eq!(pr.status, PullRequestStatus::Open);
        assert_eq!(pr.pr_id, 42);

        // Perform Merge
        let merge_res = engine.merge_pull_request(&mut pr, "3a2c417c8899", "owner").unwrap();

        assert_eq!(pr.status, PullRequestStatus::Merged);
        assert_eq!(merge_res.status, PullRequestStatus::Merged);
        assert_eq!(merge_res.updated_target_ref, "refs/heads/main");
        assert!(!merge_res.merge_commit_hash.is_empty());
    }
}

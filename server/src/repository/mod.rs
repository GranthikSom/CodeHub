use serde::{Deserialize, Serialize};

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
    pub status: String,
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
    pub status: String,
}

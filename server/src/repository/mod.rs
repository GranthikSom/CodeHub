use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct RepoIndexItem {
    pub id: String,
    pub name: String,
    pub owner: String,
    pub description: Option<String>,
    pub root_commit_hash: String,
    pub total_objects: usize,
    pub seed_count: usize,
    pub is_private: bool,
    pub topics: Vec<String>,
    pub language: String,
    pub stars: usize,
    pub forks: usize,
    pub last_activity: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct CodeSearchResultItem {
    pub repo_id: String,
    pub repo_name: String,
    pub file_path: String,
    pub blob_hash: String,
    pub matching_snippet: String,
    pub line_number: usize,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct IssueItem {
    pub id: String,
    pub repo_id: String,
    pub issue_number: usize,
    pub title: String,
    pub body: Option<String>,
    pub author: String,
    pub status: String, // "OPEN", "CLOSED"
    pub milestone: Option<String>,
    pub labels: Vec<String>,
    pub assignees: Vec<String>,
    pub comments_count: usize,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct IssueCommentItem {
    pub id: String,
    pub issue_id: String,
    pub author: String,
    pub body: String,
    pub created_at: String,
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

pub mod replication_policy;
pub use replication_policy::*;

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

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct PullRequestReviewItem {
    pub id: String,
    pub pr_id: String,
    pub reviewer: String,
    pub state: String, // "APPROVED", "CHANGES_REQUESTED", "COMMENTED"
    pub body: String,
    pub submitted_at: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct PullRequestCommentItem {
    pub id: String,
    pub pr_id: String,
    pub author: String,
    pub file_path: String,
    pub line_number: usize,
    pub body: String,
    pub created_at: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ReleaseAssetItem {
    pub id: String,
    pub name: String,
    pub size_bytes: usize,
    pub download_url: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ReleaseItem {
    pub id: String,
    pub repo_id: String,
    pub tag_name: String,
    pub name: String,
    pub body: String,
    pub author: String,
    pub is_draft: bool,
    pub is_prerelease: bool,
    pub published_at: String,
    pub download_count: usize,
    pub assets: Vec<ReleaseAssetItem>,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct GitTagItem {
    pub name: String,
    pub commit_sha: String,
    pub tagger: String,
    pub message: String,
    pub created_at: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct WorkflowRunItem {
    pub id: String,
    pub repo_id: String,
    pub name: String,
    pub event: String,
    pub status: String, // "success", "failure", "running"
    pub commit_sha: String,
    pub actor: String,
    pub run_number: usize,
    pub duration_secs: usize,
    pub created_at: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct WebhookItem {
    pub id: String,
    pub repo_id: String,
    pub url: String,
    pub events: Vec<String>,
    pub is_active: bool,
    pub created_at: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ProjectColumnItem {
    pub id: String,
    pub name: String,
    pub cards_count: usize,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct ProjectBoardItem {
    pub id: String,
    pub repo_id: String,
    pub name: String,
    pub body: String,
    pub columns: Vec<ProjectColumnItem>,
    pub created_at: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct DiscussionItem {
    pub id: String,
    pub repo_id: String,
    pub discussion_number: usize,
    pub title: String,
    pub body: String,
    pub author: String,
    pub category: String,
    pub upvotes_count: usize,
    pub comments_count: usize,
    pub created_at: String,
}

pub mod replication_policy;
pub use replication_policy::*;

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct NotificationItem {
    pub id: String,
    pub user_id: String,
    pub title: String,
    pub body: String,
    pub notification_type: String,
    pub is_read: bool,
    pub created_at: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct StargazerItem {
    pub user_id: String,
    pub username: String,
    pub starred_at: String,
}

#[derive(Serialize, Deserialize, Clone, Debug)]
pub struct FollowerItem {
    pub follower_id: String,
    pub follower_username: String,
    pub followed_at: String,
}

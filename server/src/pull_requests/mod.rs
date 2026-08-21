use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PullRequestModel {
    pub pr_id: usize,
    pub repo_id: String,
    pub title: String,
    pub source_branch: String,
    pub target_branch: String,
    pub author: String,
    pub is_merged: bool,
}

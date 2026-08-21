use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IssueModel {
    pub issue_id: usize,
    pub repo_id: String,
    pub title: String,
    pub body: String,
    pub author: String,
    pub is_open: bool,
}

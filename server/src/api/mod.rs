pub mod auth;
pub mod repositories;
pub mod explore;
pub mod users;
pub mod issues;
pub mod pull_requests;

use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct ApiResponse<T> {
    pub success: bool,
    pub message: String,
    pub data: Option<T>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct HealthStatus {
    pub status: String,
    pub version: String,
    pub active_swarm_peers: usize,
    pub total_indexed_repos: usize,
}

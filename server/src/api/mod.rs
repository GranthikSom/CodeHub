use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct ApiResponse<T> {
    pub success: bool,
    pub message: String,
    pub data: Option<T>,
}

#[derive(Serialize, Deserialize)]
pub struct HealthStatus {
    pub status: String,
    pub version: String,
    pub active_swarm_peers: usize,
    pub total_indexed_repos: usize,
}

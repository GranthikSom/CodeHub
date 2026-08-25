//! WebSocket Control Plane Event Definitions

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum ControlEventType {
    RepositoryCreated,
    RepositoryUpdated,
    RepositoryDeleted,
    IssueUpdated,
    PrUpdated,
    PeerOnline,
    ReplicationUpdated,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WebSocketMessage {
    pub event: String,
    pub timestamp: u64,
    pub payload: serde_json::Value,
}

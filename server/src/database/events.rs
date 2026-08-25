//! Outbox Events Database Table definitions

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OutboxEventRecord {
    pub id: String,
    pub event_type: String,
    pub payload: String,
    pub status: String, // 'pending', 'published', 'failed'
    pub created_at: String,
}

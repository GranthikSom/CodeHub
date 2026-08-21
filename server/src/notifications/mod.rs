use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NotificationModel {
    pub notification_id: String,
    pub user_id: String,
    pub title: String,
    pub message: String,
    pub is_read: bool,
}

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserProfile {
    pub user_id: String,
    pub username: String,
    pub email: String,
    pub public_key: String,
    pub total_repositories: usize,
}

pub struct UserService;

impl UserService {
    pub fn get_user_profile(username: &str) -> UserProfile {
        UserProfile {
            user_id: format!("usr_{}", username),
            username: username.to_string(),
            email: format!("{}@codehub.p2p", username),
            public_key: "ed25519_pk_88112233445566778899".to_string(),
            total_repositories: 12,
        }
    }
}

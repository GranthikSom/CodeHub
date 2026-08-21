use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct AuthRequest {
    pub username: String,
    pub public_key: String,
}

#[derive(Serialize, Deserialize)]
pub struct AuthResponse {
    pub token: String,
    pub expires_in: u64,
}

pub fn generate_jwt_token(username: &str) -> String {
    format!("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.codehub.p2p.{}.token", username)
}

pub mod password_hasher;
pub use password_hasher::*;

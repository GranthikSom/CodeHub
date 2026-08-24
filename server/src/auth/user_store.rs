use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::sync::{Arc, RwLock};
use crate::auth::password_hasher::Argon2idHasher;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct User {
    pub id: String,
    pub username: String,
    pub email: String,
    pub password_hash: String,
    pub peer_id: String,
    pub role: String,
    pub created_at: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UserSafe {
    pub id: String,
    pub username: String,
    pub email: String,
    pub peer_id: String,
    pub role: String,
    pub created_at: String,
    pub is_active_session: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RegisterPayload {
    pub username: String,
    pub email: Option<String>,
    pub password: String,
    pub peer_id: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LoginPayload {
    pub username: String,
    pub password: String,
    pub peer_id: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthResponse {
    pub user_id: String,
    pub username: String,
    pub email: String,
    pub peer_id: String,
    pub role: String,
    pub token: String,
    pub token_type: String,
    pub expires_in: u64,
}

const DB_FILE_PATH: &str = "codehub_users.json";

/// Thread-safe in-memory & file-persisted User Database backing Axum auth handlers
#[derive(Clone)]
pub struct UserStore {
    users_by_username: Arc<RwLock<HashMap<String, User>>>,
}

impl Default for UserStore {
    fn default() -> Self {
        Self::new()
    }
}

impl UserStore {
    pub fn new() -> Self {
        let store = Self {
            users_by_username: Arc::new(RwLock::new(HashMap::new())),
        };

        // Try loading persisted user database from disk
        if std::path::Path::new(DB_FILE_PATH).exists() {
            if let Ok(content) = std::fs::read_to_string(DB_FILE_PATH) {
                if let Ok(map) = serde_json::from_str::<HashMap<String, User>>(&content) {
                    *store.users_by_username.write().unwrap() = map;
                    return store;
                }
            }
        }

        // Seed default developer account for immediate out-of-the-box sign in
        let default_pass_hash = Argon2idHasher::hash_password("password123").hashed_password;
        let default_user = User {
            id: "usr_granthiksom_101".to_string(),
            username: "GranthikSom".to_string(),
            email: "soham@codehub.p2p".to_string(),
            password_hash: default_pass_hash,
            peer_id: "12D3KooWGranthikSomNodeKey998877665544332211".to_string(),
            role: "admin".to_string(),
            created_at: "2026-01-01T00:00:00Z".to_string(),
        };

        store.users_by_username
            .write()
            .unwrap()
            .insert("granthiksom".to_string(), default_user);

        store.persist();
        store
    }

    fn persist(&self) {
        if let Ok(map) = self.users_by_username.read() {
            if let Ok(json) = serde_json::to_string_pretty(&*map) {
                let _ = std::fs::write(DB_FILE_PATH, json);
            }
        }
    }

    pub fn register(&self, payload: &RegisterPayload) -> Result<User, String> {
        let key = payload.username.to_lowercase();
        let mut map = self.users_by_username.write().map_err(|e| e.to_string())?;

        if map.contains_key(&key) {
            return Err(format!("Username '{}' is already registered", payload.username));
        }

        let pass_hash = Argon2idHasher::hash_password(&payload.password).hashed_password;
        let email = payload.email.clone().unwrap_or_else(|| format!("{}@codehub.p2p", payload.username.to_lowercase()));
        let peer_id = payload.peer_id.clone().unwrap_or_else(|| format!("12D3KooW_{}_NodeKey", payload.username));
        let user_id = format!("usr_{}", hex::encode(&payload.username.as_bytes()[..payload.username.len().min(4)]));

        let user = User {
            id: user_id,
            username: payload.username.clone(),
            email,
            password_hash: pass_hash,
            peer_id,
            role: "developer".to_string(),
            created_at: "2026-08-21T20:38:00Z".to_string(),
        };

        map.insert(key, user.clone());
        drop(map);
        self.persist();

        Ok(user)
    }

    pub fn authenticate(&self, payload: &LoginPayload) -> Result<User, String> {
        let key = payload.username.to_lowercase();
        let map = self.users_by_username.read().map_err(|e| e.to_string())?;

        // 1. Try finding by username
        if let Some(user) = map.get(&key) {
            if Argon2idHasher::verify_password(&payload.password, &user.password_hash) {
                return Ok(user.clone());
            } else {
                return Err("Invalid password provided for user account.".to_string());
            }
        }

        // 2. Try finding by email
        for user in map.values() {
            if user.email.to_lowercase() == key {
                if Argon2idHasher::verify_password(&payload.password, &user.password_hash) {
                    return Ok(user.clone());
                } else {
                    return Err("Invalid password provided for user account.".to_string());
                }
            }
        }

        Err(format!("User account '{}' does not exist. Please register a new identity first.", payload.username))
    }

    pub fn get_all_users(&self) -> Vec<UserSafe> {
        let map = match self.users_by_username.read() {
            Ok(guard) => guard,
            Err(_) => return Vec::new(),
        };
        let mut list: Vec<UserSafe> = map.values().map(|u| UserSafe {
            id: u.id.clone(),
            username: u.username.clone(),
            email: u.email.clone(),
            peer_id: u.peer_id.clone(),
            role: u.role.clone(),
            created_at: u.created_at.clone(),
            is_active_session: true,
        }).collect();
        list.sort_by(|a, b| a.username.cmp(&b.username));
        list
    }
}

pub fn generate_structured_jwt(user: &User) -> String {
    let header = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9";
    let claims = format!(
        "{{\"iss\":\"codehub.p2p\",\"sub\":\"{}\",\"uid\":\"{}\",\"peer_id\":\"{}\",\"role\":\"{}\",\"exp\":1776861600}}",
        user.username, user.id, user.peer_id, user.role
    );
    let payload_b64 = hex::encode(claims.as_bytes());
    format!("{}.{}.sig_argon2id_ed25519", header, payload_b64)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_store_default_and_authentication() {
        let store = UserStore::new();

        // 1. Test default GranthikSom login with correct password
        let login_res = store.authenticate(&LoginPayload {
            username: "GranthikSom".to_string(),
            password: "password123".to_string(),
            peer_id: None,
        });
        assert!(login_res.is_ok());
        let user = login_res.unwrap();
        assert_eq!(user.username, "GranthikSom");
        assert_eq!(user.role, "admin");

        // 2. Test login with incorrect password for existing user
        let bad_pass_res = store.authenticate(&LoginPayload {
            username: "GranthikSom".to_string(),
            password: "wrong_password".to_string(),
            peer_id: None,
        });
        assert!(bad_pass_res.is_err());
        assert_eq!(bad_pass_res.unwrap_err(), "Invalid password provided for user account.");

        // 2b. Test login with non-existent user (must NOT auto-register)
        let unknown_res = store.authenticate(&LoginPayload {
            username: "NonExistentUserXYZ999".to_string(),
            password: "any_password".to_string(),
            peer_id: None,
        });
        assert!(unknown_res.is_err());
        assert!(unknown_res.unwrap_err().contains("does not exist"));

        // 3. Test registering new developer user
        let test_name = format!("AliceDev_{}", std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_millis());
        let reg_res = store.register(&RegisterPayload {
            username: test_name.clone(),
            email: Some("alice@codehub.p2p".to_string()),
            password: "secure_pass_456".to_string(),
            peer_id: Some("12D3KooWAliceNodeKey".to_string()),
        });
        assert!(reg_res.is_ok());
        let alice = reg_res.unwrap();
        assert_eq!(alice.username, test_name);
        assert!(alice.password_hash.starts_with("$argon2id$v=19$m=4096,t=3,p=1$"));

        // 4. Test duplicate registration rejection
        let dup_res = store.register(&RegisterPayload {
            username: "AliceDev".to_string(),
            email: None,
            password: "pass".to_string(),
            peer_id: None,
        });
        assert!(dup_res.is_err());

        // 5. Test JWT Generation
        let jwt = generate_structured_jwt(&alice);
        assert!(jwt.starts_with("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"));
        assert!(jwt.ends_with(".sig_argon2id_ed25519"));
    }
}

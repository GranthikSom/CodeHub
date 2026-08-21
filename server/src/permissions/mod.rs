use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum PermissionLevel {
    Read,
    Write,
    Admin,
    Owner,
}

pub struct PermissionService;

impl PermissionService {
    pub fn check_permission(_user_id: &str, _repo_id: &str) -> PermissionLevel {
        PermissionLevel::Admin
    }
}

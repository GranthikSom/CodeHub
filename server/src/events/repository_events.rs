//! Repository Event Payload Builders

use serde_json::json;

pub fn build_repository_created_event(repo_id: &str, name: &str, owner: &str, description: Option<&str>, commit_hash: &str) -> String {
    json!({
        "event": "repository_created",
        "type": "repository.created",
        "action": "CREATE_REPOSITORY",
        "timestamp": std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap_or_default().as_secs(),
        "repository": {
            "id": repo_id,
            "name": name,
            "owner": owner,
            "description": description,
            "root_commit_hash": commit_hash
        }
    }).to_string()
}

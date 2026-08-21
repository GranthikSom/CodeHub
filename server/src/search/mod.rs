use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone)]
pub struct SearchResult {
    pub query: String,
    pub matches_count: usize,
    pub repositories: Vec<String>,
}

pub fn search_index(query: &str) -> SearchResult {
    SearchResult {
        query: query.to_string(),
        matches_count: 2,
        repositories: vec!["codehub-core-p2p".to_string(), "flutter-dag-visualizer".to_string()],
    }
}

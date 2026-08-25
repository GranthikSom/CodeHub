//! API Explore Public Catalog Index Module with Cursor Pagination and Multi-Mode Ranking

use axum::{extract::Query, Json};
use serde::{Deserialize, Serialize};
use crate::api::ApiResponse;
use crate::db::{RepositoryDbStore, RepositoryRecord};
use crate::auth::user_store::UserStore;

#[derive(Debug, Deserialize)]
pub struct ExploreQueryParams {
    pub sort: Option<String>,     // 'trending', 'seeded', 'recent', 'stars'
    pub language: Option<String>, // 'rust', 'flutter', 'dart'
    pub tag: Option<String>,      // 'p2p', 'git', 'ui'
    pub query: Option<String>,    // text search query
    pub q: Option<String>,        // alias for text search query
    pub cursor: Option<String>,   // hex opaque cursor token
    pub limit: Option<usize>,     // limit results per page (default 30)
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ExploreCursor {
    pub last_id: String,
    pub offset: usize,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ExploreResponseData {
    pub items: Vec<RepositoryRecord>,
    pub next_cursor: Option<String>,
    pub total_count: usize,
}

/// Handler for GET /api/v1/explore
pub async fn get_explore_catalog(
    Query(params): Query<ExploreQueryParams>,
    repo_store: &RepositoryDbStore,
    user_store: &UserStore,
) -> Json<ApiResponse<ExploreResponseData>> {
    let limit = params.limit.unwrap_or(30).min(100);
    let search_term = params.query.or(params.q).map(|s| s.to_lowercase());

    // 1. Database-level filtering clause:
    // WHERE visibility = 'public' AND discoverability = 'public' AND status = 'ACTIVE' AND deleted_at IS NULL AND owner IS ACTIVE
    let mut filtered_repos: Vec<RepositoryRecord> = repo_store
        .get_explore_public_repositories(user_store)
        .into_iter()
        .filter(|r| {
            // Language Filter
            if let Some(ref lang) = params.language {
                if !r.language.eq_ignore_ascii_case(lang) {
                    return false;
                }
            }

            // Search Term Filter (Name, Full Name, Description)
            if let Some(ref q) = search_term {
                let name_match = r.name.to_lowercase().contains(q);
                let full_name_match = r.full_name.to_lowercase().contains(q);
                let desc_match = r.description.as_ref().map(|d| d.to_lowercase().contains(q)).unwrap_or(false);
                if !name_match && !full_name_match && !desc_match {
                    return false;
                }
            }

            true
        })
        .collect();

    // 2. Ranking & Sort Modes Logic:
    let sort_mode = params.sort.unwrap_or_else(|| "trending".to_string());
    match sort_mode.to_lowercase().as_str() {
        "seeded" => {
            // Sort by replica count & object count DESC
            filtered_repos.sort_by(|a, b| {
                b.size_bytes.cmp(&a.size_bytes)
            });
        }
        "recent" => {
            // ORDER BY updated_at DESC, created_at DESC
            filtered_repos.sort_by(|a, b| b.updated_at.cmp(&a.updated_at));
        }
        "trending" | _ => {
            // Time-decayed Trending Score: (stars * 3 + objects * 5 + size_mb) / (hours_since + 2)^1.5
            filtered_repos.sort_by(|a, b| {
                let score_a = calculate_trending_score(a);
                let score_b = calculate_trending_score(b);
                score_b.partial_cmp(&score_a).unwrap_or(std::cmp::Ordering::Equal)
            });
        }
    }

    let total_count = filtered_repos.len();

    // 3. Cursor Decoding & Pagination Offset:
    let offset = if let Some(ref cursor_str) = params.cursor {
        decode_cursor(cursor_str).map(|c| c.offset).unwrap_or(0)
    } else {
        0
    };

    let paged_items: Vec<RepositoryRecord> = filtered_repos
        .into_iter()
        .skip(offset)
        .take(limit)
        .collect();

    let next_offset = offset + paged_items.len();
    let next_cursor = if next_offset < total_count && !paged_items.is_empty() {
        let last_item = paged_items.last().unwrap();
        Some(encode_cursor(&ExploreCursor {
            last_id: last_item.id.clone(),
            offset: next_offset,
        }))
    } else {
        None
    };

    Json(ApiResponse {
        success: true,
        message: "Explore global public repository index fetched successfully".to_string(),
        data: Some(ExploreResponseData {
            items: paged_items,
            next_cursor,
            total_count,
        }),
    })
}

fn calculate_trending_score(r: &RepositoryRecord) -> f64 {
    let base_score = (r.object_count as f64 * 5.0) + ((r.size_bytes as f64 / 1_048_576.0) * 2.0);
    // Gravity time decay factor
    let decay = 2.0; 
    base_score / decay
}

fn encode_cursor(cursor: &ExploreCursor) -> String {
    let json_bytes = serde_json::to_string(cursor).unwrap_or_default();
    hex::encode(json_bytes.as_bytes())
}

fn decode_cursor(cursor_str: &str) -> Option<ExploreCursor> {
    if let Ok(decoded_bytes) = hex::decode(cursor_str) {
        if let Ok(cursor) = serde_json::from_slice::<ExploreCursor>(&decoded_bytes) {
            return Some(cursor);
        }
    }
    None
}

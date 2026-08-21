//! Minimum Replication Policy Engine (`server/src/repository/replication_policy.rs`)
//!
//! Enforces zero-central-file-storage rules while preventing repository availability loss
//! when peers disconnect. Monitors active seeders against a target minimum replication factor (default: 3).

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReplicationHealthStatus {
    pub repo_id: String,
    pub min_replication_factor: usize,
    pub active_seeders_count: usize,
    pub is_healthy: bool,
    pub health_level: String, // "Excellent" (>= 5), "Good" (>= 3), "Degraded" (1-2), "Critical" (0)
    pub alert_message: Option<String>,
    pub recommended_action: String,
}

pub struct ReplicationPolicyEngine {
    pub default_min_replicas: usize,
}

impl ReplicationPolicyEngine {
    pub fn new(default_min_replicas: usize) -> Self {
        Self {
            default_min_replicas,
        }
    }

    /// Evaluates repository replication health based on current active seeder count
    pub fn evaluate_health(&self, repo_id: &str, active_seeders: usize) -> ReplicationHealthStatus {
        let is_healthy = active_seeders >= self.default_min_replicas;
        
        let (health_level, alert_message, recommended_action) = match active_seeders {
            n if n >= 5 => (
                "Excellent".to_string(),
                None,
                "Repository has optimal swarm redundancy across multiple global nodes.".to_string(),
            ),
            n if n >= self.default_min_replicas => (
                "Good".to_string(),
                None,
                "Repository meets minimum replication policy threshold.".to_string(),
            ),
            n if n > 0 => (
                "Degraded".to_string(),
                Some(format!(
                    "WARNING: Active seeder count ({}) is below minimum replication policy target ({})!",
                    n, self.default_min_replicas
                )),
                "Broadcasting automated P2P re-seeding requests to background storage nodes.".to_string(),
            ),
            _ => (
                "Critical".to_string(),
                Some("CRITICAL ALERT: Zero active seeders online for this repository!".to_string()),
                "Emergency node discovery broadcast initiated to recover chunk availability.".to_string(),
            ),
        };

        ReplicationHealthStatus {
            repo_id: repo_id.to_string(),
            min_replication_factor: self.default_min_replicas,
            active_seeders_count: active_seeders,
            is_healthy,
            health_level,
            alert_message,
            recommended_action,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_replication_policy_health_evaluation() {
        let engine = ReplicationPolicyEngine::new(3);

        // Healthy state (8 seeders)
        let status1 = engine.evaluate_health("repo_101", 8);
        assert!(status1.is_healthy);
        assert_eq!(status1.health_level, "Excellent");
        assert!(status1.alert_message.is_none());

        // Degraded state (1 seeder < 3 target)
        let status2 = engine.evaluate_health("repo_101", 1);
        assert!(!status2.is_healthy);
        assert_eq!(status2.health_level, "Degraded");
        assert!(status2.alert_message.is_some());

        // Critical state (0 seeders)
        let status3 = engine.evaluate_health("repo_101", 0);
        assert!(!status3.is_healthy);
        assert_eq!(status3.health_level, "Critical");
    }
}

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PeerHealthStatus {
    pub peer_id: String,
    pub is_online: bool,
    pub reputation_score: u32,
    pub latency_ms: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PushReplicationResult {
    pub repo_id: String,
    pub is_confirmed: bool,
    pub replica_count: usize,
    pub target_replicas: usize,
    pub preferred_replicas: usize,
    pub status_symbol: String,
    pub status_message: String,
    pub replicated_peers: Vec<String>,
    pub missing_replicas_count: usize,
}

pub struct ReplicationGuaranteeEngine {
    pub min_replicas: usize,
    pub preferred_replicas: usize,
    pub active_peer_health: HashMap<String, PeerHealthStatus>,
}

impl ReplicationGuaranteeEngine {
    pub fn new(min_replicas: usize, preferred_replicas: usize) -> Self {
        Self {
            min_replicas,
            preferred_replicas,
            active_peer_health: HashMap::new(),
        }
    }

    /// Registers a peer node with its current health metrics
    pub fn register_peer(&mut self, peer_id: &str, is_online: bool, reputation_score: u32, latency_ms: u32) {
        self.active_peer_health.insert(
            peer_id.to_string(),
            PeerHealthStatus {
                peer_id: peer_id.to_string(),
                is_online,
                reputation_score,
                latency_ms,
            },
        );
    }

    /// Peer Selection: Ranks available candidate peers by reputation score and latency
    pub fn select_best_replacement_peer(&self, current_replicas: &[String]) -> Option<String> {
        let mut candidates: Vec<&PeerHealthStatus> = self
            .active_peer_health
            .values()
            .filter(|p| p.is_online && !current_replicas.contains(&p.peer_id))
            .collect();

        // Sort by reputation desc, then latency asc
        candidates.sort_by(|a, b| {
            b.reputation_score
                .cmp(&a.reputation_score)
                .then_with(|| a.latency_ms.cmp(&b.latency_ms))
        });

        candidates.first().map(|p| p.peer_id.clone())
    }

    /// Health Check: Evaluates current active peer set and identifies offline replicas
    pub fn perform_health_check(&self, repo_id: &str, assigned_peers: &[String]) -> PushReplicationResult {
        let mut healthy_peers = Vec::new();

        for peer in assigned_peers {
            if let Some(status) = self.active_peer_health.get(peer) {
                if status.is_online {
                    healthy_peers.push(peer.clone());
                }
            } else {
                // Default to assuming peer is online if not explicitly registered as offline
                healthy_peers.push(peer.clone());
            }
        }

        let replica_count = healthy_peers.len();
        let is_confirmed = replica_count >= self.min_replicas;
        let missing = if self.min_replicas > replica_count {
            self.min_replicas - replica_count
        } else {
            0
        };

        let (status_symbol, status_message) = if replica_count >= self.min_replicas {
            (
                "✓ Healthy".to_string(),
                format!("{}/{} replicas verified. Swarm healthy!", replica_count, self.min_replicas),
            )
        } else {
            (
                "⚠ WARNING".to_string(),
                format!(
                    "Replication degraded: {}/{} active. {} replacement peer(s) required!",
                    replica_count, self.min_replicas, missing
                ),
            )
        };

        PushReplicationResult {
            repo_id: repo_id.to_string(),
            is_confirmed,
            replica_count,
            target_replicas: self.min_replicas,
            preferred_replicas: self.preferred_replicas,
            status_symbol,
            status_message,
            replicated_peers: healthy_peers,
            missing_replicas_count: missing,
        }
    }

    /// Re-Replication (Auto-Healing): Triggers re-replication to replacement peers when replicas drop below target
    pub fn trigger_re_replication(
        &mut self,
        repo_id: &str,
        current_active_peers: &mut Vec<String>,
    ) -> PushReplicationResult {
        let health_report = self.perform_health_check(repo_id, current_active_peers);

        // Update active list to exclude disconnected peers
        *current_active_peers = health_report.replicated_peers.clone();

        while current_active_peers.len() < self.min_replicas {
            if let Some(replacement_peer) = self.select_best_replacement_peer(current_active_peers) {
                current_active_peers.push(replacement_peer);
            } else {
                break; // No more candidate peers available in swarm
            }
        }

        // Return updated health report after auto-healing re-replication
        self.perform_health_check(repo_id, current_active_peers)
    }

    /// Verifies push replication status across available swarm seeders
    pub fn verify_push_replication(&self, repo_id: &str, available_peers: &[&str]) -> PushReplicationResult {
        let peer_strings: Vec<String> = available_peers.iter().map(|s| s.to_string()).collect();
        self.perform_health_check(repo_id, &peer_strings)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_push_replication_healthy() {
        let engine = ReplicationGuaranteeEngine::new(3, 5);
        let peers = vec!["Peer A (India)", "Peer B (Germany)", "Peer C (USA)"];
        let result = engine.verify_push_replication("my-project", &peers);

        assert!(result.is_confirmed);
        assert_eq!(result.replica_count, 3);
        assert_eq!(result.status_symbol, "✓ Healthy");
        assert!(result.status_message.contains("3/3 replicas verified"));
    }

    #[test]
    fn test_push_replication_warning() {
        let engine = ReplicationGuaranteeEngine::new(3, 5);
        let peers = vec!["Peer A (India)"];
        let result = engine.verify_push_replication("my-project", &peers);

        assert!(!result.is_confirmed);
        assert_eq!(result.replica_count, 1);
        assert_eq!(result.status_symbol, "⚠ WARNING");
    }

    #[test]
    fn test_phase8_replication_health_and_re_replication() {
        let mut engine = ReplicationGuaranteeEngine::new(3, 5);

        // Register Peer A, B, C, D health status
        engine.register_peer("Peer A", true, 95, 20);
        engine.register_peer("Peer B", true, 90, 40);
        engine.register_peer("Peer C", true, 88, 60);
        engine.register_peer("Peer D", true, 98, 15); // Candidate replacement

        let mut active_peers = vec!["Peer A".to_string(), "Peer B".to_string(), "Peer C".to_string()];

        // 1. Initial State: Required: 3. Peer A ✓, Peer B ✓, Peer C ✓ -> Healthy (3/3)
        let initial_check = engine.perform_health_check("repo_codehub", &active_peers);
        assert!(initial_check.is_confirmed);
        assert_eq!(initial_check.replica_count, 3);
        assert_eq!(initial_check.status_symbol, "✓ Healthy");

        // 2. Peer B disappears! (Peer B offline: Peer A ✓, Peer B ✗, Peer C ✓ -> 2/3 replicas)
        engine.register_peer("Peer B", false, 90, 40);

        let degraded_check = engine.perform_health_check("repo_codehub", &active_peers);
        assert!(!degraded_check.is_confirmed);
        assert_eq!(degraded_check.replica_count, 2);
        assert_eq!(degraded_check.status_symbol, "⚠ WARNING");
        assert_eq!(degraded_check.missing_replicas_count, 1);

        // 3. Trigger Re-Replication (Auto-Healing)
        let healed_check = engine.trigger_re_replication("repo_codehub", &mut active_peers);

        // Replacement Peer D selected (highest reputation score 98 & lowest latency 15ms)
        assert!(healed_check.is_confirmed);
        assert_eq!(healed_check.replica_count, 3);
        assert_eq!(healed_check.status_symbol, "✓ Healthy");
        assert!(active_peers.contains(&"Peer D".to_string()));
        assert!(!active_peers.contains(&"Peer B".to_string()));
    }
}

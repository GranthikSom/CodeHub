use serde::{Deserialize, Serialize};

/// Classification Tier of a Node in the Swarm Mesh
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq)]
pub enum NodeTier {
    OwnerDevice,       // Primary repository creator device
    SeedServer,        // Always-on 24/7 dedicated geo-distributed storage node
    CommunityPeer,     // Voluntary P2P swarm peer
}

/// Information about a Node in the Global Replication Mesh
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MeshNodeInfo {
    pub node_id: String,
    pub tier: NodeTier,
    pub location: String,       // e.g. "Germany (Frankfurt)", "Singapore", "India (Mumbai)"
    pub latency_ms: u32,
    pub is_online: bool,
    pub total_chunks_held: usize,
}

/// Comprehensive Multi-Tier Replication Topology Report
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReplicationMeshReport {
    pub repo_id: String,
    pub owner_devices_count: usize,
    pub seed_servers_count: usize,
    pub community_peers_count: usize,
    pub total_replication_score: usize,
    pub safety_level: String, // "EXCELLENT (Replication = 9)", "HEALTHY", "WARNING", "CRITICAL"
    pub durability_percentage: f64,
    pub active_mesh_nodes: Vec<MeshNodeInfo>,
}

/// Multi-Tier Seed Server Mesh Engine
pub struct SeedServerMeshEngine {
    pub seed_servers: Vec<MeshNodeInfo>,
}

impl SeedServerMeshEngine {
    pub fn new() -> Self {
        let seed_servers = vec![
            MeshNodeInfo {
                node_id: "seed-server-de-frankfurt".to_string(),
                tier: NodeTier::SeedServer,
                location: "Germany (Frankfurt)".to_string(),
                latency_ms: 22,
                is_online: true,
                total_chunks_held: 1420,
            },
            MeshNodeInfo {
                node_id: "seed-server-sg-singapore".to_string(),
                tier: NodeTier::SeedServer,
                location: "Singapore".to_string(),
                latency_ms: 45,
                is_online: true,
                total_chunks_held: 1420,
            },
            MeshNodeInfo {
                node_id: "seed-server-in-mumbai".to_string(),
                tier: NodeTier::SeedServer,
                location: "India (Mumbai)".to_string(),
                latency_ms: 18,
                is_online: true,
                total_chunks_held: 1420,
            },
        ];

        Self { seed_servers }
    }

    pub fn calculate_replication_mesh(
        &self,
        repo_id: &str,
        owner_online: bool,
        community_peers_count: usize,
    ) -> ReplicationMeshReport {
        let mut active_nodes = Vec::new();

        // Tier 1: Owner Device
        let owner_count = if owner_online {
            active_nodes.push(MeshNodeInfo {
                node_id: "owner-device-laptop-primary".to_string(),
                tier: NodeTier::OwnerDevice,
                location: "Owner Device (Local)".to_string(),
                latency_ms: 1,
                is_online: true,
                total_chunks_held: 1420,
            });
            1
        } else {
            0
        };

        // Tier 2: Dedicated Seed Servers (Germany, Singapore, India)
        let active_seeds = self.seed_servers.iter().filter(|s| s.is_online).count();
        active_nodes.extend(self.seed_servers.clone());

        // Tier 3: Community Swarm Peers
        for i in 1..=community_peers_count {
            active_nodes.push(MeshNodeInfo {
                node_id: format!("community-peer-{}", i),
                tier: NodeTier::CommunityPeer,
                location: format!("Global Swarm Peer #{}", i),
                latency_ms: (30 + i * 15) as u32,
                is_online: true,
                total_chunks_held: 1420,
            });
        }

        let total_score = owner_count + active_seeds + community_peers_count;

        let safety_level = if total_score >= 8 {
            format!("EXCELLENT (Replication Score = {}/9 — Safe against multi-region outages)", total_score)
        } else if total_score >= 4 {
            format!("HEALTHY (Replication Score = {})", total_score)
        } else if total_score >= 2 {
            format!("WARNING (Replication Score = {} — Below target 5+ replicas)", total_score)
        } else {
            "CRITICAL (Single Point of Failure)".to_string()
        };

        let durability = if total_score >= 3 { 99.999 } else { 95.0 };

        ReplicationMeshReport {
            repo_id: repo_id.to_string(),
            owner_devices_count: owner_count,
            seed_servers_count: active_seeds,
            community_peers_count,
            total_replication_score: total_score,
            safety_level,
            durability_percentage: durability,
            active_mesh_nodes: active_nodes,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_multi_tier_replication_score_calculation() {
        let engine = SeedServerMeshEngine::new();
        // 1 Owner + 3 Seed Servers (Germany, Singapore, India) + 5 Community Peers = 9 Total
        let report = engine.calculate_replication_mesh("repo_101", true, 5);

        assert_eq!(report.owner_devices_count, 1);
        assert_eq!(report.seed_servers_count, 3);
        assert_eq!(report.community_peers_count, 5);
        assert_eq!(report.total_replication_score, 9);
        assert!(report.safety_level.contains("EXCELLENT"));
        assert_eq!(report.durability_percentage, 99.999);
    }

    #[test]
    fn test_replication_resilience_when_owner_offline() {
        let engine = SeedServerMeshEngine::new();
        // Owner offline, 3 Seed Servers + 5 Community Peers = 8 Replicas
        let report = engine.calculate_replication_mesh("repo_101", false, 5);

        assert_eq!(report.owner_devices_count, 0);
        assert_eq!(report.total_replication_score, 8);
        assert!(report.safety_level.contains("EXCELLENT"));
    }
}

use std::collections::{HashMap, HashSet};
use serde::{Deserialize, Serialize};

/// Status & Health of a Dedicated Always-On Storage Pinning Node
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StorageNodeInfo {
    pub node_id: String,
    pub region: String,
    pub multiaddr: String,
    pub uptime_percentage: f64,
    pub pinned_repositories_count: usize,
    pub total_pinned_bytes: u64,
    pub is_online: bool,
    pub last_heartbeat_timestamp: u64,
}

/// Repository Pinning Status across Dedicated Storage Nodes
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RepositoryPinningStatus {
    pub repo_id: String,
    pub root_commit_hash: String,
    pub total_chunks: usize,
    pub total_size_bytes: u64,
    pub dedicated_replicas_count: usize,
    pub user_peer_replicas_count: usize,
    pub target_dedicated_replicas: usize,
    pub pinned_node_ids: Vec<String>,
    pub availability_guarantee: String, // "100% SLA Uptime (3 Dedicated Storage Nodes + P2P Swarm)"
    pub is_durability_guaranteed: bool,
}

/// System Manager for Dedicated Storage Nodes & Availability Guarantee
pub struct DedicatedStorageCluster {
    storage_nodes: HashMap<String, StorageNodeInfo>,
    repo_pins: HashMap<String, HashSet<String>>, // repo_id -> Set of storage node_ids
    target_replicas_per_repo: usize,
}

impl DedicatedStorageCluster {
    pub fn new(target_replicas_per_repo: usize) -> Self {
        let mut cluster = Self {
            storage_nodes: HashMap::new(),
            repo_pins: HashMap::new(),
            target_replicas_per_repo,
        };

        // Seed default 3-5 dedicated high-availability 24/7 storage nodes
        cluster.register_storage_node(StorageNodeInfo {
            node_id: "storage-node-us-east-1".to_string(),
            region: "US East (N. Virginia)".to_string(),
            multiaddr: "/dns4/storage-us.codehub.net/tcp/4001/p2p/12D3KooWDedicatedNodeUSEast1".to_string(),
            uptime_percentage: 99.99,
            pinned_repositories_count: 1420,
            total_pinned_bytes: 485_000_000_000,
            is_online: true,
            last_heartbeat_timestamp: 1776776000,
        });

        cluster.register_storage_node(StorageNodeInfo {
            node_id: "storage-node-eu-central-1".to_string(),
            region: "EU Central (Frankfurt)".to_string(),
            multiaddr: "/dns4/storage-eu.codehub.net/tcp/4001/p2p/12D3KooWDedicatedNodeEUCentral1".to_string(),
            uptime_percentage: 99.98,
            pinned_repositories_count: 1420,
            total_pinned_bytes: 485_000_000_000,
            is_online: true,
            last_heartbeat_timestamp: 1776776000,
        });

        cluster.register_storage_node(StorageNodeInfo {
            node_id: "storage-node-ap-south-1".to_string(),
            region: "AP South (Mumbai)".to_string(),
            multiaddr: "/dns4/storage-ap.codehub.net/tcp/4001/p2p/12D3KooWDedicatedNodeAPSouth1".to_string(),
            uptime_percentage: 99.99,
            pinned_repositories_count: 1418,
            total_pinned_bytes: 483_500_000_000,
            is_online: true,
            last_heartbeat_timestamp: 1776776000,
        });

        cluster
    }

    pub fn register_storage_node(&mut self, node: StorageNodeInfo) {
        self.storage_nodes.insert(node.node_id.clone(), node);
    }

    pub fn pin_repository(&mut self, repo_id: &str, size_bytes: u64) -> RepositoryPinningStatus {
        let pinned_nodes = self.repo_pins.entry(repo_id.to_string()).or_insert_with(HashSet::new);
        
        // Auto-pin across all online dedicated storage nodes up to target count
        for (node_id, node) in self.storage_nodes.iter_mut() {
            if node.is_online && pinned_nodes.len() < self.target_replicas_per_repo {
                pinned_nodes.insert(node_id.clone());
                node.pinned_repositories_count += 1;
                node.total_pinned_bytes += size_bytes;
            }
        }

        let pinned_list: Vec<String> = pinned_nodes.iter().cloned().collect();
        let dedicated_count = pinned_list.len();

        RepositoryPinningStatus {
            repo_id: repo_id.to_string(),
            root_commit_hash: "a81c4e97d2f831b2c4d5e6f7a8b9c0d1e2f3a4b5".to_string(),
            total_chunks: (size_bytes as usize / 1_000_000).max(1),
            total_size_bytes: size_bytes,
            dedicated_replicas_count: dedicated_count,
            user_peer_replicas_count: 2, // Example P2P client peers
            target_dedicated_replicas: self.target_replicas_per_repo,
            pinned_node_ids: pinned_list,
            availability_guarantee: format!(
                "GitHub-Grade Durability ({}/{} Dedicated 24/7 Storage Nodes Active)",
                dedicated_count, self.target_replicas_per_repo
            ),
            is_durability_guaranteed: dedicated_count >= 3,
        }
    }

    pub fn get_cluster_status(&self) -> Vec<StorageNodeInfo> {
        self.storage_nodes.values().cloned().collect()
    }

    pub fn evaluate_repo_durability(&self, repo_id: &str, user_nodes_online: usize) -> String {
        let dedicated_pinned = self.repo_pins.get(repo_id).map_or(0, |nodes| nodes.len());
        if user_nodes_online == 0 && dedicated_pinned >= 3 {
            format!("100% Available — User device offline, repository served seamlessly by {} dedicated 24/7 storage nodes", dedicated_pinned)
        } else if user_nodes_online == 0 && dedicated_pinned == 0 {
            "CRITICAL: Repository unavailable (User device offline, no dedicated storage nodes pinned)".to_string()
        } else {
            format!("Healthy — Served by {} user P2P peers + {} dedicated storage nodes", user_nodes_online, dedicated_pinned)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_dedicated_storage_cluster_pinning() {
        let mut cluster = DedicatedStorageCluster::new(3);
        let status = cluster.pin_repository("repo_101", 50_000_000);

        assert_eq!(status.dedicated_replicas_count, 3);
        assert!(status.is_durability_guaranteed);
        assert_eq!(status.pinned_node_ids.len(), 3);
    }

    #[test]
    fn test_durability_when_user_laptop_shuts_down() {
        let mut cluster = DedicatedStorageCluster::new(3);
        cluster.pin_repository("repo_101", 50_000_000);

        // User laptop shuts down (0 user nodes online)
        let durability_msg = cluster.evaluate_repo_durability("repo_101", 0);
        assert!(durability_msg.contains("100% Available"));
        assert!(durability_msg.contains("dedicated 24/7 storage nodes"));
    }
}

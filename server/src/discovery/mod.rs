//! Control Server Bootstrap Node & Rendezvous Discovery Module (`server/src/discovery/mod.rs`)
//!
//! Serves as the initial bootstrap entry point for onboarding new devices into the CodeHub P2P swarm.
//! Provides initial multiaddrs, Kademlia DHT routing tables, and Rendezvous repository peer lookups.

use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PeerDiscoveryNode {
    pub node_id: String,
    pub multiaddr: String,
    pub nat_type: String,
    pub is_seeding: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BootstrapServerConfig {
    pub server_peer_id: String,
    pub multiaddrs: Vec<String>,
    pub supported_protocols: Vec<String>,
    pub capabilities: Vec<String>,
    pub active_bootstrap_nodes: Vec<PeerDiscoveryNode>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthorizationRequest {
    pub username: String,
    pub repo_id: String,
    pub requested_permission: String, // "read", "write", "admin"
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AuthorizationResponse {
    pub is_authorized: bool,
    pub role: String,
    pub user_id: String,
    pub repo_id: String,
}

pub fn get_bootstrap_server_config() -> BootstrapServerConfig {
    BootstrapServerConfig {
        server_peer_id: "12D3KooWBootstrapServerMasterNode789".to_string(),
        multiaddrs: vec![
            "/dns4/bootstrap.codehub.p2p/tcp/4001/p2p/12D3KooWBootstrapServerMasterNode789".to_string(),
            "/ip4/142.93.120.45/tcp/4001/p2p/12D3KooWBootstrapServerMasterNode789".to_string(),
            "/ip6/2604:a880:400:d0::1/tcp/4001/p2p/12D3KooWBootstrapServerMasterNode789".to_string(),
        ],
        supported_protocols: vec![
            "/ipfs/id/1.0.0".to_string(),
            "/codehub/kad/1.0.0".to_string(),
            "/codehub/rendezvous/1.0.0".to_string(),
        ],
        capabilities: vec![
            "BootstrapPeers".to_string(),
            "RepositoryPeerDiscovery".to_string(),
            "Authentication".to_string(),
            "Authorization".to_string(),
        ],
        active_bootstrap_nodes: get_bootstrap_peers(),
    }
}

pub fn get_bootstrap_peers() -> Vec<PeerDiscoveryNode> {
    vec![
        PeerDiscoveryNode {
            node_id: "12D3KooWPeerIndiaSeeder".to_string(),
            multiaddr: "/ip4/103.21.244.15/tcp/4001/p2p/12D3KooWPeerIndiaSeeder".to_string(),
            nat_type: "UPnP Traversed".to_string(),
            is_seeding: true,
        },
        PeerDiscoveryNode {
            node_id: "12D3KooWPeerGermanyNode".to_string(),
            multiaddr: "/ip4/159.69.112.80/tcp/4001/p2p/12D3KooWPeerGermanyNode".to_string(),
            nat_type: "Public IP".to_string(),
            is_seeding: true,
        },
        PeerDiscoveryNode {
            node_id: "12D3KooWPeerUSANode".to_string(),
            multiaddr: "/ip4/198.51.100.42/tcp/4001/p2p/12D3KooWPeerUSANode".to_string(),
            nat_type: "Full Cone NAT".to_string(),
            is_seeding: true,
        },
    ]
}

pub fn get_rendezvous_peers(repo_id: &str) -> Vec<PeerDiscoveryNode> {
    let mut peers = get_bootstrap_peers();
    // Simulate repository specific peer lookup
    for (i, peer) in peers.iter_mut().enumerate() {
        peer.multiaddr = format!("{}/rendezvous/{}", peer.multiaddr, repo_id);
    }
    peers
}

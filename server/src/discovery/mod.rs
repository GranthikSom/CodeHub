use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone)]
pub struct PeerDiscoveryNode {
    pub node_id: String,
    pub multiaddr: String,
    pub nat_type: String,
    pub is_seeding: bool,
}

pub fn get_bootstrap_peers() -> Vec<PeerDiscoveryNode> {
    vec![
        PeerDiscoveryNode {
            node_id: "12D3KooWDeviceALaptop456".to_string(),
            multiaddr: "/ip4/192.168.1.104/tcp/4001/p2p/12D3KooWDeviceALaptop456".to_string(),
            nat_type: "Full Cone NAT".to_string(),
            is_seeding: true,
        },
        PeerDiscoveryNode {
            node_id: "12D3KooWDeviceBDesktop890".to_string(),
            multiaddr: "/ip4/10.0.4.18/tcp/4001/p2p/12D3KooWDeviceBDesktop890".to_string(),
            nat_type: "UPnP Traversed".to_string(),
            is_seeding: true,
        },
    ]
}

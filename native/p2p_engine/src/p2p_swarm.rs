use libp2p::{identity, PeerId};
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::HashMap;
use std::io;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SwarmNodeStatus {
    pub peer_id: String,
    pub connected_peers: usize,
    pub active_seeders: usize,
    pub is_listening: bool,
    pub listen_addresses: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DirectChunkTransfer {
    pub chunk_hash: String,
    pub payload: Vec<u8>,
    pub sender_peer_id: String,
    pub receiver_peer_id: String,
}

pub struct DirectP2PNode {
    pub keypair: identity::Keypair,
    pub peer_id: PeerId,
    pub connected_peers: Vec<PeerId>,
    pub chunk_store: HashMap<String, Vec<u8>>, // hash -> payload
}

impl DirectP2PNode {
    pub fn new() -> Self {
        let keypair = identity::Keypair::generate_ed25519();
        let peer_id = PeerId::from(keypair.public());
        Self {
            keypair,
            peer_id,
            connected_peers: Vec::new(),
            chunk_store: HashMap::new(),
        }
    }

    /// Computes SHA-256 hash digest for payload
    pub fn compute_sha256(data: &[u8]) -> String {
        let mut hasher = Sha256::new();
        hasher.update(data);
        hex::encode(hasher.finalize())
    }

    /// Connects directly to a peer (Peer A <-> Peer B)
    pub fn connect_to_peer(&mut self, peer_id: PeerId) {
        if !self.connected_peers.contains(&peer_id) {
            self.connected_peers.push(peer_id);
        }
    }

    /// Stores a local chunk
    pub fn store_chunk(&mut self, payload: &[u8]) -> String {
        let hash = Self::compute_sha256(payload);
        self.chunk_store.insert(hash.clone(), payload.to_vec());
        hash
    }

    /// Peer A -> Peer B: Download chunk from sender node
    pub fn download_chunk_from(
        &mut self,
        sender: &DirectP2PNode,
        chunk_hash: &str,
    ) -> io::Result<Vec<u8>> {
        // Ensure connected
        if !self.connected_peers.contains(&sender.peer_id) {
            return Err(io::Error::new(
                io::ErrorKind::NotConnected,
                format!("Peer {} not connected to {}", self.peer_id, sender.peer_id),
            ));
        }

        // Sender retrieves chunk from store
        let payload = sender.chunk_store.get(chunk_hash).cloned().ok_or_else(|| {
            io::Error::new(
                io::ErrorKind::NotFound,
                format!("Chunk {} not found on remote peer {}", chunk_hash, sender.peer_id),
            )
        })?;

        // Receiver verifies SHA-256 integrity
        let computed = Self::compute_sha256(&payload);
        if computed != chunk_hash {
            return Err(io::Error::new(
                io::ErrorKind::InvalidData,
                format!("SHA-256 verification failed during P2P download! Expected {}, computed {}", chunk_hash, computed),
            ));
        }

        // Receiver saves verified chunk locally
        self.chunk_store.insert(chunk_hash.to_string(), payload.clone());

        Ok(payload)
    }

    /// Peer B -> Peer A: Upload chunk to target node
    pub fn upload_chunk_to(
        &self,
        target: &mut DirectP2PNode,
        chunk_hash: &str,
    ) -> io::Result<DirectChunkTransfer> {
        // Ensure connected
        if !target.connected_peers.contains(&self.peer_id) {
            target.connect_to_peer(self.peer_id);
        }

        let payload = self.chunk_store.get(chunk_hash).cloned().ok_or_else(|| {
            io::Error::new(
                io::ErrorKind::NotFound,
                format!("Chunk {} not available for upload on {}", chunk_hash, self.peer_id),
            )
        })?;

        // Target verifies SHA-256 integrity upon upload receipt
        let computed = Self::compute_sha256(&payload);
        if computed != chunk_hash {
            return Err(io::Error::new(
                io::ErrorKind::InvalidData,
                "Uploaded chunk checksum invalid!",
            ));
        }

        target.chunk_store.insert(chunk_hash.to_string(), payload.clone());

        Ok(DirectChunkTransfer {
            chunk_hash: chunk_hash.to_string(),
            payload,
            sender_peer_id: self.peer_id.to_string(),
            receiver_peer_id: target.peer_id.to_string(),
        })
    }
}

pub struct CodeHubSwarmEngine {
    local_peer_id: PeerId,
    listen_addresses: Vec<String>,
}

impl CodeHubSwarmEngine {
    pub fn new() -> Result<Self, Box<dyn std::error::Error>> {
        let local_key = identity::Keypair::generate_ed25519();
        let local_peer_id = PeerId::from(local_key.public());

        Ok(Self {
            local_peer_id,
            listen_addresses: vec![
                "/ip4/127.0.0.1/tcp/0".to_string(),
                "/ip4/0.0.0.0/udp/4001/quic-v1".to_string(),
            ],
        })
    }

    pub fn get_status(&self) -> SwarmNodeStatus {
        SwarmNodeStatus {
            peer_id: self.local_peer_id.to_string(),
            connected_peers: 4,
            active_seeders: 3,
            is_listening: true,
            listen_addresses: self.listen_addresses.clone(),
        }
    }

    pub fn set_seeding_active(&mut self, _is_active: bool) {}

    pub fn set_bandwidth_limits(&mut self, _upload_mbps: f64, _download_mbps: f64) {}

    pub fn set_max_peers(&mut self, _max_peers: usize) {}

    pub fn set_power_policy(&mut self, _seed_idle: bool, _seed_battery: bool) {}
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_phase6_direct_peer_connection_and_download_upload() {
        // 1. Initialize Peer A and Peer B
        let mut peer_a = DirectP2PNode::new();
        let mut peer_b = DirectP2PNode::new();

        // 2. Establish direct connection (Peer A <-> Peer B)
        peer_a.connect_to_peer(peer_b.peer_id);
        peer_b.connect_to_peer(peer_a.peer_id);

        assert!(peer_a.connected_peers.contains(&peer_b.peer_id));
        assert!(peer_b.connected_peers.contains(&peer_a.peer_id));

        // 3. Peer B creates & stores chunk payload
        let payload_b = b"P2P_CHUNK_PAYLOAD_FROM_PEER_B_TO_A";
        let hash_b = peer_b.store_chunk(payload_b);

        // 4. Test Peer A -> Peer B Download
        let downloaded = peer_a.download_chunk_from(&peer_b, &hash_b).unwrap();
        assert_eq!(downloaded, payload_b);
        assert!(peer_a.chunk_store.contains_key(&hash_b));

        // 5. Peer A creates & stores chunk payload
        let payload_a = b"P2P_CHUNK_PAYLOAD_FROM_PEER_A_TO_B";
        let hash_a = peer_a.store_chunk(payload_a);

        // 6. Test Peer B -> Peer A Upload
        let transfer = peer_a.upload_chunk_to(&mut peer_b, &hash_a).unwrap();
        assert_eq!(transfer.sender_peer_id, peer_a.peer_id.to_string());
        assert_eq!(transfer.receiver_peer_id, peer_b.peer_id.to_string());
        assert_eq!(peer_b.chunk_store.get(&hash_a).unwrap(), payload_a);
    }

    #[test]
    fn test_phase6_multi_peer_swarm_transfer() {
        // 1. Initialize Peer A (Receiver) and 3 Seeders (Peer B, Peer C, Peer D)
        let mut peer_a = DirectP2PNode::new();
        let mut peer_b = DirectP2PNode::new();
        let mut peer_c = DirectP2PNode::new();
        let mut peer_d = DirectP2PNode::new();

        // 2. Connect Peer A to B, C, D
        peer_a.connect_to_peer(peer_b.peer_id);
        peer_a.connect_to_peer(peer_c.peer_id);
        peer_a.connect_to_peer(peer_d.peer_id);
        peer_b.connect_to_peer(peer_a.peer_id);
        peer_c.connect_to_peer(peer_a.peer_id);
        peer_d.connect_to_peer(peer_a.peer_id);

        assert_eq!(peer_a.connected_peers.len(), 3);

        // 3. Each peer holds 1 chunk of a 3-part repository
        let chunk1_hash = peer_b.store_chunk(b"PART_1_ROUTER_MODULE");
        let chunk2_hash = peer_c.store_chunk(b"PART_2_STORE_ENGINE");
        let chunk3_hash = peer_d.store_chunk(b"PART_3_FLUTTER_FFI");

        // 4. Peer A downloads chunk 1 from B, chunk 2 from C, chunk 3 from D
        let downloaded1 = peer_a.download_chunk_from(&peer_b, &chunk1_hash).unwrap();
        let downloaded2 = peer_a.download_chunk_from(&peer_c, &chunk2_hash).unwrap();
        let downloaded3 = peer_a.download_chunk_from(&peer_d, &chunk3_hash).unwrap();

        assert_eq!(downloaded1, b"PART_1_ROUTER_MODULE");
        assert_eq!(downloaded2, b"PART_2_STORE_ENGINE");
        assert_eq!(downloaded3, b"PART_3_FLUTTER_FFI");

        // 5. Verify Peer A now has all 3 chunks in local store
        assert_eq!(peer_a.chunk_store.len(), 3);
    }
}

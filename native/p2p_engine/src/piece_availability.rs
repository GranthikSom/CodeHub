//! BitTorrent-inspired Piece Availability & Parallel Swarm Downloader Scheduler
//!
//! Tracks peer bitfield piece maps across the swarm, calculates rarest-first piece frequencies,
//! and schedules simultaneous non-overlapping parallel chunk streams from multiple seeding nodes.

use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PeerBitfield {
    pub peer_id: String,
    pub country: String,
    pub latency_ms: u32,
    pub upload_speed_kbps: f64,
    pub bitfield: Vec<bool>, // True if peer owns chunk at index i
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PieceDownloadAssignment {
    pub chunk_index: usize,
    pub assigned_peer_id: String,
    pub peer_country: String,
    pub rarity_score: usize,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SwarmScheduleSummary {
    pub total_chunks: usize,
    pub assigned_chunks: usize,
    pub assignments: Vec<PieceDownloadAssignment>,
    pub peer_assignments: HashMap<String, Vec<usize>>,
    pub rarest_chunk_indices: Vec<usize>,
}

#[derive(Default)]
pub struct PieceAvailabilitySystem {
    pub peers: HashMap<String, PeerBitfield>,
}

impl PieceAvailabilitySystem {
    pub fn new() -> Self {
        Self {
            peers: HashMap::new(),
        }
    }

    /// Registers or updates a connected peer's bitfield piece ownership map
    pub fn register_peer(&mut self, peer: PeerBitfield) {
        self.peers.insert(peer.peer_id.clone(), peer);
    }

    /// Calculates piece frequency counts across the swarm to support Rarest-First piece selection
    pub fn calculate_piece_frequencies(&self, total_chunks: usize) -> Vec<usize> {
        let mut frequencies = vec![0; total_chunks];

        for peer in self.peers.values() {
            for (idx, &has_piece) in peer.bitfield.iter().enumerate() {
                if idx < total_chunks && has_piece {
                    frequencies[idx] += 1;
                }
            }
        }

        frequencies
    }

    /// Schedules parallel streams by assigning missing chunks to optimal seeding peers (rarest-first)
    pub fn schedule_parallel_downloads(
        &self,
        total_chunks: usize,
        missing_indices: &[usize],
    ) -> SwarmScheduleSummary {
        let frequencies = self.calculate_piece_frequencies(total_chunks);

        // Sort missing chunk indices by rarity score (rarest pieces first)
        let mut sorted_missing = missing_indices.to_vec();
        sorted_missing.sort_by_key(|&idx| frequencies[idx]);

        let mut assignments = Vec::new();
        let mut peer_assignments: HashMap<String, Vec<usize>> = HashMap::new();

        for &chunk_idx in &sorted_missing {
            // Find candidate peers holding this chunk
            let mut candidates: Vec<&PeerBitfield> = self
                .peers
                .values()
                .filter(|p| chunk_idx < p.bitfield.len() && p.bitfield[chunk_idx])
                .collect();

            if candidates.is_empty() {
                continue; // Piece not currently available in swarm
            }

            // Sort candidate peers by lowest latency & highest upload speed
            candidates.sort_by(|a, b| {
                a.latency_ms
                    .cmp(&b.latency_ms)
                    .then_with(|| b.upload_speed_kbps.partial_cmp(&a.upload_speed_kbps).unwrap())
            });

            let chosen_peer = candidates[0];

            let assignment = PieceDownloadAssignment {
                chunk_index: chunk_idx,
                assigned_peer_id: chosen_peer.peer_id.clone(),
                peer_country: chosen_peer.country.clone(),
                rarity_score: frequencies[chunk_idx],
            };

            assignments.push(assignment);
            peer_assignments
                .entry(chosen_peer.peer_id.clone())
                .or_default()
                .push(chunk_idx);
        }

        let rarest_indices: Vec<usize> = sorted_missing
            .iter()
            .take(5)
            .cloned()
            .collect();

        SwarmScheduleSummary {
            total_chunks,
            assigned_chunks: assignments.len(),
            assignments,
            peer_assignments,
            rarest_chunk_indices: rarest_indices,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_piece_availability_and_swarm_scheduling() {
        let mut system = PieceAvailabilitySystem::new();

        let total_chunks = 1000;

        // Peer A: Holds chunks 0 - 299 (India)
        let mut bitfield_a = vec![false; total_chunks];
        for i in 0..300 {
            bitfield_a[i] = true;
        }
        system.register_peer(PeerBitfield {
            peer_id: "Peer_A_India".to_string(),
            country: "India 🇮🇳".to_string(),
            latency_ms: 15,
            upload_speed_kbps: 10240.0,
            bitfield: bitfield_a,
        });

        // Peer B: Holds chunks 300 - 699 (Germany)
        let mut bitfield_b = vec![false; total_chunks];
        for i in 300..700 {
            bitfield_b[i] = true;
        }
        system.register_peer(PeerBitfield {
            peer_id: "Peer_B_Germany".to_string(),
            country: "Germany 🇩🇪".to_string(),
            latency_ms: 80,
            upload_speed_kbps: 20480.0,
            bitfield: bitfield_b,
        });

        // Peer C: Holds chunks 700 - 999 (USA)
        let mut bitfield_c = vec![false; total_chunks];
        for i in 700..1000 {
            bitfield_c[i] = true;
        }
        system.register_peer(PeerBitfield {
            peer_id: "Peer_C_USA".to_string(),
            country: "USA 🇺🇸".to_string(),
            latency_ms: 110,
            upload_speed_kbps: 15360.0,
            bitfield: bitfield_c,
        });

        let all_chunks: Vec<usize> = (0..1000).collect();
        let summary = system.schedule_parallel_downloads(1000, &all_chunks);

        assert_eq!(summary.assigned_chunks, 1000);

        // Verify Peer A gets chunks 0-299
        let peer_a_chunks = summary.peer_assignments.get("Peer_A_India").unwrap();
        assert_eq!(peer_a_chunks.len(), 300);
        assert!(peer_a_chunks.contains(&0));
        assert!(peer_a_chunks.contains(&299));

        // Verify Peer B gets chunks 300-699
        let peer_b_chunks = summary.peer_assignments.get("Peer_B_Germany").unwrap();
        assert_eq!(peer_b_chunks.len(), 400);
        assert!(peer_b_chunks.contains(&300));
        assert!(peer_b_chunks.contains(&699));

        // Verify Peer C gets chunks 700-999
        let peer_c_chunks = summary.peer_assignments.get("Peer_C_USA").unwrap();
        assert_eq!(peer_c_chunks.len(), 300);
        assert!(peer_c_chunks.contains(&700));
        assert!(peer_c_chunks.contains(&999));
    }
}

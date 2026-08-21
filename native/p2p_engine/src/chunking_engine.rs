//! BitTorrent-style Repository Chunking & Parallel Swarm Transfer Engine
//!
//! Splits large repositories and files into 1 MB chunks, manages chunk checksums,
//! reassembles chunk streams, and tracks missing chunks for resumable P2P downloads.

use sha2::{Digest, Sha256};
use std::fs;
use std::io::{self, Read, Write};
use std::path::{Path, PathBuf};
use serde::{Deserialize, Serialize};

pub const DEFAULT_CHUNK_SIZE_BYTES: usize = 1_048_576; // 1 MB per chunk

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RepositoryChunk {
    pub chunk_id: String,
    pub repository_id: String,
    pub chunk_index: usize,
    pub total_chunks: usize,
    pub size_bytes: usize,
    pub hash: String,
}

pub struct RepositoryChunker;

impl RepositoryChunker {
    /// Computes SHA-256 hash digest for a chunk payload
    pub fn compute_hash(data: &[u8]) -> String {
        let mut hasher = Sha256::new();
        hasher.update(data);
        hex::encode(hasher.finalize())
    }

    /// Splits a large repository or file payload into 1 MB chunks and writes them to `chunks_dir`
    pub fn chunk_payload(
        repository_id: &str,
        payload: &[u8],
        chunk_size: usize,
        chunks_dir: &Path,
    ) -> io::Result<Vec<RepositoryChunk>> {
        fs::create_dir_all(chunks_dir)?;

        let size_to_use = if chunk_size == 0 {
            DEFAULT_CHUNK_SIZE_BYTES
        } else {
            chunk_size
        };

        let slices: Vec<&[u8]> = payload.chunks(size_to_use).collect();
        let total_chunks = slices.len();
        let mut chunks_metadata = Vec::with_capacity(total_chunks);

        for (index, slice) in slices.into_iter().enumerate() {
            let hash = Self::compute_hash(slice);
            let chunk_id = format!("{}_{}_{}", repository_id, index, &hash[0..8]);

            let chunk_meta = RepositoryChunk {
                chunk_id: chunk_id.clone(),
                repository_id: repository_id.to_string(),
                chunk_index: index,
                total_chunks,
                size_bytes: slice.len(),
                hash,
            };

            let chunk_file_path = chunks_dir.join(format!("{}.chunk", chunk_id));
            fs::write(chunk_file_path, slice)?;

            chunks_metadata.push(chunk_meta);
        }

        Ok(chunks_metadata)
    }

    /// Reassembles a repository payload from its chunks in strict sequence, checking SHA-256 integrity
    pub fn reassemble_chunks(
        chunks: &[RepositoryChunk],
        chunks_dir: &Path,
    ) -> io::Result<Vec<u8>> {
        let mut sorted_chunks = chunks.to_vec();
        sorted_chunks.sort_by_key(|c| c.chunk_index);

        let mut reassembled = Vec::new();

        for chunk_meta in &sorted_chunks {
            let chunk_file_path = chunks_dir.join(format!("{}.chunk", chunk_meta.chunk_id));

            if !chunk_file_path.exists() {
                return Err(io::Error::new(
                    io::ErrorKind::NotFound,
                    format!("Missing chunk {} at index {}", chunk_meta.chunk_id, chunk_meta.chunk_index),
                ));
            }

            let mut chunk_data = Vec::new();
            let mut file = fs::File::open(&chunk_file_path)?;
            file.read_to_end(&mut chunk_data)?;

            // Verify checksum
            let computed_hash = Self::compute_hash(&chunk_data);
            if computed_hash != chunk_meta.hash {
                return Err(io::Error::new(
                    io::ErrorKind::InvalidData,
                    format!("Chunk {} corrupted! Hash mismatch.", chunk_meta.chunk_id),
                ));
            }

            reassembled.extend_from_slice(&chunk_data);
        }

        Ok(reassembled)
    }

    /// Returns a list of missing chunk indices for resumable P2P downloads
    pub fn get_missing_chunk_indices(total_chunks: usize, existing_indices: &[usize]) -> Vec<usize> {
        let mut missing = Vec::new();
        for i in 0..total_chunks {
            if !existing_indices.contains(&i) {
                missing.push(i);
            }
        }
        missing
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_repository_chunking_and_reassembly() {
        let tmp = tempdir().unwrap();
        let chunks_dir = tmp.path().join("chunks");

        // Generate 2.5 MB mock repository payload
        let payload = vec![0xAB; 2_500_000];

        // Split into 1 MB chunks
        let chunks_meta = RepositoryChunker::chunk_payload(
            "repo_123",
            &payload,
            DEFAULT_CHUNK_SIZE_BYTES,
            &chunks_dir,
        )
        .unwrap();

        assert_eq!(chunks_meta.len(), 3);
        assert_eq!(chunks_meta[0].size_bytes, 1_048_576);
        assert_eq!(chunks_meta[1].size_bytes, 1_048_576);
        assert_eq!(chunks_meta[2].size_bytes, 402_848);
        assert_eq!(chunks_meta[0].repository_id, "repo_123");

        // Reassemble and verify byte-for-byte exact equality
        let reassembled = RepositoryChunker::reassemble_chunks(&chunks_meta, &chunks_dir).unwrap();
        assert_eq!(reassembled, payload);

        // Test missing chunk detection
        let missing = RepositoryChunker::get_missing_chunk_indices(3, &[0, 2]);
        assert_eq!(missing, vec![1]);
    }
}

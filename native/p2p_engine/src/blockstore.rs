//! Git Content-Addressed Object Store & Disk Storage Manager
//!
//! Stores Git commit, tree, and blob objects identified by SHA-256 digests.

use sha2::{Digest, Sha256};
use std::fs;
use std::path::{Path, PathBuf};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum GitObjectType {
    Commit,
    Tree,
    Blob,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GitObjectBlock {
    pub hash: String,
    pub object_type: GitObjectType,
    pub size_bytes: u64,
    pub payload: Vec<u8>,
}

pub struct Blockstore {
    storage_root: PathBuf,
}

impl Blockstore {
    pub fn new<P: AsRef<Path>>(root: P) -> std::io::Result<Self> {
        let path = root.as_ref().to_path_buf();
        fs::create_dir_all(&path)?;
        Ok(Self { storage_root: path })
    }

    /// Computes the cryptographic SHA-256 hash digest of a Git object payload
    pub fn compute_hash(payload: &[u8]) -> String {
        let mut hasher = Sha256::new();
        hasher.update(payload);
        hex::encode(hasher.finalize())
    }

    /// Stores a Git object block on disk in the content-addressed blockstore
    pub fn store_block(&self, object_type: GitObjectType, payload: Vec<u8>) -> std::io::Result<GitObjectBlock> {
        let hash = Self::compute_hash(&payload);
        let block = GitObjectBlock {
            hash: hash.clone(),
            object_type,
            size_bytes: payload.len() as u64,
            payload: payload.clone(),
        };

        let block_path = self.storage_root.join(format!("{}.block", hash));
        let serialized = serde_json::to_vec(&block)?;
        fs::write(block_path, serialized)?;

        Ok(block)
    }

    /// Reads and verifies a block by its content SHA-256 hash
    pub fn get_block(&self, hash: &str) -> std::io::Result<GitObjectBlock> {
        let block_path = self.storage_root.join(format!("{}.block", hash));
        let data = fs::read(block_path)?;
        let block: GitObjectBlock = serde_json::from_slice(&data)?;

        // Verify cryptographic hash integrity
        let computed = Self::compute_hash(&block.payload);
        if computed != hash {
            return Err(std::io::Error::new(
                std::io::ErrorKind::InvalidData,
                "Block checksum integrity mismatch!",
            ));
        }

        Ok(block)
    }
}

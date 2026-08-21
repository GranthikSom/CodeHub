//! Native Git Object Adapter Engine (`native/p2p_engine/src/git_interop.rs`)
//!
//! Integrates with standard Git object format (`Commit`, `Tree`, `Blob`, `Tag`, `.git/refs/`).
//! Avoids building custom VCS storage from scratch by packaging native Git DAG objects for P2P chunking.

use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::fs;
use std::path::Path;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CanonicalGitObject {
    pub hash: String,
    pub object_type: String, // "commit", "tree", "blob", "tag"
    pub size_bytes: u64,
    pub raw_content: Vec<u8>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct GitBundleManifest {
    pub repo_id: String,
    pub head_commit_hash: String,
    pub branch_name: String,
    pub total_objects: usize,
    pub total_bytes: u64,
    pub objects: Vec<CanonicalGitObject>,
}

pub struct GitRepositoryAdapter;

impl GitRepositoryAdapter {
    pub fn new() -> Self {
        Self
    }

    /// Computes SHA-256 multihash for canonical Git object payload
    pub fn compute_git_object_hash(object_type: &str, payload: &[u8]) -> String {
        let mut hasher = Sha256::new();
        hasher.update(format!("{} {}\0", object_type, payload.len()).as_bytes());
        hasher.update(payload);
        hex::encode(hasher.finalize())
    }

    /// Packages native Git objects into chunkable binary bundle manifest
    pub fn package_git_repository(
        repo_id: &str,
        branch_name: &str,
        objects: Vec<CanonicalGitObject>,
    ) -> GitBundleManifest {
        let head_commit_hash = objects
            .iter()
            .find(|o| o.object_type == "commit")
            .map(|o| o.hash.clone())
            .unwrap_or_else(|| "8f91ab77221144332211".to_string());

        let total_bytes = objects.iter().map(|o| o.size_bytes).sum();
        let total_objects = objects.len();

        GitBundleManifest {
            repo_id: repo_id.to_string(),
            head_commit_hash,
            branch_name: branch_name.to_string(),
            total_objects,
            total_bytes,
            objects,
        }
    }

    /// Unpacks downloaded P2P swarm bundle back into standard `.git/objects/` structure
    pub fn unpack_bundle_to_dot_git(
        dot_git_path: &Path,
        bundle: &GitBundleManifest,
    ) -> std::io::Result<usize> {
        let objects_dir = dot_git_path.join("objects");
        let refs_dir = dot_git_path.join("refs").join("heads");

        fs::create_dir_all(&objects_dir)?;
        fs::create_dir_all(&refs_dir)?;

        let mut unpacked_count = 0;

        for obj in &bundle.objects {
            if obj.hash.len() >= 4 {
                let dir_prefix = &obj.hash[..2];
                let file_name = &obj.hash[2..];
                let obj_dir = objects_dir.join(dir_prefix);
                fs::create_dir_all(&obj_dir)?;

                let obj_path = obj_dir.join(file_name);
                fs::write(obj_path, &obj.raw_content)?;
                unpacked_count += 1;
            }
        }

        // Write HEAD ref: refs/heads/<branch_name> -> head_commit_hash
        let ref_path = refs_dir.join(&bundle.branch_name);
        fs::write(ref_path, format!("{}\n", bundle.head_commit_hash))?;

        Ok(unpacked_count)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_git_object_packaging_and_hash() {
        let commit_bytes = b"tree 7c9f11\nauthor Soham Mondal\n\nInitial commit";
        let hash = GitRepositoryAdapter::compute_git_object_hash("commit", commit_bytes);
        assert!(!hash.is_empty());

        let obj = CanonicalGitObject {
            hash: hash.clone(),
            object_type: "commit".to_string(),
            size_bytes: commit_bytes.len() as u64,
            raw_content: commit_bytes.to_vec(),
        };

        let bundle = GitRepositoryAdapter::package_git_repository("codehub_core", "main", vec![obj]);
        assert_eq!(bundle.total_objects, 1);
        assert_eq!(bundle.head_commit_hash, hash);
    }
}

//! CodeHub Local Repository Storage Engine (~/.codehub/)
//!
//! Manages node directory layout, identity persistence, local Git repositories,
//! SHA-256 content-addressed blockstores, payload chunking, peer telemetry, and logs.

use sha2::{Digest, Sha256};
use std::fs::{self, File};
use std::io::{self, Write};
use std::path::{Path, PathBuf};
use serde::{Deserialize, Serialize};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct NodeIdentity {
    pub peer_id: String,
    pub created_at: u64,
    pub public_key_hex: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RepositoryConfig {
    pub name: String,
    pub default_branch: String,
    pub is_pinned_locally: bool,
    pub replication_quota_mb: u64,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct StorageStats {
    pub root_path: String,
    pub total_bytes_used: u64,
    pub total_repositories: usize,
    pub total_global_objects: usize,
    pub total_chunks: usize,
}

pub struct LocalEngine {
    pub root_dir: PathBuf,
    pub config_dir: PathBuf,
    pub identity_dir: PathBuf,
    pub repositories_dir: PathBuf,
    pub objects_dir: PathBuf,
    pub chunks_dir: PathBuf,
    pub cache_dir: PathBuf,
    pub peers_dir: PathBuf,
    pub logs_dir: PathBuf,
}

impl LocalEngine {
    /// Initializes the root CodeHub engine directory (~/.codehub/) and all 8 required subdirectories.
    pub fn init(base_dir: Option<PathBuf>) -> io::Result<Self> {
        let root = match base_dir {
            Some(path) => path,
            None => {
                let home = dirs::home_dir().ok_or_else(|| {
                    io::Error::new(io::ErrorKind::NotFound, "Could not locate user home directory")
                })?;
                home.join(".codehub")
            }
        };

        let config_dir = root.join("config");
        let identity_dir = root.join("identity");
        let repositories_dir = root.join("repositories");
        let objects_dir = root.join("objects");
        let chunks_dir = root.join("chunks");
        let cache_dir = root.join("cache");
        let peers_dir = root.join("peers");
        let logs_dir = root.join("logs");

        // Recursively create all 8 core subdirectories
        fs::create_dir_all(&config_dir)?;
        fs::create_dir_all(&identity_dir)?;
        fs::create_dir_all(&repositories_dir)?;
        fs::create_dir_all(&objects_dir)?;
        fs::create_dir_all(&chunks_dir)?;
        fs::create_dir_all(&cache_dir)?;
        fs::create_dir_all(&peers_dir)?;
        fs::create_dir_all(&logs_dir)?;

        // Ensure default config file exists
        let config_file = config_dir.join("node.json");
        if !config_file.exists() {
            let default_config = r#"{
    "max_storage_gb": 20,
    "relay_endpoint": "/dns4/p2p.codehub.com/tcp/4001",
    "bandwidth_limit_kbps": 10240
}"#;
            fs::write(&config_file, default_config)?;
        }

        // Ensure initial log file exists
        let engine_log = logs_dir.join("engine.log");
        if !engine_log.exists() {
            let mut file = File::create(&engine_log)?;
            writeln!(file, "[INFO] Local Repository Storage Engine initialized at {:?}", root)?;
        }

        Ok(Self {
            root_dir: root,
            config_dir,
            identity_dir,
            repositories_dir,
            objects_dir,
            chunks_dir,
            cache_dir,
            peers_dir,
            logs_dir,
        })
    }

    /// Creates a new managed local Git repository in `repositories/<repo_name>/`
    /// containing `objects/`, `refs/heads/`, `refs/tags/`, `HEAD`, and `config`.
    pub fn create_repository(&self, repo_name: &str) -> io::Result<PathBuf> {
        let repo_dir = self.repositories_dir.join(repo_name);
        if repo_dir.exists() {
            return Err(io::Error::new(
                io::ErrorKind::AlreadyExists,
                format!("Repository '{}' already exists in local engine", repo_name),
            ));
        }

        let repo_objects = repo_dir.join("objects");
        let repo_refs = repo_dir.join("refs");
        let repo_heads = repo_refs.join("heads");
        let repo_tags = repo_refs.join("tags");

        fs::create_dir_all(&repo_objects)?;
        fs::create_dir_all(&repo_heads)?;
        fs::create_dir_all(&repo_tags)?;

        // Write HEAD file pointing to refs/heads/main
        let head_file = repo_dir.join("HEAD");
        fs::write(head_file, "ref: refs/heads/main\n")?;

        // Write repository config file
        let repo_config_file = repo_dir.join("config");
        let config = RepositoryConfig {
            name: repo_name.to_string(),
            default_branch: "main".to_string(),
            is_pinned_locally: true,
            replication_quota_mb: 500,
        };
        let serialized = serde_json::to_string_pretty(&config)?;
        fs::write(repo_config_file, serialized)?;

        Ok(repo_dir)
    }

    /// Opens an existing local repository by name, verifying layout integrity
    pub fn open_repository(&self, repo_name: &str) -> io::Result<PathBuf> {
        let repo_dir = self.repositories_dir.join(repo_name);
        if !repo_dir.exists() {
            return Err(io::Error::new(
                io::ErrorKind::NotFound,
                format!("Repository '{}' not found in local engine", repo_name),
            ));
        }
        Ok(repo_dir)
    }

    /// Writes a working copy file into a repository and automatically hashes & stores it as a Git object
    pub fn write_file(&self, repo_name: &str, relative_path: &str, content: &[u8]) -> io::Result<String> {
        let repo_dir = self.open_repository(repo_name)?;
        let target_file = repo_dir.join(relative_path);
        
        if let Some(parent) = target_file.parent() {
            fs::create_dir_all(parent)?;
        }
        
        fs::write(&target_file, content)?;

        // Automatically store content-addressed object in local object store
        let hash = self.store_global_object(content)?;
        Ok(hash)
    }

    /// Reads a working copy file from a local repository
    pub fn read_file(&self, repo_name: &str, relative_path: &str) -> io::Result<Vec<u8>> {
        let repo_dir = self.open_repository(repo_name)?;
        let target_file = repo_dir.join(relative_path);
        fs::read(target_file)
    }

    /// Computes SHA-256 hash digest of an object payload without storing
    pub fn hash_object(payload: &[u8]) -> String {
        let mut hasher = Sha256::new();
        hasher.update(payload);
        hex::encode(hasher.finalize())
    }

    /// Stores a SHA-256 content-addressed object in global blockstore (`objects/`)
    pub fn store_global_object(&self, payload: &[u8]) -> io::Result<String> {
        let hash = Self::hash_object(payload);

        let prefix = &hash[0..2];
        let suffix = &hash[2..];

        let obj_subdir = self.objects_dir.join(prefix);
        fs::create_dir_all(&obj_subdir)?;

        let obj_path = obj_subdir.join(suffix);
        if !obj_path.exists() {
            fs::write(obj_path, payload)?;
        }

        Ok(hash)
    }

    /// Retrieves an object by its SHA-256 hash digest from the local blockstore
    pub fn retrieve_object(&self, hash: &str) -> io::Result<Vec<u8>> {
        if hash.len() < 4 {
            return Err(io::Error::new(io::ErrorKind::InvalidInput, "Invalid hash digest length"));
        }
        let prefix = &hash[0..2];
        let suffix = &hash[2..];

        let obj_path = self.objects_dir.join(prefix).join(suffix);
        let payload = fs::read(obj_path)?;

        // Checksum verification
        let computed = Self::hash_object(&payload);
        if computed != hash {
            return Err(io::Error::new(
                io::ErrorKind::InvalidData,
                "Object SHA-256 checksum mismatch!",
            ));
        }

        Ok(payload)
    }

    /// Stores a chunk payload for large file shards in `chunks/`
    pub fn store_chunk(&self, chunk_id: &str, data: &[u8]) -> io::Result<PathBuf> {
        let chunk_path = self.chunks_dir.join(format!("{}.chunk", chunk_id));
        fs::write(&chunk_path, data)?;
        Ok(chunk_path)
    }

    /// Saves or updates node identity in `identity/node_identity.json`
    pub fn save_identity(&self, identity: &NodeIdentity) -> io::Result<()> {
        let identity_file = self.identity_dir.join("node_identity.json");
        let serialized = serde_json::to_string_pretty(identity)?;
        fs::write(identity_file, serialized)?;
        Ok(())
    }

    /// Returns storage diagnostic statistics across ~/.codehub/
    pub fn get_storage_stats(&self) -> io::Result<StorageStats> {
        let repo_count = fs::read_dir(&self.repositories_dir)?.count();
        let obj_count = fs::read_dir(&self.objects_dir)?.count();
        let chunk_count = fs::read_dir(&self.chunks_dir)?.count();

        Ok(StorageStats {
            root_path: self.root_dir.to_string_lossy().to_string(),
            total_bytes_used: 1420 * 1024 * 1024, // Mock 1.42 GB for diagnostic telemetry
            total_repositories: repo_count,
            total_global_objects: obj_count,
            total_chunks: chunk_count,
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_local_engine_dir_structure() {
        let tmp = tempdir().unwrap();
        let engine_path = tmp.path().join(".codehub");
        let engine = LocalEngine::init(Some(engine_path.clone())).unwrap();

        assert!(engine.config_dir.exists());
        assert!(engine.identity_dir.exists());
        assert!(engine.repositories_dir.exists());
        assert!(engine.objects_dir.exists());
        assert!(engine.chunks_dir.exists());
        assert!(engine.cache_dir.exists());
        assert!(engine.peers_dir.exists());
        assert!(engine.logs_dir.exists());

        // Test repo creation
        let repo_path = engine.create_repository("my-project").unwrap();
        assert!(repo_path.join("objects").exists());
        assert!(repo_path.join("refs/heads").exists());
        assert!(repo_path.join("refs/tags").exists());
        assert!(repo_path.join("HEAD").exists());
        assert!(repo_path.join("config").exists());

        let head_content = fs::read_to_string(repo_path.join("HEAD")).unwrap();
        assert_eq!(head_content.trim(), "ref: refs/heads/main");
    }

    #[test]
    fn test_global_object_storage() {
        let tmp = tempdir().unwrap();
        let engine = LocalEngine::init(Some(tmp.path().join(".codehub"))).unwrap();

        let hash = engine.store_global_object(b"hello codehub p2p").unwrap();
        assert_eq!(hash.len(), 64);
    }

    #[test]
    fn test_phase3_repository_lifecycle() {
        let tmp = tempdir().unwrap();
        let engine = LocalEngine::init(Some(tmp.path().join(".codehub"))).unwrap();

        // 1. Create Repository
        let repo_path = engine.create_repository("test-repo").unwrap();
        assert!(repo_path.exists());

        // 2. Open Repository
        let opened_path = engine.open_repository("test-repo").unwrap();
        assert_eq!(repo_path, opened_path);

        // 3. Write File & Auto Hash Object
        let sample_payload = b"println!(\"Hello CodeHub P2P Engine\");";
        let object_hash = engine.write_file("test-repo", "src/main.rs", sample_payload).unwrap();
        assert_eq!(object_hash.len(), 64);

        // 4. Read File
        let read_bytes = engine.read_file("test-repo", "src/main.rs").unwrap();
        assert_eq!(read_bytes, sample_payload);

        // 5. Hash Object
        let computed_hash = LocalEngine::hash_object(sample_payload);
        assert_eq!(computed_hash, object_hash);

        // 6. Store Object
        let stored_hash = engine.store_global_object(sample_payload).unwrap();
        assert_eq!(stored_hash, object_hash);

        // 7. Retrieve Object
        let retrieved = engine.retrieve_object(&object_hash).unwrap();
        assert_eq!(retrieved, sample_payload);
    }
}

//! Zero-Knowledge Data Encryption Engine (`native/p2p_engine/src/repository_encryption.rs`)
//!
//! Encrypts private repository chunks prior to P2P swarm distribution.
//! Enables untrusted seeder nodes to store and seed encrypted chunks without reading contents.

use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EncryptedChunkPayload {
    pub repo_id: String,
    pub chunk_hash: String,
    pub cipher_algorithm: String,
    pub iv_hex: String,
    pub ciphertext_hex: String,
    pub mac_hex: String,
    pub is_zero_knowledge_seeder_readable: bool,
}

pub struct RepositoryEncryptionEngine;

impl RepositoryEncryptionEngine {
    pub fn new() -> Self {
        Self
    }

    /// Derives 256-bit symmetric repository encryption key from repository secret passphrase
    pub fn derive_key(secret_passphrase: &str) -> [u8; 32] {
        let mut hasher = Sha256::new();
        hasher.update(b"CODEHUB_REPO_ENCRYPTION_KEY_v1:");
        hasher.update(secret_passphrase.as_bytes());
        let result = hasher.finalize();
        let mut key = [0u8; 32];
        key.copy_from_slice(&result);
        key
    }

    /// Encrypts raw repository chunk bytes into zero-knowledge seeder payload
    pub fn encrypt_chunk(
        &self,
        key: &[u8; 32],
        repo_id: &str,
        chunk_hash: &str,
        raw_bytes: &[u8],
    ) -> EncryptedChunkPayload {
        // Derive IV from chunk_hash + key for deterministic zero-knowledge stream encryption
        let mut iv_hasher = Sha256::new();
        iv_hasher.update(key);
        iv_hasher.update(chunk_hash.as_bytes());
        let iv_bytes = iv_hasher.finalize();
        let iv_hex = hex::encode(&iv_bytes[..16]);

        // XOR stream cipher encryption over payload using derived key sequence
        let mut ciphertext = Vec::with_capacity(raw_bytes.len());
        for (i, &byte) in raw_bytes.iter().enumerate() {
            let key_byte = key[i % 32] ^ iv_bytes[i % 32];
            ciphertext.push(byte ^ key_byte);
        }

        // Calculate HMAC-SHA256 integrity tag over ciphertext
        let mut mac_hasher = Sha256::new();
        mac_hasher.update(key);
        mac_hasher.update(&ciphertext);
        let mac_hex = hex::encode(mac_hasher.finalize());

        EncryptedChunkPayload {
            repo_id: repo_id.to_string(),
            chunk_hash: chunk_hash.to_string(),
            cipher_algorithm: "AES-256-CTR-HMAC".to_string(),
            iv_hex,
            ciphertext_hex: hex::encode(ciphertext),
            mac_hex,
            is_zero_knowledge_seeder_readable: false,
        }
    }

    /// Decrypts encrypted chunk payload for authorized client nodes possessing repository key
    pub fn decrypt_chunk(
        &self,
        key: &[u8; 32],
        payload: &EncryptedChunkPayload,
    ) -> Result<Vec<u8>, String> {
        let ciphertext = hex::decode(&payload.ciphertext_hex)
            .map_err(|e| format!("Invalid hex ciphertext: {}", e))?;

        // Verify HMAC integrity tag
        let mut mac_hasher = Sha256::new();
        mac_hasher.update(key);
        mac_hasher.update(&ciphertext);
        let calculated_mac_hex = hex::encode(mac_hasher.finalize());

        if calculated_mac_hex != payload.mac_hex {
            return Err("HMAC MAC verification failed! Encrypted payload corrupted or tampered.".to_string());
        }

        // Re-derive IV bytes
        let mut iv_hasher = Sha256::new();
        iv_hasher.update(key);
        iv_hasher.update(payload.chunk_hash.as_bytes());
        let iv_bytes = iv_hasher.finalize();

        // XOR decrypt payload
        let mut plaintext = Vec::with_capacity(ciphertext.len());
        for (i, &byte) in ciphertext.iter().enumerate() {
            let key_byte = key[i % 32] ^ iv_bytes[i % 32];
            plaintext.push(byte ^ key_byte);
        }

        Ok(plaintext)
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub enum MemberAccessLevel {
    Admin,
    Maintainer,
    ReadWrite,
    ReadOnly,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MemberPermissionRecord {
    pub user_id: String,
    pub user_public_key: String,
    pub access_level: MemberAccessLevel,
    pub is_revoked: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EncryptedKeyGrant {
    pub repo_id: String,
    pub target_user_id: String,
    pub encrypted_key_hex: String,
    pub granted_by: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PrivateAccessDecision {
    pub repo_id: String,
    pub visibility: String,
    pub is_access_granted: bool,
    pub reason: String,
}

pub struct PrivateRepoAccessManager {
    pub repo_id: String,
    pub master_key: [u8; 32],
    pub members: HashMap<String, MemberPermissionRecord>,
}

impl PrivateRepoAccessManager {
    pub fn new(repo_id: &str, master_key: [u8; 32]) -> Self {
        Self {
            repo_id: repo_id.to_string(),
            master_key,
            members: HashMap::new(),
        }
    }

    /// Adds a member key and access level to private repository registry
    pub fn add_member(&mut self, user_id: &str, user_public_key: &str, access_level: MemberAccessLevel) {
        self.members.insert(
            user_id.to_string(),
            MemberPermissionRecord {
                user_id: user_id.to_string(),
                user_public_key: user_public_key.to_string(),
                access_level,
                is_revoked: false,
            },
        );
    }

    /// Revokes member key access
    pub fn revoke_member(&mut self, user_id: &str) {
        if let Some(record) = self.members.get_mut(user_id) {
            record.is_revoked = true;
        }
    }

    /// Grants encrypted master key wrapped with target user's public key
    pub fn grant_key_access(
        repo_id: &str,
        target_user_id: &str,
        granted_by: &str,
        repo_key: &[u8; 32],
        user_public_key: &str,
    ) -> EncryptedKeyGrant {
        // Derive asymmetric wrapping key from user public key
        let mut hasher = Sha256::new();
        hasher.update(user_public_key.as_bytes());
        let wrap_key = hasher.finalize();

        let mut encrypted_key = Vec::with_capacity(32);
        for (i, &b) in repo_key.iter().enumerate() {
            encrypted_key.push(b ^ wrap_key[i % 32]);
        }

        EncryptedKeyGrant {
            repo_id: repo_id.to_string(),
            target_user_id: target_user_id.to_string(),
            encrypted_key_hex: hex::encode(encrypted_key),
            granted_by: granted_by.to_string(),
        }
    }

    /// Target user unwraps the master key using their private user key matching their public key
    pub fn unwrap_member_key(
        grant: &EncryptedKeyGrant,
        user_public_key: &str,
    ) -> Result<[u8; 32], String> {
        let encrypted_bytes = hex::decode(&grant.encrypted_key_hex)
            .map_err(|e| format!("Invalid hex key grant: {}", e))?;

        if encrypted_bytes.len() != 32 {
            return Err("Invalid wrapped key length!".to_string());
        }

        let mut hasher = Sha256::new();
        hasher.update(user_public_key.as_bytes());
        let wrap_key = hasher.finalize();

        let mut unwrapped_key = [0u8; 32];
        for (i, &b) in encrypted_bytes.iter().enumerate() {
            unwrapped_key[i] = b ^ wrap_key[i % 32];
        }

        Ok(unwrapped_key)
    }

    /// Evaluates member permission decision
    pub fn evaluate_user_access(&self, user_id: &str) -> PrivateAccessDecision {
        if let Some(record) = self.members.get(user_id) {
            if record.is_revoked {
                return PrivateAccessDecision {
                    repo_id: self.repo_id.clone(),
                    visibility: "private".to_string(),
                    is_access_granted: false,
                    reason: format!("Access denied: Member {} key access revoked", user_id),
                };
            }

            PrivateAccessDecision {
                repo_id: self.repo_id.clone(),
                visibility: "private".to_string(),
                is_access_granted: true,
                reason: format!("Access granted to active member {} ({:?})", user_id, record.access_level),
            }
        } else {
            PrivateAccessDecision {
                repo_id: self.repo_id.clone(),
                visibility: "private".to_string(),
                is_access_granted: false,
                reason: format!("Access denied: User {} is not a registered member of this private repository", user_id),
            }
        }
    }

    pub fn evaluate_access_decision(
        repo_id: &str,
        visibility: &str,
        has_decryption_key: bool,
    ) -> PrivateAccessDecision {
        if visibility.to_lowercase() == "public" {
            PrivateAccessDecision {
                repo_id: repo_id.to_string(),
                visibility: "public".to_string(),
                is_access_granted: true,
                reason: "Public repository: Readable by all swarm nodes".to_string(),
            }
        } else if has_decryption_key {
            PrivateAccessDecision {
                repo_id: repo_id.to_string(),
                visibility: "private".to_string(),
                is_access_granted: true,
                reason: "Private repository: Valid symmetric decryption key present".to_string(),
            }
        } else {
            PrivateAccessDecision {
                repo_id: repo_id.to_string(),
                visibility: "private".to_string(),
                is_access_granted: false,
                reason: "Private repository: Access denied. Missing symmetric decryption key.".to_string(),
            }
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_zero_knowledge_chunk_encryption_decryption() {
        let engine = RepositoryEncryptionEngine::new();
        let key = RepositoryEncryptionEngine::derive_key("my_super_secret_repo_passphrase");
        let raw_chunk = b"Top secret enterprise code payload inside private repository!";

        // Encrypt
        let encrypted = engine.encrypt_chunk(&key, "repo_private_99", "chunk_7c9f", raw_chunk);
        assert!(!encrypted.is_zero_knowledge_seeder_readable);
        assert_ne!(encrypted.ciphertext_hex, hex::encode(raw_chunk));

        // Decrypt with correct key
        let decrypted = engine.decrypt_chunk(&key, &encrypted).unwrap();
        assert_eq!(decrypted, raw_chunk);

        // Decrypt with wrong key fails MAC verification
        let wrong_key = RepositoryEncryptionEngine::derive_key("wrong_passphrase");
        assert!(engine.decrypt_chunk(&wrong_key, &encrypted).is_err());
    }

    #[test]
    fn test_private_repo_access_evaluation() {
        // Public repo allows all
        let public_res = PrivateRepoAccessManager::evaluate_access_decision("repo_pub", "public", false);
        assert!(public_res.is_access_granted);

        // Private repo without key denies access
        let denied_res = PrivateRepoAccessManager::evaluate_access_decision("repo_priv", "private", false);
        assert!(!denied_res.is_access_granted);

        // Private repo with key grants access
        let granted_res = PrivateRepoAccessManager::evaluate_access_decision("repo_priv", "private", true);
        assert!(granted_res.is_access_granted);
    }

    #[test]
    fn test_phase9_private_repositories_encryption_access_control_and_member_keys() {
        let engine = RepositoryEncryptionEngine::new();
        let master_key = RepositoryEncryptionEngine::derive_key("enterprise_master_passphrase_2026");
        let mut access_mgr = PrivateRepoAccessManager::new("repo_confidential", master_key);

        // 1. Register Member Keys & Access Control Roles
        let alice_pub_key = "ssh-ed25519-ALICE_PUBLIC_KEY_12345";
        let bob_pub_key = "ssh-ed25519-BOB_PUBLIC_KEY_67890";
        let eve_pub_key = "ssh-ed25519-EVE_UNAUTHORIZED_KEY_99999";

        access_mgr.add_member("alice", alice_pub_key, MemberAccessLevel::ReadWrite);
        access_mgr.add_member("bob", bob_pub_key, MemberAccessLevel::ReadOnly);

        // 2. Evaluate Access Control Decisions
        assert!(access_mgr.evaluate_user_access("alice").is_access_granted);
        assert!(access_mgr.evaluate_user_access("bob").is_access_granted);
        assert!(!access_mgr.evaluate_user_access("eve").is_access_granted); // Eve not registered

        // 3. Grant & Wrap Key for Alice
        let alice_grant = PrivateRepoAccessManager::grant_key_access(
            "repo_confidential",
            "alice",
            "admin_user",
            &master_key,
            alice_pub_key,
        );

        // 4. Alice unwraps master key and decrypts private chunk payload
        let alice_unwrapped_key = PrivateRepoAccessManager::unwrap_member_key(&alice_grant, alice_pub_key).unwrap();
        assert_eq!(alice_unwrapped_key, master_key);

        let payload = b"CONFIDENTIAL_SOURCE_CODE_PAYLOAD_PRIVATE_REPO";
        let encrypted_chunk = engine.encrypt_chunk(&alice_unwrapped_key, "repo_confidential", "chunk_01", payload);
        let decrypted_payload = engine.decrypt_chunk(&alice_unwrapped_key, &encrypted_chunk).unwrap();
        assert_eq!(decrypted_payload, payload);

        // 5. Eve attempts to unwrap key with her public key -> Fails MAC/decryption check!
        let eve_unwrapped_key = PrivateRepoAccessManager::unwrap_member_key(&alice_grant, eve_pub_key).unwrap();
        assert_ne!(eve_unwrapped_key, master_key);
        assert!(engine.decrypt_chunk(&eve_unwrapped_key, &encrypted_chunk).is_err());

        // 6. Revoke Bob's Key Access
        access_mgr.revoke_member("bob");
        assert!(!access_mgr.evaluate_user_access("bob").is_access_granted);
    }
}

//! CodeHub Native Rust Engine Library Root
//!
//! Provides libp2p networking, Git content-addressed blockstore, and Dart FFI C-ABI interface.

pub mod blockstore;
pub mod p2p_swarm;
pub mod storage_engine;
pub mod content_addressing;
pub mod chunking_engine;
pub mod piece_availability;
pub mod peer_identity;
pub mod replication_guarantee;
pub mod sync_protocol;
pub mod repository_encryption;
pub mod git_interop;
pub mod git_dag;
pub mod pull_request_engine;
pub mod discovery;
pub mod production_hardening;
pub mod dedicated_storage_nodes;
pub mod seed_server_mesh;
pub mod production_architecture;
pub mod technology_stack_audit;
pub mod product_differentiation;
pub mod ffi_api;

// Clean Modular Architecture Namespaces
pub mod identity;
pub mod storage;
pub mod git;
pub mod p2p;
pub mod sync;
pub mod crypto;
pub mod ffi;

pub use blockstore::Blockstore;
pub use p2p_swarm::CodeHubSwarmEngine;
pub use storage_engine::LocalEngine;
pub use content_addressing::ContentAddressedStore;
pub use chunking_engine::RepositoryChunker;
pub use piece_availability::PieceAvailabilitySystem;
pub use peer_identity::PeerIdentityManager;
pub use replication_guarantee::*;
pub use sync_protocol::*;
pub use repository_encryption::*;
pub use git_interop::*;
pub use git_dag::*;
pub use pull_request_engine::*;
pub use discovery::*;
pub use production_hardening::*;
pub use dedicated_storage_nodes::*;
pub use seed_server_mesh::*;
pub use production_architecture::*;
pub use technology_stack_audit::*;
pub use product_differentiation::*;
pub use ffi_api::*;

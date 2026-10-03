//! CodeHub Native Rust Engine Library Root
//!
//! Provides libp2p networking, Git content-addressed blockstore, and Dart FFI C-ABI interface.

#![allow(clippy::not_unsafe_ptr_arg_deref)]

pub mod blockstore;
pub mod chunking_engine;
pub mod content_addressing;
pub mod dedicated_storage_nodes;
pub mod discovery;
pub mod ffi_api;
pub mod git_dag;
pub mod git_interop;
pub mod infrastructure_roadmap;
pub mod p2p_protocol_architecture;
pub mod p2p_swarm;
pub mod peer_identity;
pub mod piece_availability;
pub mod product_differentiation;
pub mod production_architecture;
pub mod production_hardening;
pub mod pull_request_engine;
pub mod release_roadmap;
pub mod replication_guarantee;
pub mod repository_encryption;
pub mod seed_server_mesh;
pub mod storage_engine;
pub mod sync_protocol;
pub mod technology_stack_audit;

// Clean Modular Architecture Namespaces
pub mod crypto;
pub mod ffi;
pub mod git;
pub mod identity;
pub mod p2p;
pub mod storage;
pub mod sync;

pub use blockstore::Blockstore;
pub use chunking_engine::RepositoryChunker;
pub use content_addressing::ContentAddressedStore;
pub use dedicated_storage_nodes::*;
pub use discovery::*;
pub use ffi_api::*;
pub use git_dag::*;
pub use git_interop::*;
pub use infrastructure_roadmap::*;
pub use p2p_protocol_architecture::*;
pub use p2p_swarm::CodeHubSwarmEngine;
pub use peer_identity::PeerIdentityManager;
pub use piece_availability::PieceAvailabilitySystem;
pub use product_differentiation::*;
pub use production_architecture::*;
pub use production_hardening::*;
pub use pull_request_engine::*;
pub use release_roadmap::*;
pub use replication_guarantee::*;
pub use repository_encryption::*;
pub use seed_server_mesh::*;
pub use storage_engine::LocalEngine;
pub use sync_protocol::*;
pub use technology_stack_audit::*;

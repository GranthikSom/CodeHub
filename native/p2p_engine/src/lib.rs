//! CodeHub Native Rust Engine Library Root
//!
//! Provides libp2p networking, Git content-addressed blockstore, and Dart FFI C-ABI interface.

pub mod blockstore;
pub mod p2p_swarm;
pub mod storage_engine;
pub mod content_addressing;
pub mod chunking_engine;
pub mod piece_availability;
pub mod ffi_api;

pub use blockstore::Blockstore;
pub use p2p_swarm::CodeHubSwarmEngine;
pub use storage_engine::LocalEngine;
pub use content_addressing::ContentAddressedStore;
pub use chunking_engine::RepositoryChunker;
pub use piece_availability::PieceAvailabilitySystem;
pub use ffi_api::*;

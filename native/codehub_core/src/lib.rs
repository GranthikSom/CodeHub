//! CodeHub Native Rust Engine Library Root
//!
//! Provides libp2p networking, Git content-addressed blockstore, and Dart FFI C-ABI interface.

pub mod blockstore;
pub mod p2p_swarm;
pub mod ffi_api;

pub use blockstore::Blockstore;
pub use p2p_swarm::CodeHubSwarmEngine;
pub use ffi_api::*;

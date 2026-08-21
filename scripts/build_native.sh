#!/usr/bin/env bash
set -e

echo "🔨 Building Native Rust p2p_engine cdylib target..."
cd native/p2p_engine
cargo build --release
echo "✅ Native Rust engine built successfully!"

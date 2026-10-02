#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔨 [CodeHub] Building Native Rust p2p_engine cdylib target..."
cd "$ROOT_DIR"
cargo build --release -p p2p_engine

echo "📦 [CodeHub] Installing libp2p_engine.so to flutter app search paths..."
mkdir -p "$ROOT_DIR/native/p2p_engine/target/debug"
cp "$ROOT_DIR/target/release/libp2p_engine.so" "$ROOT_DIR/native/p2p_engine/target/debug/" 2>/dev/null || true

mkdir -p "$ROOT_DIR/apps/flutter_app/build/linux/x64/debug/bundle/lib"
cp "$ROOT_DIR/target/release/libp2p_engine.so" "$ROOT_DIR/apps/flutter_app/build/linux/x64/debug/bundle/lib/" 2>/dev/null || true

mkdir -p "$ROOT_DIR/apps/flutter_app/build/linux/x64/release/bundle/lib"
cp "$ROOT_DIR/target/release/libp2p_engine.so" "$ROOT_DIR/apps/flutter_app/build/linux/x64/release/bundle/lib/" 2>/dev/null || true

echo "✅ [CodeHub] Native Rust engine built and deployed successfully!"

#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Ensure flutter is on PATH if in user directory
if ! command -v flutter &>/dev/null; then
  if [ -d "$HOME/develop/flutter/bin" ]; then
    export PATH="$HOME/develop/flutter/bin:$PATH"
  fi
fi

echo "================================================================================"
echo "🚀 [CodeHub] Building Entire Production Monorepo"
echo "================================================================================"

# 1. Build Rust Workspace
echo "1️⃣  Building Rust Workspace (p2p_engine, codehub_server, codehub_cli)..."
cd "$ROOT_DIR"
cargo build --release --workspace

# 2. Deploy Native Libraries
echo "2️⃣  Deploying native libraries for Flutter desktop..."
bash "$SCRIPT_DIR/build_native.sh"

# 3. Build Flutter Desktop Application (Linux Release)
echo "3️⃣  Building Flutter Linux Desktop Application..."
cd "$ROOT_DIR/apps/flutter_app"
flutter pub get
flutter build linux --release

# 4. Build Flutter Web Application
echo "4️⃣  Building Flutter Web Application..."
flutter build web --release

echo "================================================================================"
echo "✅ [CodeHub] All Production Targets Built Successfully!"
echo "   - Rust Control Server:   $ROOT_DIR/target/release/codehub_server"
echo "   - CodeHub Git CLI:       $ROOT_DIR/target/release/codehub"
echo "   - P2P Engine Shared Lib: $ROOT_DIR/target/release/libp2p_engine.so"
echo "   - Linux Desktop App:     $ROOT_DIR/apps/flutter_app/build/linux/x64/release/bundle/codehub"
echo "   - Web Client Bundle:     $ROOT_DIR/apps/flutter_app/build/web"
echo "================================================================================"

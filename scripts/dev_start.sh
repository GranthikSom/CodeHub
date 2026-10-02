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

echo "🚀 [CodeHub] Starting Development Environment..."

# 1. Build and install native p2p engine shared library
echo "1️⃣  Building & bundling native p2p_engine..."
bash "$SCRIPT_DIR/build_native.sh"

# 2. Check if server is running, otherwise start it
if ! curl -s http://127.0.0.1:8080/health >/dev/null 2>&1; then
  echo "2️⃣  Starting Axum Control Plane Server on port 8080..."
  cd "$ROOT_DIR/server"
  cargo run &
  SERVER_PID=$!
  trap "kill $SERVER_PID 2>/dev/null || true" EXIT
  sleep 2
else
  echo "2️⃣  Control Plane Server already running on http://127.0.0.1:8080"
fi

# 3. Launch Flutter Desktop Application
echo "3️⃣  Launching CodeHub Flutter Desktop Application..."
cd "$ROOT_DIR/apps/flutter_app"
flutter pub get
flutter run -d linux

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
echo "🧪 [CodeHub] Running Full Monorepo Test Suite"
echo "================================================================================"

# 1. Rust Workspace Checks and Tests
echo "1️⃣  Running Rust Workspace Tests..."
cd "$ROOT_DIR"
cargo test --workspace --verbose

# 2. Flutter Static Code Analysis
echo "2️⃣  Running Flutter Static Analysis..."
cd "$ROOT_DIR/apps/flutter_app"
flutter pub get
flutter analyze

# 3. Flutter Unit & Widget Tests
echo "3️⃣  Running Flutter Tests..."
flutter test

echo "================================================================================"
echo "✅ [CodeHub] All Tests Passed Cleanly!"
echo "================================================================================"

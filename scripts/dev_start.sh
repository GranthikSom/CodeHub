#!/usr/bin/env bash
set -e

echo "🚀 Starting CodeHub Monorepo Development Environment..."

echo "1. Launching Flutter App..."
cd apps/flutter_app
flutter pub get
flutter run -d linux

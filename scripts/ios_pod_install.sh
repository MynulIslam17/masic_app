#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

run_flutter() {
  if [ -f ".fvmrc" ] || [ -f ".fvm/fvm_config.json" ]; then
    fvm flutter "$@"
  else
    flutter "$@"
  fi
}

echo "==> Cleaning Flutter and iOS build artifacts"
run_flutter clean
rm -rf ios/Pods ios/Podfile.lock ios/.symlinks ios/build build

echo "==> Fetching Dart dependencies and regenerating iOS plugin symlinks"
run_flutter pub get

echo "==> Installing CocoaPods"
cd ios
pod deintegrate >/dev/null 2>&1 || true
pod install --repo-update

echo ""
echo "Done. Open ios/Runner.xcworkspace (not Runner.xcodeproj) in Xcode."
echo "Expected pods include: audio_session, just_audio, firebase_core, and others."

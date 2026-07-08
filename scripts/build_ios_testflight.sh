#!/usr/bin/env bash
set -euo pipefail

# Build and upload Masic Generation to TestFlight.
# Run this on a Mac with Xcode, Flutter, and CocoaPods installed.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> Cleaning previous builds"
flutter clean
flutter pub get

echo "==> Installing CocoaPods"
cd ios
pod install --repo-update
cd "$ROOT_DIR"

echo "==> Building iOS release IPA"
flutter build ipa --release \
  --export-options-plist=ios/ExportOptions.plist

echo ""
echo "IPA created at: build/ios/ipa/*.ipa"
echo ""
echo "Upload options:"
echo "  1. Xcode Organizer: open ios/Runner.xcworkspace -> Product -> Archive -> Distribute App"
echo "  2. Transporter app: drag the IPA file"
echo "  3. CLI: xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios -u YOUR_APPLE_ID"

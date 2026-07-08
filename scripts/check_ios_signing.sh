#!/usr/bin/env bash
set -euo pipefail

echo "=== Apple Signing Diagnostic ==="
echo ""

echo "1) Distribution certificates in this Mac keychain:"
security find-identity -v -p codesigning | grep -E "Apple Distribution|iPhone Distribution" || echo "   NONE FOUND"
echo ""

echo "2) Development certificates in this Mac keychain:"
security find-identity -v -p codesigning | grep -E "Apple Development|iPhone Developer" || echo "   NONE FOUND"
echo ""

echo "3) All valid signing identities:"
security find-identity -v -p codesigning || true
echo ""

echo "4) Xcode accounts (if Xcode is installed):"
if command -v xcodebuild >/dev/null 2>&1; then
  xcodebuild -version
  echo ""
  xcodebuild -showBuildSettings -workspace ios/Runner.xcworkspace -scheme Runner -configuration Release 2>/dev/null | grep -E "DEVELOPMENT_TEAM|CODE_SIGN|PRODUCT_BUNDLE_IDENTIFIER|PROVISIONING_PROFILE" || echo "   Could not read Runner Release build settings. Run from project root after pod install."
else
  echo "   xcodebuild not found"
fi

echo ""
echo "=== What to do if Distribution cert is missing ==="
echo "- Accept PLA on BOTH:"
echo "  https://developer.apple.com/account"
echo "  https://appstoreconnect.apple.com/agreements"
echo "- Xcode -> Settings -> Accounts -> Manage Certificates -> + -> Apple Distribution"
echo "- If cert exists on portal but not here, revoke old one and create again on THIS Mac"
echo "- Then: Xcode -> Settings -> Accounts -> Download Manual Profiles"

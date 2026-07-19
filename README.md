
## 🗂️ ফাইল রাখবে

```
your_project/
├── lib/
├── android/
├── ios/
├── pubspec.yaml
└── codemagic.yaml   ← এখানে রাখো (project root)

```
## ✅ `codemagic.yaml` তৈরি করুন (change করার জায়গা marked)

```yaml
definitions:
  env_versions: &env_versions
    flutter: 3.38.5        # ← [CHANGE-1] তোমার Flutter SDK version (pubspec.yaml দেখো)
    xcode: latest
    cocoapods: default
  app_vars: &app_vars
    APP_ID: com.masicgeneration.app        # ← [CHANGE-2] তোমার App এর ID
    PACKAGE_NAME: com.masicgeneration.app  # ← [CHANGE-3] Android package name (AndroidManifest.xml)
  scripts:
    - &disable_spm_and_install
      name: Install Flutter dependencies
      script: |
        set -e
        flutter config --no-enable-swift-package-manager
        flutter pub get
    - &analyze_project
      name: Analyze project
      script: |
        set -e
        flutter analyze
    - &run_tests
      name: Run tests
      script: |
        set -e
        flutter test          # ← [CHANGE-4] test না থাকলে এই পুরো block comment করো
    - &install_pods
      name: Install CocoaPods
      script: |
        set -e
        find . -name "Podfile" -execdir pod install \;
    - &build_ios_ipa
      name: Build iOS IPA (TestFlight)
      script: |
        set -e
        flutter build ipa \
          --release \
          --build-number=$PROJECT_BUILD_NUMBER

workflows:
  flutter-ci:
    name: Masic Generation – Flutter CI    # ← [CHANGE-5] প্রজেক্টের নাম দাও
    instance_type: mac_mini_m2
    max_build_duration: 30
    environment:
      <<: *env_versions
      vars:
        <<: *app_vars
    cache:
      cache_paths:
        - $FLUTTER_ROOT/.pub-cache
        - $HOME/.pub-cache
    triggering:
      events:
        - push
        - pull_request
      branch_patterns:
        - pattern: "*"
          include: true
    scripts:
      - *disable_spm_and_install
      - *analyze_project
      - *run_tests

  ios-testflight:
    name: Masic Generation – iOS TestFlight  # ← [CHANGE-6] প্রজেক্টের নাম দাও
    instance_type: mac_mini_m2
    max_build_duration: 120
    integrations:
      app_store_connect: Codemagic  # ← [CHANGE-7] Codemagic dashboard এ App Store Connect integration এর নাম
    environment:
      <<: *env_versions
      ios_signing:
        distribution_type: app_store
        bundle_identifier: com.masicgeneration.app  # ← [CHANGE-8] iOS Bundle Identifier (Xcode এ দেখো)
      vars:
        <<: *app_vars
    cache:
      cache_paths:
        - $FLUTTER_ROOT/.pub-cache
        - $HOME/.pub-cache
        - $HOME/Library/Caches/CocoaPods
    triggering:
      events:
        - push
      branch_patterns:
        - pattern: main
          include: true
    scripts:
      - *disable_spm_and_install
      - *analyze_project
      - *run_tests
      - *install_pods
      - *build_ios_ipa
    artifacts:
      - build/ios/ipa/*.ipa
      - /tmp/xcodebuild_logs/*.log
      - flutter_drive.log
    publishing:
      app_store_connect:
        auth: integration
        submit_to_testflight: true

  android-release:
    name: Masic Generation – Android Release  # ← [CHANGE-9] প্রজেক্টের নাম দাও
    instance_type: mac_mini_m2
    max_build_duration: 60
    environment:
      <<: *env_versions
      android_signing:
        - keystore_reference  # ← [CHANGE-10] Codemagic dashboard এ keystore যে নামে upload করেছ
      vars:
        <<: *app_vars
    cache:
      cache_paths:
        - $FLUTTER_ROOT/.pub-cache
        - $HOME/.pub-cache
        - $HOME/.gradle/caches
    triggering:
      events:
        - push
      branch_patterns:
        - pattern: main
          include: true
    scripts:
      - *disable_spm_and_install
      - *analyze_project
      - *run_tests
      - name: Build Android App Bundle
        script: |
          set -e
          flutter build appbundle \
            --release \
            --build-number=$PROJECT_BUILD_NUMBER
    artifacts:
      - build/app/outputs/bundle/release/*.aab
      - build/app/outputs/flutter-apk/app-release.apk
      - flutter_drive.log
```

 
---


## 🗂️ ফাইল রাখবে

```
your_project/
├── lib/
├── android/
├── ios/
├── pubspec.yaml
├── codemagic.yaml                        ← project root এ
└── scripts/
    └── codemagic_ios_build.sh            ← scripts/ folder এ
```
 
---

## ✅ `scripts/codemagic_ios_build.sh` (change করার জায়গা marked)

```bash
#!/usr/bin/env bash
# Codemagic iOS TestFlight build – Flutter only (no Shorebird).
set -eo pipefail
 
# Generate export_options.plist from installed profiles
xcode-project use-profiles
 
EXPORT_PLIST="${HOME}/export_options.plist"
if [[ ! -f "${EXPORT_PLIST}" ]]; then
  echo "Error: ${EXPORT_PLIST} not found. Codemagic iOS signing must run before this step."
  exit 1
fi
 
# Auto-increment build number from App Store Connect
LATEST_BUILD=$(app-store-connect get-latest-build-number \
  --bundle-id com.masicgeneration.app \        # ← [CHANGE-11] তোমার iOS Bundle ID দাও
  --platform IOS \
  --pre-release 2>/dev/null || echo "1")      # ← [CHANGE-12] fallback build number
 
BUILD_NUM=$((LATEST_BUILD + 1))
echo "Using build number: ${BUILD_NUM}"
 
if command -v shorebird >/dev/null 2>&1; then
  echo "Note: Shorebird CLI is installed but this script uses flutter build ipa only."
fi
 
flutter build ipa \
  --release \
  --export-options-plist="${EXPORT_PLIST}" \
  --build-number="${BUILD_NUM}"
```
 
---
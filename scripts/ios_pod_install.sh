#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ -f ".fvmrc" ] || [ -f ".fvm/fvm_config.json" ]; then
  echo "==> Running fvm flutter pub get"
  fvm flutter pub get
else
  echo "==> Running flutter pub get"
  flutter pub get
fi

cd ios
echo "==> Running pod install"
pod install

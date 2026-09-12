#!/bin/bash
# Generate dSYM for Flutter native-asset frameworks (objective_c.framework).
# Xcode 16+ validates that every embedded framework has a matching dSYM in the
# archive; Flutter embeds native assets but may not copy their dSYMs automatically.
set -euo pipefail

FRAMEWORK_BINARY="${BUILT_PRODUCTS_DIR}/${FRAMEWORKS_FOLDER_PATH}/objective_c.framework/objective_c"
DSYM_OUTPUT="${DWARF_DSYM_FOLDER_PATH}/objective_c.framework.dSYM"

if [[ ! -f "${FRAMEWORK_BINARY}" ]]; then
  exit 0
fi

if [[ -d "${DSYM_OUTPUT}" ]]; then
  echo "objective_c.framework.dSYM already present"
  exit 0
fi

# Prefer a dSYM produced during `flutter build` if one exists next to native assets.
if [[ -n "${FLUTTER_APPLICATION_PATH:-}" && -n "${FLUTTER_BUILD_DIR:-}" ]]; then
  PREBUILT_DSYM="${FLUTTER_APPLICATION_PATH}/${FLUTTER_BUILD_DIR}/native_assets/ios/objective_c.framework.dSYM"
  if [[ -d "${PREBUILT_DSYM}" ]]; then
    echo "Copying prebuilt objective_c.framework.dSYM from native_assets"
    mkdir -p "${DWARF_DSYM_FOLDER_PATH}"
    rsync -a "${PREBUILT_DSYM}/" "${DSYM_OUTPUT}/"
    exit 0
  fi
fi

echo "Generating dSYM for objective_c.framework"
mkdir -p "${DWARF_DSYM_FOLDER_PATH}"
xcrun dsymutil "${FRAMEWORK_BINARY}" -o "${DSYM_OUTPUT}"

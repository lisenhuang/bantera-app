#!/bin/bash
# Re-sign dynamic .framework bundles inside the app so physical-device install succeeds.
# Fixes "invalid signature" (0xe8008014) on frameworks such as objective_c.framework from Dart packages.
set -euo pipefail

if [ -z "${EXPANDED_CODE_SIGN_IDENTITY:-}" ] || [ "${EXPANDED_CODE_SIGN_IDENTITY}" = "-" ]; then
  echo "resign_embedded_frameworks: no code sign identity; skip"
  exit 0
fi

FRAMEWORKS_DIR="${TARGET_BUILD_DIR}/${WRAPPER_NAME}/Frameworks"
if [ ! -d "${FRAMEWORKS_DIR}" ]; then
  exit 0
fi

# shellcheck disable=SC2044
for fw in "${FRAMEWORKS_DIR}"/*.framework; do
  [ -e "$fw" ] || continue
  echo "resign_embedded_frameworks: signing ${fw}"
  /usr/bin/codesign --force --sign "${EXPANDED_CODE_SIGN_IDENTITY}" \
    --preserve-metadata=identifier,entitlements,flags \
    --generate-entitlement-der \
    "${fw}"
done

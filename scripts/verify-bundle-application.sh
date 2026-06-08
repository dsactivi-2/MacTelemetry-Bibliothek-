#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_ROOT="$(mktemp -d)"
trap 'rm -rf "${TMP_ROOT}"' EXIT

SWIFTUI_COPY="${TMP_ROOT}/HostSwiftUIApp"
APPKIT_COPY="${TMP_ROOT}/HostAppKitApp"
MIXED_COPY="${TMP_ROOT}/HostMixedApp"

cp -R "${ROOT_DIR}/fixtures/HostSwiftUIApp" "${SWIFTUI_COPY}"
cp -R "${ROOT_DIR}/fixtures/HostAppKitApp" "${APPKIT_COPY}"
cp -R "${ROOT_DIR}/fixtures/HostMixedApp" "${MIXED_COPY}"

echo "[verify-apply] generate bootstrap bundle for swiftui copy"
bash "${ROOT_DIR}/bootstrap/install.sh" --project "${SWIFTUI_COPY}"
echo "[verify-apply] apply bundle for swiftui copy"
bash "${ROOT_DIR}/bootstrap/apply_bundle.sh" --project "${SWIFTUI_COPY}" --package-root "${ROOT_DIR}"
swift build --package-path "${SWIFTUI_COPY}"

echo "[verify-apply] generate bootstrap bundle for appkit copy"
bash "${ROOT_DIR}/bootstrap/install.sh" --project "${APPKIT_COPY}"
echo "[verify-apply] apply bundle for appkit copy"
bash "${ROOT_DIR}/bootstrap/apply_bundle.sh" --project "${APPKIT_COPY}" --package-root "${ROOT_DIR}"
swift build --package-path "${APPKIT_COPY}"

echo "[verify-apply] generate bootstrap bundle for mixed copy"
bash "${ROOT_DIR}/bootstrap/install.sh" --project "${MIXED_COPY}"
echo "[verify-apply] apply bundle for mixed copy"
bash "${ROOT_DIR}/bootstrap/apply_bundle.sh" --project "${MIXED_COPY}" --package-root "${ROOT_DIR}"
swift build --package-path "${MIXED_COPY}"

echo "PASS: bundle application verification"

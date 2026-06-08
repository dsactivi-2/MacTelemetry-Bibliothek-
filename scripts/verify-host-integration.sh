#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SWIFTUI_FIXTURE_DIR="${ROOT_DIR}/fixtures/HostSwiftUIApp"
APPKIT_FIXTURE_DIR="${ROOT_DIR}/fixtures/HostAppKitApp"
TMP_OUTPUT="$(mktemp)"
trap 'rm -f "${TMP_OUTPUT}"' EXIT

cd "${ROOT_DIR}"

echo "[verify] build host demo target"
swift build --product MacTelemetryHostDemo

echo "[verify] run host demo smoke log"
./.build/debug/MacTelemetryHostDemo --smoke-log

echo "[verify] inspect host demo unified log"
/usr/bin/log show --last 2m --info --style compact --predicate 'subsystem == "com.activi.MacTelemetryHostDemo"' > "${TMP_OUTPUT}"
grep -q 'app_started: App started' "${TMP_OUTPUT}"

echo "[verify] bootstrap dry-run against host fixture"
bash bootstrap/install.sh --project "${SWIFTUI_FIXTURE_DIR}" --dry-run > "${TMP_OUTPUT}"
grep -q 'CHECK: package-swift=present' "${TMP_OUTPUT}"
grep -q 'CHECK: swiftui-app-files=1' "${TMP_OUTPUT}"
grep -q 'CHECK: host-type=swiftui' "${TMP_OUTPUT}"
grep -q 'CHECK: preferred-entry-file=Sources/HostSwiftUIApp/HostSwiftUIApp.swift' "${TMP_OUTPUT}"
grep -q 'SCAFFOLD: integration-snippet-swiftui.txt' "${TMP_OUTPUT}"

echo "[verify] bootstrap apply-mode against host fixture"
rm -rf "${SWIFTUI_FIXTURE_DIR}/.mactelemetry-bootstrap"
bash bootstrap/install.sh --project "${SWIFTUI_FIXTURE_DIR}" > "${TMP_OUTPUT}"
test -f "${SWIFTUI_FIXTURE_DIR}/.mactelemetry-bootstrap/telemetry-config-example.txt"
test -f "${SWIFTUI_FIXTURE_DIR}/.mactelemetry-bootstrap/integration-snippet-swiftui.txt"
test -f "${SWIFTUI_FIXTURE_DIR}/.mactelemetry-bootstrap/NEXT_STEPS.md"
test -f "${SWIFTUI_FIXTURE_DIR}/.mactelemetry-bootstrap/INTEGRATION_GUIDE.md"
grep -q 'integration-snippet-swiftui.txt' "${SWIFTUI_FIXTURE_DIR}/.mactelemetry-bootstrap/NEXT_STEPS.md"
grep -q 'Sources/HostSwiftUIApp/HostSwiftUIApp.swift' "${SWIFTUI_FIXTURE_DIR}/.mactelemetry-bootstrap/INTEGRATION_GUIDE.md"

echo "[verify] bootstrap dry-run against appkit host fixture"
bash bootstrap/install.sh --project "${APPKIT_FIXTURE_DIR}" --dry-run > "${TMP_OUTPUT}"
grep -q 'CHECK: package-swift=present' "${TMP_OUTPUT}"
grep -q 'CHECK: swiftui-app-files=0' "${TMP_OUTPUT}"
grep -q 'CHECK: appkit-delegate-files=1' "${TMP_OUTPUT}"
grep -q 'CHECK: host-type=appkit' "${TMP_OUTPUT}"
grep -q 'CHECK: preferred-entry-file=Sources/HostAppKitApp/AppDelegate.swift' "${TMP_OUTPUT}"
grep -q 'SCAFFOLD: integration-snippet-appkit.txt' "${TMP_OUTPUT}"

echo "[verify] bootstrap apply-mode against appkit host fixture"
rm -rf "${APPKIT_FIXTURE_DIR}/.mactelemetry-bootstrap"
bash bootstrap/install.sh --project "${APPKIT_FIXTURE_DIR}" > "${TMP_OUTPUT}"
test -f "${APPKIT_FIXTURE_DIR}/.mactelemetry-bootstrap/telemetry-config-example.txt"
test -f "${APPKIT_FIXTURE_DIR}/.mactelemetry-bootstrap/integration-snippet-appkit.txt"
test -f "${APPKIT_FIXTURE_DIR}/.mactelemetry-bootstrap/NEXT_STEPS.md"
test -f "${APPKIT_FIXTURE_DIR}/.mactelemetry-bootstrap/INTEGRATION_GUIDE.md"
grep -q 'integration-snippet-appkit.txt' "${APPKIT_FIXTURE_DIR}/.mactelemetry-bootstrap/NEXT_STEPS.md"
grep -q 'Sources/HostAppKitApp/AppDelegate.swift' "${APPKIT_FIXTURE_DIR}/.mactelemetry-bootstrap/INTEGRATION_GUIDE.md"

echo "PASS: host integration verification"

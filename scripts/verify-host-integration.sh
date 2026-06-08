#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIXTURE_DIR="${ROOT_DIR}/fixtures/HostSwiftUIApp"
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
bash bootstrap/install.sh --project "${FIXTURE_DIR}" --dry-run > "${TMP_OUTPUT}"
grep -q 'CHECK: package-swift=present' "${TMP_OUTPUT}"
grep -q 'CHECK: swiftui-app-files=1' "${TMP_OUTPUT}"
grep -q 'CHECK: host-type=swiftui' "${TMP_OUTPUT}"
grep -q 'SCAFFOLD: integration-snippet-swiftui.txt' "${TMP_OUTPUT}"

echo "[verify] bootstrap apply-mode against host fixture"
rm -rf "${FIXTURE_DIR}/.mactelemetry-bootstrap"
bash bootstrap/install.sh --project "${FIXTURE_DIR}" > "${TMP_OUTPUT}"
test -f "${FIXTURE_DIR}/.mactelemetry-bootstrap/telemetry-config-example.txt"
test -f "${FIXTURE_DIR}/.mactelemetry-bootstrap/integration-snippet-swiftui.txt"
test -f "${FIXTURE_DIR}/.mactelemetry-bootstrap/NEXT_STEPS.md"
grep -q 'integration-snippet-swiftui.txt' "${FIXTURE_DIR}/.mactelemetry-bootstrap/NEXT_STEPS.md"

echo "PASS: host integration verification"

#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap/apply_bundle.sh --project <path> --package-root <path>
EOF
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

PROJECT_PATH=""
PACKAGE_ROOT=""
BUNDLE_DIR=".mactelemetry-bootstrap"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT_PATH="${2:-}"
      shift 2
      ;;
    --package-root)
      PACKAGE_ROOT="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "${PROJECT_PATH}" || -z "${PACKAGE_ROOT}" ]]; then
  usage >&2
  exit 1
fi

GUIDE_PATH="${PROJECT_PATH}/${BUNDLE_DIR}/INTEGRATION_GUIDE.md"

if [[ ! -f "${GUIDE_PATH}" ]]; then
  echo "Missing integration guide at ${GUIDE_PATH}" >&2
  exit 1
fi

HOST_TYPE="$(awk -F': ' '/^Host type:/ {print $2}' "${GUIDE_PATH}")"
PREFERRED_ENTRY_FILE="$(awk -F': ' '/^Preferred entry file:/ {print $2}' "${GUIDE_PATH}")"
APPKIT_DELEGATE_FILE="$(awk -F': ' '/^AppKit delegate file:/ {print $2}' "${GUIDE_PATH}" || true)"
PACKAGE_FILE="${PROJECT_PATH}/Package.swift"
PACKAGE_IDENTITY="$(basename "${PACKAGE_ROOT}" | tr '[:upper:]' '[:lower:]')"
XCODEPROJ_COUNT="$(find "${PROJECT_PATH}" -maxdepth 2 -name "*.xcodeproj" | wc -l | tr -d ' ')"
BUILD_SYSTEM="unknown"

if [[ -f "${PROJECT_PATH}/Package.swift" && "${XCODEPROJ_COUNT}" != "0" ]]; then
  BUILD_SYSTEM="hybrid"
elif [[ -f "${PROJECT_PATH}/Package.swift" ]]; then
  BUILD_SYSTEM="swiftpm"
elif [[ "${XCODEPROJ_COUNT}" != "0" ]]; then
  BUILD_SYSTEM="xcodeproj"
fi

PACKAGE_FILE="${PROJECT_PATH}/Package.swift"
PACKAGE_IDENTITY="$(basename "${PACKAGE_ROOT}" | tr '[:upper:]' '[:lower:]')"

escaped_package_root="${PACKAGE_ROOT//\//\\/}"

require_file() {
  local file_path="$1"

  if [[ ! -f "${file_path}" ]]; then
    echo "Expected file not found: ${file_path}" >&2
    exit 1
  fi
}

patch_package_file() {
  local package_file="$1"

  if ! grep -q 'MacTelemetryKit' "${package_file}"; then
    perl -0pi -e "s/(    ],\n)(    targets:)/\1    dependencies: [\n        .package(path: \"${escaped_package_root}\")\n    ],\n\2/s" "${package_file}"
  fi

  perl -0pi -e "s/\\.executableTarget\\(name: \"([^\"]+)\"\\)/.executableTarget(name: \"\\1\", dependencies: [.product(name: \"MacTelemetryKit\", package: \"${PACKAGE_IDENTITY}\"), .product(name: \"MacTelemetryKitUI\", package: \"${PACKAGE_IDENTITY}\")])/g" "${package_file}"
}

patch_swiftui_entry() {
  local file_path="$1"

  require_file "${file_path}"

  if ! grep -q 'import MacTelemetryKit' "${file_path}"; then
    perl -0pi -e 's/import SwiftUI\n/import SwiftUI\nimport MacTelemetryKit\nimport MacTelemetryKitUI\n/' "${file_path}"
  fi

  if ! grep -q 'TelemetryBootstrap.start' "${file_path}"; then
    perl -0pi -e 's/struct ([A-Za-z0-9_]+): App \{\n/struct \1: App {\n    private let telemetry = TelemetryBootstrap.start(subsystem: "com.example.app")\n/' "${file_path}"
  fi

  if ! grep -q 'TelemetryPanelView' "${file_path}"; then
    perl -0pi -e 's/Text\("([^"]+)"\)\n\s*\.padding\(\)/VStack {\n                Text("\1")\n                    .padding()\n                TelemetryPanelView(store: telemetry.store)\n            }/s' "${file_path}"
  fi

  if ! grep -q 'TelemetryPanelView(store: telemetry.store)' "${file_path}"; then
    echo "Failed to apply SwiftUI panel patch to ${file_path}" >&2
    exit 1
  fi
}

patch_appkit_delegate() {
  local file_path="$1"

  require_file "${file_path}"

  if ! grep -q 'import MacTelemetryKit' "${file_path}"; then
    perl -0pi -e 's/import AppKit\n/import AppKit\nimport MacTelemetryKit\n/' "${file_path}"
  fi

  if ! grep -q 'private var telemetryObserver: TelemetryAppKitObserver\?' "${file_path}"; then
    perl -0pi -e 's/final class AppDelegate: NSObject, NSApplicationDelegate \{\n/final class AppDelegate: NSObject, NSApplicationDelegate {\n    private var telemetryObserver: TelemetryAppKitObserver?\n/' "${file_path}"
  fi

  if ! grep -q 'TelemetryBootstrap.start' "${file_path}"; then
    perl -0pi -e 's/func applicationDidFinishLaunching\(_ notification: Notification\) \{\n/\@MainActor\n    func applicationDidFinishLaunching(_ notification: Notification) {\n        let telemetry = TelemetryBootstrap.start(subsystem: "com.example.app")\n        telemetryObserver = telemetry.attachAppKitObserver()\n/' "${file_path}"
  fi

  if ! grep -q 'telemetryObserver = telemetry.attachAppKitObserver()' "${file_path}"; then
    echo "Failed to apply AppKit observer patch to ${file_path}" >&2
    exit 1
  fi
}

if [[ "${BUILD_SYSTEM}" == "swiftpm" || "${BUILD_SYSTEM}" == "hybrid" ]]; then
  patch_package_file "${PACKAGE_FILE}"
fi

case "${HOST_TYPE}" in
  swiftui)
    patch_swiftui_entry "${PROJECT_PATH}/${PREFERRED_ENTRY_FILE}"
    ;;
  appkit)
    patch_appkit_delegate "${PROJECT_PATH}/${PREFERRED_ENTRY_FILE}"
    ;;
  mixed)
    patch_swiftui_entry "${PROJECT_PATH}/${PREFERRED_ENTRY_FILE}"
    if [[ -n "${APPKIT_DELEGATE_FILE}" ]]; then
      patch_appkit_delegate "${PROJECT_PATH}/${APPKIT_DELEGATE_FILE}"
    fi
    ;;
  *)
    echo "Unsupported host type for automatic bundle application: ${HOST_TYPE}" >&2
    exit 1
    ;;
esac

if [[ "${BUILD_SYSTEM}" == "xcodeproj" ]]; then
  echo "Applied source bundle to ${PROJECT_PATH}"
  echo "Manual step remaining: add MacTelemetryKit and MacTelemetryKitUI as Xcode package dependencies."
else
  echo "Applied bootstrap bundle to ${PROJECT_PATH}"
fi

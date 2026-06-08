#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="${SCRIPT_DIR}/../reports"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
REPORT_PATH="${REPORT_DIR}/install-${TIMESTAMP}.txt"
OUTPUT_DIR=".mactelemetry-bootstrap"

# shellcheck source=bootstrap/lib/report.sh
source "${SCRIPT_DIR}/lib/report.sh"

usage() {
  cat <<'EOF'
Usage: bootstrap/install.sh --project <path> [--dry-run]
EOF
}

if [[ "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

PROJECT_PATH=""
DRY_RUN="false"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project)
      PROJECT_PATH="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="true"
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

mkdir -p "${REPORT_DIR}"

find_first_match_count() {
  local base_path="$1"
  local pattern="$2"
  find "${base_path}" -name "${pattern}" | wc -l | tr -d ' '
}

find_delegate_count() {
  local base_path="$1"
  find "${base_path}" \( -name "*AppDelegate*.swift" -o -name "*Delegate.swift" \) | wc -l | tr -d ' '
}

detect_host_type() {
  local swiftui_count="$1"
  local delegate_count="$2"

  if [[ "${swiftui_count}" != "0" && "${delegate_count}" != "0" ]]; then
    echo "mixed"
  elif [[ "${swiftui_count}" != "0" ]]; then
    echo "swiftui"
  elif [[ "${delegate_count}" != "0" ]]; then
    echo "appkit"
  else
    echo "unknown"
  fi
}

copy_template() {
  local template_name="$1"
  local project_path="$2"
  mkdir -p "${project_path}/${OUTPUT_DIR}"
  cp "${SCRIPT_DIR}/templates/${template_name}" "${project_path}/${OUTPUT_DIR}/${template_name}"
}

write_next_steps() {
  local project_path="$1"
  local host_type="$2"

  mkdir -p "${project_path}/${OUTPUT_DIR}"

  case "${host_type}" in
    swiftui)
      cp "${SCRIPT_DIR}/templates/next-steps-swiftui.md" "${project_path}/${OUTPUT_DIR}/NEXT_STEPS.md"
      ;;
    appkit)
      cp "${SCRIPT_DIR}/templates/next-steps-appkit.md" "${project_path}/${OUTPUT_DIR}/NEXT_STEPS.md"
      ;;
    mixed)
      cp "${SCRIPT_DIR}/templates/next-steps-swiftui.md" "${project_path}/${OUTPUT_DIR}/NEXT_STEPS.md"
      {
        echo ""
        echo "Additional mixed-app note:"
        echo "- This project appears to contain both SwiftUI app entry points and AppKit delegate files."
        echo "- Review both integration snippets and choose the real startup path used by the host app."
      } >> "${project_path}/${OUTPUT_DIR}/NEXT_STEPS.md"
      ;;
    *)
      cat > "${project_path}/${OUTPUT_DIR}/NEXT_STEPS.md" <<'EOF'
1. Add `MacTelemetryKit` and `MacTelemetryKitUI` to your host app package or Xcode target.
2. Review the generated scaffold files in this directory and choose the snippet that matches your real startup path.
3. Add the bootstrap call manually in the host app entry point.
4. Add `TelemetryPanelView(store: telemetry.store)` to an internal debug-only surface.
5. Rebuild the host app and verify telemetry events with `/usr/bin/log stream` or `/usr/bin/log show`.
EOF
      ;;
  esac
}

if [[ -z "${PROJECT_PATH}" ]]; then
  write_report_header "${REPORT_PATH}" "FAIL" "<missing>" "${DRY_RUN}"
  append_report_line "${REPORT_PATH}" "CHECK: missing --project"
  cat "${REPORT_PATH}"
  exit 1
fi

if [[ ! -d "${PROJECT_PATH}" ]]; then
  write_report_header "${REPORT_PATH}" "FAIL" "${PROJECT_PATH}" "${DRY_RUN}"
  append_report_line "${REPORT_PATH}" "CHECK: project path not found"
  cat "${REPORT_PATH}"
  exit 1
fi

write_report_header "${REPORT_PATH}" "PASS" "${PROJECT_PATH}" "${DRY_RUN}"
append_report_line "${REPORT_PATH}" "CHECK: package-ready"
append_report_line "${REPORT_PATH}" "CHECK: no secrets emitted"

SWIFTUI_APP_COUNT="$(find_first_match_count "${PROJECT_PATH}" "*App.swift")"
APPKIT_DELEGATE_COUNT="$(find_delegate_count "${PROJECT_PATH}")"
HOST_TYPE="$(detect_host_type "${SWIFTUI_APP_COUNT}" "${APPKIT_DELEGATE_COUNT}")"

if [[ -f "${PROJECT_PATH}/Package.swift" ]]; then
  append_report_line "${REPORT_PATH}" "CHECK: package-swift=present"
else
  append_report_line "${REPORT_PATH}" "CHECK: package-swift=missing"
fi

if find "${PROJECT_PATH}" -maxdepth 2 -name "*.xcodeproj" | grep -q .; then
  append_report_line "${REPORT_PATH}" "CHECK: xcodeproj=present"
else
  append_report_line "${REPORT_PATH}" "CHECK: xcodeproj=missing"
fi

if [[ -d "${PROJECT_PATH}/Sources" ]]; then
  append_report_line "${REPORT_PATH}" "CHECK: sources-dir=present"
else
  append_report_line "${REPORT_PATH}" "CHECK: sources-dir=missing"
fi

append_report_line "${REPORT_PATH}" "CHECK: swiftui-app-files=${SWIFTUI_APP_COUNT}"
append_report_line "${REPORT_PATH}" "CHECK: appkit-delegate-files=${APPKIT_DELEGATE_COUNT}"
append_report_line "${REPORT_PATH}" "CHECK: host-type=${HOST_TYPE}"

append_report_line "${REPORT_PATH}" "SCAFFOLD: telemetry-config-example.txt"

if [[ "${SWIFTUI_APP_COUNT}" != "0" ]]; then
  append_report_line "${REPORT_PATH}" "SCAFFOLD: integration-snippet-swiftui.txt"
fi

if [[ "${APPKIT_DELEGATE_COUNT}" != "0" ]]; then
  append_report_line "${REPORT_PATH}" "SCAFFOLD: integration-snippet-appkit.txt"
fi

append_report_line "${REPORT_PATH}" "SCAFFOLD: NEXT_STEPS.md"

if [[ "${DRY_RUN}" != "true" ]]; then
  copy_template "telemetry-config-example.txt" "${PROJECT_PATH}"
  append_report_line "${REPORT_PATH}" "OUTPUT: ${OUTPUT_DIR}/telemetry-config-example.txt"

  if [[ "${SWIFTUI_APP_COUNT}" != "0" ]]; then
    copy_template "integration-snippet-swiftui.txt" "${PROJECT_PATH}"
    append_report_line "${REPORT_PATH}" "OUTPUT: ${OUTPUT_DIR}/integration-snippet-swiftui.txt"
  fi

  if [[ "${APPKIT_DELEGATE_COUNT}" != "0" ]]; then
    copy_template "integration-snippet-appkit.txt" "${PROJECT_PATH}"
    append_report_line "${REPORT_PATH}" "OUTPUT: ${OUTPUT_DIR}/integration-snippet-appkit.txt"
  fi

  write_next_steps "${PROJECT_PATH}" "${HOST_TYPE}"
  append_report_line "${REPORT_PATH}" "OUTPUT: ${OUTPUT_DIR}/NEXT_STEPS.md"
fi

cat "${REPORT_PATH}"

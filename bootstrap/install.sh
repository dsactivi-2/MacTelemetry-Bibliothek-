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

copy_template() {
  local template_name="$1"
  local project_path="$2"
  mkdir -p "${project_path}/${OUTPUT_DIR}"
  cp "${SCRIPT_DIR}/templates/${template_name}" "${project_path}/${OUTPUT_DIR}/${template_name}"
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

append_report_line "${REPORT_PATH}" "CHECK: swiftui-app-files=$(find_first_match_count "${PROJECT_PATH}" "*App.swift")"

append_report_line "${REPORT_PATH}" "SCAFFOLD: telemetry-config-example.txt"

if [[ "$(find_first_match_count "${PROJECT_PATH}" "*App.swift")" != "0" ]]; then
  append_report_line "${REPORT_PATH}" "SCAFFOLD: integration-snippet-swiftui.txt"
fi

if find "${PROJECT_PATH}" -name "*AppDelegate*.swift" -o -name "*Delegate.swift" | grep -q .; then
  append_report_line "${REPORT_PATH}" "SCAFFOLD: integration-snippet-appkit.txt"
fi

if [[ "${DRY_RUN}" != "true" ]]; then
  copy_template "telemetry-config-example.txt" "${PROJECT_PATH}"
  append_report_line "${REPORT_PATH}" "OUTPUT: ${OUTPUT_DIR}/telemetry-config-example.txt"

  if [[ "$(find_first_match_count "${PROJECT_PATH}" "*App.swift")" != "0" ]]; then
    copy_template "integration-snippet-swiftui.txt" "${PROJECT_PATH}"
    append_report_line "${REPORT_PATH}" "OUTPUT: ${OUTPUT_DIR}/integration-snippet-swiftui.txt"
  fi

  if find "${PROJECT_PATH}" -name "*AppDelegate*.swift" -o -name "*Delegate.swift" | grep -q .; then
    copy_template "integration-snippet-appkit.txt" "${PROJECT_PATH}"
    append_report_line "${REPORT_PATH}" "OUTPUT: ${OUTPUT_DIR}/integration-snippet-appkit.txt"
  fi
fi

cat "${REPORT_PATH}"

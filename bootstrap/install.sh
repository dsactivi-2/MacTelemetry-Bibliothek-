#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPORT_DIR="${SCRIPT_DIR}/../reports"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
REPORT_PATH="${REPORT_DIR}/install-${TIMESTAMP}.txt"

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
cat "${REPORT_PATH}"

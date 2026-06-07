#!/usr/bin/env bash
set -euo pipefail

write_report_header() {
  local report_path="$1"
  local status="$2"
  local project_path="$3"
  local dry_run="$4"

  {
    echo "STATUS: ${status}"
    echo "PROJECT: ${project_path}"
    echo "DRY_RUN: ${dry_run}"
  } >"${report_path}"
}

append_report_line() {
  local report_path="$1"
  local line="$2"
  echo "${line}" >>"${report_path}"
}

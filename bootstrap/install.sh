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

find_first_match_path() {
  local base_path="$1"
  local pattern="$2"
  local match
  match="$(find "${base_path}" -name "${pattern}" | sort | head -n 1)"
  if [[ -z "${match}" ]]; then
    return 1
  fi
  echo "${match#"${base_path}/"}"
}

find_first_delegate_path() {
  local base_path="$1"
  local match
  match="$(find "${base_path}" \( -name "*AppDelegate*.swift" -o -name "*Delegate.swift" \) | sort | head -n 1)"
  if [[ -z "${match}" ]]; then
    return 1
  fi
  echo "${match#"${base_path}/"}"
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

detect_preferred_entry_file() {
  local project_path="$1"
  local host_type="$2"

  case "${host_type}" in
    swiftui)
      find_first_match_path "${project_path}" "*App.swift" || true
      ;;
    appkit)
      find_first_delegate_path "${project_path}" || true
      ;;
    mixed)
      find_first_match_path "${project_path}" "*App.swift" || true
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

detect_build_system() {
  local has_package_swift="$1"
  local has_xcodeproj="$2"

  if [[ "${has_package_swift}" == "present" && "${has_xcodeproj}" == "present" ]]; then
    echo "hybrid"
  elif [[ "${has_package_swift}" == "present" ]]; then
    echo "swiftpm"
  elif [[ "${has_xcodeproj}" == "present" ]]; then
    echo "xcodeproj"
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

write_integration_guide() {
  local project_path="$1"
  local host_type="$2"
  local preferred_entry_file="$3"
  local swiftui_entry_file="$4"
  local delegate_entry_file="$5"

  mkdir -p "${project_path}/${OUTPUT_DIR}"

  {
    echo "# Integration Guide"
    echo ""
    echo "Host type: ${host_type}"
    echo "Preferred entry file: ${preferred_entry_file}"
    echo ""
    if [[ "${swiftui_entry_file}" != "none" ]]; then
      echo "SwiftUI entry file: ${swiftui_entry_file}"
    fi
    if [[ "${delegate_entry_file}" != "none" ]]; then
      echo "AppKit delegate file: ${delegate_entry_file}"
    fi
    echo ""
    echo "Generated scaffold files:"
    echo "- telemetry-config-example.txt"
    if [[ "${host_type}" == "swiftui" || "${host_type}" == "mixed" ]]; then
      echo "- integration-snippet-swiftui.txt"
    fi
    if [[ "${host_type}" == "appkit" || "${host_type}" == "mixed" ]]; then
      echo "- integration-snippet-appkit.txt"
    fi
    echo "- NEXT_STEPS.md"
    echo ""
    echo "Recommended manual sequence:"
    echo "1. Open the preferred entry file listed above."
    echo "2. Apply the matching integration snippet."
    echo "3. Keep the telemetry client alive for the app lifetime."
    echo "4. Add TelemetryPanelView to an internal debug-only surface."
    echo "5. Verify logs with /usr/bin/log show or /usr/bin/log stream."
  } > "${project_path}/${OUTPUT_DIR}/INTEGRATION_GUIDE.md"
}

write_dependency_setup() {
  local project_path="$1"
  local build_system="$2"

  mkdir -p "${project_path}/${OUTPUT_DIR}"

  case "${build_system}" in
    swiftpm)
      cat > "${project_path}/${OUTPUT_DIR}/DEPENDENCY_SETUP.md" <<'EOF'
# Dependency Setup

Swift Package Manager host:

1. Add this package as a dependency in the host `Package.swift`.
2. Link `MacTelemetryKit` and `MacTelemetryKitUI` to the executable target.
3. Rebuild the host package after applying the generated integration snippet.
EOF
      ;;
    xcodeproj)
      cat > "${project_path}/${OUTPUT_DIR}/DEPENDENCY_SETUP.md" <<'EOF'
# Dependency Setup

Xcode project host:

1. In Xcode, add the MacTelemetry package through "Add Package Dependencies...".
2. Link `MacTelemetryKit` and `MacTelemetryKitUI` to the app target.
3. Rebuild the app after applying the generated integration snippet.
EOF
      ;;
    hybrid)
      cat > "${project_path}/${OUTPUT_DIR}/DEPENDENCY_SETUP.md" <<'EOF'
# Dependency Setup

Hybrid host (Package.swift + xcodeproj detected):

1. Decide whether the package linkage is managed through SwiftPM manifests or directly in Xcode.
2. Add `MacTelemetryKit` and `MacTelemetryKitUI` through the chosen path.
3. Rebuild the app after applying the generated integration snippet.
EOF
      ;;
    *)
      cat > "${project_path}/${OUTPUT_DIR}/DEPENDENCY_SETUP.md" <<'EOF'
# Dependency Setup

Unknown host build system:

1. Add `MacTelemetryKit` and `MacTelemetryKitUI` using the host project's dependency management flow.
2. Rebuild the app after applying the generated integration snippet.
EOF
      ;;
  esac
}

write_patch_suggestion() {
  local project_path="$1"
  local host_type="$2"
  local preferred_entry_file="$3"
  local delegate_entry_file="$4"

  mkdir -p "${project_path}/${OUTPUT_DIR}"

  case "${host_type}" in
    swiftui)
      cat > "${project_path}/${OUTPUT_DIR}/PATCH_SUGGESTION.md" <<EOF
# Patch Suggestion

Target file: ${preferred_entry_file}

Add the bootstrap call and panel wiring in the app entry path:

\`\`\`swift
let telemetry = TelemetryBootstrap.start(subsystem: "com.example.app")
TelemetryPanelView(store: telemetry.store)
\`\`\`
EOF
      ;;
    appkit)
      cat > "${project_path}/${OUTPUT_DIR}/PATCH_SUGGESTION.md" <<EOF
# Patch Suggestion

Target file: ${preferred_entry_file}

Add the bootstrap call and retain the observer in the AppKit startup path:

\`\`\`swift
let telemetry = TelemetryBootstrap.start(subsystem: "com.example.app")
let observer = telemetry.attachAppKitObserver()
\`\`\`
EOF
      ;;
    mixed)
      cat > "${project_path}/${OUTPUT_DIR}/PATCH_SUGGESTION.md" <<EOF
# Patch Suggestion

Target file: ${preferred_entry_file}
Secondary file: ${delegate_entry_file}

Apply the primary SwiftUI bootstrap in the app entry file:

\`\`\`swift
let telemetry = TelemetryBootstrap.start(subsystem: "com.example.app")
TelemetryPanelView(store: telemetry.store)
\`\`\`

If the AppKit delegate is part of the real startup path, also attach the observer there:

\`\`\`swift
let observer = telemetry.attachAppKitObserver()
\`\`\`
EOF
      ;;
    *)
      cat > "${project_path}/${OUTPUT_DIR}/PATCH_SUGGESTION.md" <<EOF
# Patch Suggestion

Target file: ${preferred_entry_file}

Add the generated integration snippet to the host app entry path after confirming which startup file is authoritative.
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
SWIFTUI_ENTRY_FILE="$(find_first_match_path "${PROJECT_PATH}" "*App.swift" || true)"
APPKIT_DELEGATE_FILE="$(find_first_delegate_path "${PROJECT_PATH}" || true)"
PREFERRED_ENTRY_FILE="$(detect_preferred_entry_file "${PROJECT_PATH}" "${HOST_TYPE}")"
PACKAGE_SWIFT_STATUS="missing"
XCODEPROJ_STATUS="missing"

if [[ -z "${SWIFTUI_ENTRY_FILE}" ]]; then
  SWIFTUI_ENTRY_FILE="none"
fi

if [[ -z "${APPKIT_DELEGATE_FILE}" ]]; then
  APPKIT_DELEGATE_FILE="none"
fi

if [[ -z "${PREFERRED_ENTRY_FILE}" ]]; then
  PREFERRED_ENTRY_FILE="unknown"
fi

if [[ -f "${PROJECT_PATH}/Package.swift" ]]; then
  PACKAGE_SWIFT_STATUS="present"
fi
append_report_line "${REPORT_PATH}" "CHECK: package-swift=${PACKAGE_SWIFT_STATUS}"

if find "${PROJECT_PATH}" -maxdepth 2 -name "*.xcodeproj" | grep -q .; then
  XCODEPROJ_STATUS="present"
fi
append_report_line "${REPORT_PATH}" "CHECK: xcodeproj=${XCODEPROJ_STATUS}"

BUILD_SYSTEM="$(detect_build_system "${PACKAGE_SWIFT_STATUS}" "${XCODEPROJ_STATUS}")"

if [[ -d "${PROJECT_PATH}/Sources" ]]; then
  append_report_line "${REPORT_PATH}" "CHECK: sources-dir=present"
else
  append_report_line "${REPORT_PATH}" "CHECK: sources-dir=missing"
fi

append_report_line "${REPORT_PATH}" "CHECK: swiftui-app-files=${SWIFTUI_APP_COUNT}"
append_report_line "${REPORT_PATH}" "CHECK: appkit-delegate-files=${APPKIT_DELEGATE_COUNT}"
append_report_line "${REPORT_PATH}" "CHECK: host-type=${HOST_TYPE}"
append_report_line "${REPORT_PATH}" "CHECK: build-system=${BUILD_SYSTEM}"
append_report_line "${REPORT_PATH}" "CHECK: preferred-entry-file=${PREFERRED_ENTRY_FILE}"

append_report_line "${REPORT_PATH}" "SCAFFOLD: telemetry-config-example.txt"

if [[ "${SWIFTUI_APP_COUNT}" != "0" ]]; then
  append_report_line "${REPORT_PATH}" "SCAFFOLD: integration-snippet-swiftui.txt"
fi

if [[ "${APPKIT_DELEGATE_COUNT}" != "0" ]]; then
  append_report_line "${REPORT_PATH}" "SCAFFOLD: integration-snippet-appkit.txt"
fi

append_report_line "${REPORT_PATH}" "SCAFFOLD: NEXT_STEPS.md"
append_report_line "${REPORT_PATH}" "SCAFFOLD: INTEGRATION_GUIDE.md"
append_report_line "${REPORT_PATH}" "SCAFFOLD: DEPENDENCY_SETUP.md"
append_report_line "${REPORT_PATH}" "SCAFFOLD: PATCH_SUGGESTION.md"

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

  write_integration_guide "${PROJECT_PATH}" "${HOST_TYPE}" "${PREFERRED_ENTRY_FILE}" "${SWIFTUI_ENTRY_FILE}" "${APPKIT_DELEGATE_FILE}"
  append_report_line "${REPORT_PATH}" "OUTPUT: ${OUTPUT_DIR}/INTEGRATION_GUIDE.md"

  write_dependency_setup "${PROJECT_PATH}" "${BUILD_SYSTEM}"
  append_report_line "${REPORT_PATH}" "OUTPUT: ${OUTPUT_DIR}/DEPENDENCY_SETUP.md"

  write_patch_suggestion "${PROJECT_PATH}" "${HOST_TYPE}" "${PREFERRED_ENTRY_FILE}" "${APPKIT_DELEGATE_FILE}"
  append_report_line "${REPORT_PATH}" "OUTPUT: ${OUTPUT_DIR}/PATCH_SUGGESTION.md"
fi

cat "${REPORT_PATH}"

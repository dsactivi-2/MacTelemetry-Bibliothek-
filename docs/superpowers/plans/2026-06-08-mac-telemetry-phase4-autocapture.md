# MacTelemetry Phase 4 Auto-Capture Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a small, reusable auto-capture layer for `commands`, `navigation`, and `selection` so host apps can log common UI flows with very little code.

**Architecture:** Keep the new capture APIs as lightweight static helpers in `Sources/MacTelemetryKit/AutoCapture/`. Each helper should map directly onto the existing `TelemetryClient.log(...)` API, add safe metadata only, and stay simple enough for both SwiftUI and AppKit callers.

**Tech Stack:** Swift 5.10, XCTest, existing Swift Package targets

---

## Planned File Structure

### Create

- `Sources/MacTelemetryKit/AutoCapture/TelemetryCommand.swift`
- `Sources/MacTelemetryKit/AutoCapture/TelemetryNavigation.swift`
- `Sources/MacTelemetryKit/AutoCapture/TelemetrySelection.swift`
- `Tests/MacTelemetryKitTests/TelemetryCommandTests.swift`
- `Tests/MacTelemetryKitTests/TelemetryNavigationTests.swift`
- `Tests/MacTelemetryKitTests/TelemetrySelectionTests.swift`

### Modify

- `Sources/MacTelemetryDemo/TelemetryDemoApp.swift`

### Defer

- broad AppKit control observation
- automatic menu interception
- advanced selection diffing
- view-modifier based SwiftUI auto-instrumentation

## Task 1: Add command capture helper

**Files:**
- Create: `Tests/MacTelemetryKitTests/TelemetryCommandTests.swift`
- Create: `Sources/MacTelemetryKit/AutoCapture/TelemetryCommand.swift`

- [ ] **Step 1: Write the failing test**

Run:

```bash
swift test --filter TelemetryCommandTests
```

Expected: FAIL because `TelemetryCommand` does not exist yet.

- [ ] **Step 2: Implement minimal helper**

Add a static helper that logs:

- category: `.commands`
- configurable level
- safe metadata such as `command_group`

The helper should mirror the shape of `TelemetryAction.capture(...)` and run the provided body after logging.

- [ ] **Step 3: Verify the test passes**

Run:

```bash
swift test --filter TelemetryCommandTests
```

- [ ] **Step 4: Commit**

```bash
git add Sources/MacTelemetryKit Tests/MacTelemetryKitTests/TelemetryCommandTests.swift
git commit -m "feat: add command auto-capture helper"
```

## Task 2: Add navigation and selection capture helpers

**Files:**
- Create: `Tests/MacTelemetryKitTests/TelemetryNavigationTests.swift`
- Create: `Tests/MacTelemetryKitTests/TelemetrySelectionTests.swift`
- Create: `Sources/MacTelemetryKit/AutoCapture/TelemetryNavigation.swift`
- Create: `Sources/MacTelemetryKit/AutoCapture/TelemetrySelection.swift`

- [ ] **Step 1: Write the failing tests**

Run:

```bash
swift test --filter TelemetryNavigationTests
swift test --filter TelemetrySelectionTests
```

Expected: FAIL because the helpers do not exist yet.

- [ ] **Step 2: Implement minimal helpers**

Navigation helper:

- category: `.navigation`
- logs `from`, `to`, and optional `surface`

Selection helper:

- category: `.navigation`
- logs `selection`, optional `container`, and optional `selection_state`

Both helpers should log immediately and not try to infer UI state automatically.

- [ ] **Step 3: Verify the tests pass**

Run:

```bash
swift test --filter TelemetryNavigationTests
swift test --filter TelemetrySelectionTests
```

- [ ] **Step 4: Commit**

```bash
git add Sources/MacTelemetryKit Tests/MacTelemetryKitTests/TelemetryNavigationTests.swift Tests/MacTelemetryKitTests/TelemetrySelectionTests.swift
git commit -m "feat: add navigation and selection capture helpers"
```

## Task 3: Show the helpers in the demo app

**Files:**
- Modify: `Sources/MacTelemetryDemo/TelemetryDemoApp.swift`

- [ ] **Step 1: Add small demo triggers**

Use buttons or local state changes to emit:

- a command event
- a navigation transition event
- a selection event

Keep the demo explicit and testable rather than trying to auto-hook everything.

- [ ] **Step 2: Verify package-wide checks**

Run:

```bash
swift build
swift test
./.build/debug/MacTelemetryDemo --smoke-log
/usr/bin/log show --last 2m --info --style compact --predicate 'subsystem == "com.activi.MacTelemetryDemo"'
```

Expected:

- build passes
- all tests pass
- smoke log still shows `app_started`

- [ ] **Step 3: Commit**

```bash
git add Sources/MacTelemetryDemo
git commit -m "feat: extend demo with auto-capture flows"
```

## Self-Review

### Spec coverage

- command capture: covered
- navigation capture: covered
- selection capture: covered
- host app integration magic: intentionally deferred

### Placeholder scan

- No placeholder markers remain.

### Type consistency

- Public names remain aligned with the existing API family: `TelemetryAction`, `TelemetryCommand`, `TelemetryNavigation`, `TelemetrySelection`.

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-08-mac-telemetry-phase4-autocapture.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**

# MacTelemetry Phase 5 AppKit Observer Expansion Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand `TelemetryAppKitObserver` to capture a broader but still focused set of AppKit lifecycle and window notifications for classic macOS apps.

**Architecture:** Keep the expansion inside `TelemetryAppKitObserver` by registering a few additional notifications and mapping them directly to `TelemetryClient.log(...)`. Reuse the existing `window_id` safe metadata pattern and keep all event naming explicit rather than inferred.

**Tech Stack:** Swift 5.10, AppKit, XCTest, existing Swift Package targets

---

## Planned File Structure

### Modify

- `Sources/MacTelemetryKit/AppKit/TelemetryAppKitObserver.swift`
- `Sources/MacTelemetryDemo/TelemetryDemoApp.swift`
- `Tests/MacTelemetryKitTests/TelemetryAppKitObserverTests.swift`

### Create

- none

### Defer

- menu/responder interception
- generalized AppKit control instrumentation
- automatic extraction of real `NSWindow` identifiers from arbitrary host apps

## Task 1: Add failing observer tests for new notifications

**Files:**
- Modify: `Tests/MacTelemetryKitTests/TelemetryAppKitObserverTests.swift`

- [ ] **Step 1: Write failing tests**

Add tests for:

- `NSApplication.didBecomeActiveNotification`
- `NSApplication.didResignActiveNotification`
- `NSWindow.didResignKeyNotification`
- `NSWindow.willCloseNotification`
- `NSWindow.didMiniaturizeNotification`
- `NSWindow.didDeminiaturizeNotification`

Each test should post the notification through a local `NotificationCenter` and assert the expected event name, category, and safe metadata where relevant.

- [ ] **Step 2: Run the tests to verify they fail**

Run:

```bash
swift test --filter TelemetryAppKitObserverTests
```

Expected: FAIL because the observer does not yet register or handle the new notifications.

- [ ] **Step 3: Commit**

```bash
git add Tests/MacTelemetryKitTests/TelemetryAppKitObserverTests.swift
git commit -m "test: add appkit observer coverage for additional notifications"
```

## Task 2: Implement the AppKit observer expansion

**Files:**
- Modify: `Sources/MacTelemetryKit/AppKit/TelemetryAppKitObserver.swift`

- [ ] **Step 1: Implement minimal handlers**

Register and handle:

- `NSApplication.didBecomeActiveNotification` → `appkit_app_did_become_active` (`.lifecycle`)
- `NSApplication.didResignActiveNotification` → `appkit_app_did_resign_active` (`.lifecycle`)
- `NSWindow.didResignKeyNotification` → `window_did_resign_key` (`.windowing`)
- `NSWindow.willCloseNotification` → `window_will_close` (`.windowing`)
- `NSWindow.didMiniaturizeNotification` → `window_did_miniaturize` (`.windowing`)
- `NSWindow.didDeminiaturizeNotification` → `window_did_deminiaturize` (`.windowing`)

Window events should continue using `window_id` metadata with `"unknown"` fallback.

- [ ] **Step 2: Run the observer tests**

Run:

```bash
swift test --filter TelemetryAppKitObserverTests
```

Expected: PASS

- [ ] **Step 3: Commit**

```bash
git add Sources/MacTelemetryKit/AppKit/TelemetryAppKitObserver.swift
git commit -m "feat: expand appkit observer window lifecycle coverage"
```

## Task 3: Extend the demo path and verify package-wide behavior

**Files:**
- Modify: `Sources/MacTelemetryDemo/TelemetryDemoApp.swift`

- [ ] **Step 1: Add small demo guidance or triggers**

Keep the demo minimal. It should make it clear that AppKit observer coverage is active, but it does not need synthetic posting logic in production code.

- [ ] **Step 2: Run full verification**

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
git commit -m "feat: clarify demo appkit observer coverage"
```

## Self-Review

### Spec coverage

- app activation coverage: covered
- expanded window notifications: covered
- menu/responder instrumentation: intentionally deferred

### Placeholder scan

- No placeholder markers remain.

### Type consistency

- Existing naming stays aligned: `TelemetryAppKitObserver`, `window_id`, `.lifecycle`, `.windowing`.

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-08-mac-telemetry-phase5-appkit-observer.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**

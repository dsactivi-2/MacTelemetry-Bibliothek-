# Host Integration Demo Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a realistic host-app integration demo and a repeatable verification path for bootstrap-based host setup.

**Architecture:** Introduce a second executable target that consumes the package as a host app, a standalone host fixture for installer scans, and a shell verification script that exercises both paths.

**Tech Stack:** Swift 5.10, SwiftPM, AppKit, SwiftUI, Bash

---

## Planned File Structure

### Create

- `Sources/MacTelemetryHostDemo/TelemetryHostDemoApp.swift`
- `fixtures/HostSwiftUIApp/Package.swift`
- `fixtures/HostSwiftUIApp/Sources/HostSwiftUIApp/HostSwiftUIApp.swift`
- `scripts/verify-host-integration.sh`

### Modify

- `Package.swift`

### Defer

- automatic host project patching
- `.xcodeproj` editing
- installer-driven package linking

## Task 1: Add failing integration verification script

**Files:**
- Create: `scripts/verify-host-integration.sh`

- [ ] **Step 1: Write the failing verification script**

The script should expect:

- `swift build --product MacTelemetryHostDemo`
- `./.build/debug/MacTelemetryHostDemo --smoke-log`
- bootstrap checks against `fixtures/HostSwiftUIApp`

- [ ] **Step 2: Run it to verify it fails**

Run:

```bash
bash scripts/verify-host-integration.sh
```

Expected: FAIL because the host demo target and fixture do not exist yet.

## Task 2: Add the host demo executable target

**Files:**
- Modify: `Package.swift`
- Create: `Sources/MacTelemetryHostDemo/TelemetryHostDemoApp.swift`

- [ ] **Step 1: Implement a minimal host app target**

The host app should:

- bootstrap telemetry with its own subsystem
- log `app_started`
- support `--smoke-log`
- render `TelemetryPanelView`
- attach the AppKit observer

- [ ] **Step 2: Run host-demo build path**

Run:

```bash
swift build --product MacTelemetryHostDemo
./.build/debug/MacTelemetryHostDemo --smoke-log
```

Expected: PASS

## Task 3: Add the host fixture and make the verification script pass

**Files:**
- Create: `fixtures/HostSwiftUIApp/Package.swift`
- Create: `fixtures/HostSwiftUIApp/Sources/HostSwiftUIApp/HostSwiftUIApp.swift`
- Modify: `scripts/verify-host-integration.sh`

- [ ] **Step 1: Add a minimal host fixture project**

The fixture should look like a standalone SwiftUI macOS package app so `bootstrap/install.sh` can inspect it.

- [ ] **Step 2: Run the verification script**

Run:

```bash
bash scripts/verify-host-integration.sh
```

Expected: PASS with host demo log proof and fixture scaffold output.

## Self-Review

### Spec coverage

- second host app target: covered
- bootstrap fixture: covered
- repeatable verification script: covered

### Placeholder scan

- No placeholder markers remain.

### Type consistency

- Public package surfaces remain unchanged; only a new consumer target and fixture are added.

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-08-host-integration-demo.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**

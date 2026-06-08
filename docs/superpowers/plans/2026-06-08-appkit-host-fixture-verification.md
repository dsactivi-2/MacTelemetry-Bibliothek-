# AppKit Host Fixture Verification Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Extend host-integration verification so the bootstrap workflow is validated for both SwiftUI and AppKit-style macOS host projects.

**Architecture:** Add a second fixture project representing an AppKit host, then extend the existing verification script to exercise installer dry-run and apply-mode for both fixtures.

**Tech Stack:** Bash, SwiftPM fixtures, existing bootstrap installer

---

## Planned File Structure

### Create

- `fixtures/HostAppKitApp/Package.swift`
- `fixtures/HostAppKitApp/Sources/HostAppKitApp/main.swift`
- `fixtures/HostAppKitApp/Sources/HostAppKitApp/AppDelegate.swift`

### Modify

- `scripts/verify-host-integration.sh`

### Defer

- mixed-host fixture
- direct host-project mutation

## Task 1: Add failing verification for an AppKit fixture

**Files:**
- Modify: `scripts/verify-host-integration.sh`

- [ ] **Step 1: Extend the script**

Require:

- `CHECK: host-type=appkit`
- `CHECK: appkit-delegate-files=1`
- generated `integration-snippet-appkit.txt`
- generated `NEXT_STEPS.md` referencing the AppKit snippet

- [ ] **Step 2: Run it to verify it fails**

Run:

```bash
bash scripts/verify-host-integration.sh
```

Expected: FAIL because the AppKit fixture does not exist yet.

## Task 2: Add a minimal AppKit host fixture

**Files:**
- Create: `fixtures/HostAppKitApp/Package.swift`
- Create: `fixtures/HostAppKitApp/Sources/HostAppKitApp/main.swift`
- Create: `fixtures/HostAppKitApp/Sources/HostAppKitApp/AppDelegate.swift`

- [ ] **Step 1: Add the fixture**

It should look like a small standalone AppKit package app and include an `AppDelegate.swift` file for installer detection.

- [ ] **Step 2: Run the script again**

Run:

```bash
bash scripts/verify-host-integration.sh
```

Expected: PASS

## Task 3: Run full verification

- [ ] **Step 1: Run package-wide checks**

Run:

```bash
swift build
swift test
bash scripts/verify-host-integration.sh
```

Expected: PASS

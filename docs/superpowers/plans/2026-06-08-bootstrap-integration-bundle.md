# Bootstrap Integration Bundle Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Upgrade `bootstrap/install.sh` so it produces a clearer, safer host-integration bundle with concrete next steps based on detected host-app structure.

**Architecture:** Keep all changes inside the existing shell-based bootstrap flow. Improve host detection, emit richer `CHECK:` lines, and generate additive bundle files under `.mactelemetry-bootstrap/` such as `NEXT_STEPS.md`.

**Tech Stack:** Bash, POSIX utilities, existing bootstrap templates and fixture project

---

## Planned File Structure

### Create

- `bootstrap/templates/next-steps-swiftui.md`
- `bootstrap/templates/next-steps-appkit.md`

### Modify

- `bootstrap/install.sh`
- `scripts/verify-host-integration.sh`

### Defer

- direct host-file mutation
- `.xcodeproj` editing
- automatic package dependency insertion

## Task 1: Add failing verification for richer bootstrap output

**Files:**
- Modify: `scripts/verify-host-integration.sh`

- [ ] **Step 1: Extend the verification script**

Expect the bootstrap flow to prove:

- host type is detected
- `NEXT_STEPS.md` is generated in apply mode
- the generated next-steps file references the right integration snippet

- [ ] **Step 2: Run it to verify it fails**

Run:

```bash
bash scripts/verify-host-integration.sh
```

Expected: FAIL because the installer does not yet emit host-type checks or generate `NEXT_STEPS.md`.

## Task 2: Implement host-type detection and bundle generation

**Files:**
- Modify: `bootstrap/install.sh`
- Create: `bootstrap/templates/next-steps-swiftui.md`
- Create: `bootstrap/templates/next-steps-appkit.md`

- [ ] **Step 1: Implement detection**

The installer should detect:

- number of `*App.swift` files
- presence of `*AppDelegate*.swift` or `*Delegate.swift`
- derived host type: `swiftui`, `appkit`, `mixed`, or `unknown`

It should emit:

- `CHECK: host-type=<value>`
- `CHECK: appkit-delegate-files=<count>`

- [ ] **Step 2: Implement bundle output**

On apply-mode execution, generate:

- existing scaffold snippets
- `NEXT_STEPS.md`

The next-steps file should point at the generated snippet names and describe the safe manual integration sequence for the detected host type.

- [ ] **Step 3: Run the verification script**

Run:

```bash
bash scripts/verify-host-integration.sh
```

Expected: PASS

## Task 3: Run full verification and capture the improved workflow

**Files:**
- Modify as needed: `scripts/verify-host-integration.sh`

- [ ] **Step 1: Run package-wide verification**

Run:

```bash
swift build
swift test
bash scripts/verify-host-integration.sh
```

Expected: PASS

## Self-Review

### Spec coverage

- richer host detection: covered
- concrete next-steps bundle: covered
- destructive host changes: intentionally deferred

### Placeholder scan

- No placeholder markers remain.

### Type consistency

- Bootstrap terminology stays consistent: `CHECK`, `SCAFFOLD`, `OUTPUT`, `host-type`.

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-08-bootstrap-integration-bundle.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**

# MacTelemetry Phase 3 Bootstrap Expansion Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expand `bootstrap/install.sh` from a minimal dry-run checker into a practical integration helper that inspects a host project, reports integration gaps, and generates additive scaffold files safely.

**Architecture:** Keep the installer in shell. Move repeatable checks into small helper functions, generate timestamped reports, and prefer additive scaffold output over editing host project files directly. The script should remain safe-by-default and dry-run-first.

**Tech Stack:** Bash, POSIX utilities, macOS shell environment

---

## Planned File Structure

### Create

- `bootstrap/templates/telemetry-config-example.txt`
- `bootstrap/templates/integration-snippet-swiftui.txt`
- `bootstrap/templates/integration-snippet-appkit.txt`

### Modify

- `bootstrap/install.sh`
- `bootstrap/lib/report.sh`

### Defer

- direct mutation of `.xcodeproj`
- dependency injection into arbitrary target graphs
- automatic package linking in host projects

## Task 1: Add structured host-project inspection

**Files:**
- Modify: `bootstrap/install.sh`
- Modify: `bootstrap/lib/report.sh`

- [ ] **Step 1: Write the failing shell check**

Run:

```bash
bash bootstrap/install.sh --project . --dry-run | grep 'CHECK: package-swift'
```

Expected: FAIL because the script does not yet report structured host-project checks.

- [ ] **Step 2: Implement minimal structured inspection**

Add checks for:

- `Package.swift` presence
- `.xcodeproj` presence
- existing `Sources/` directory
- existing `App.swift` files

The script should emit report lines like:

```text
CHECK: package-swift=present
CHECK: xcodeproj=missing
CHECK: sources-dir=present
CHECK: swiftui-app-files=1
```

- [ ] **Step 3: Run the check to verify it passes**

Run:

```bash
bash bootstrap/install.sh --project . --dry-run
```

Expected: PASS with the new structured `CHECK:` lines.

- [ ] **Step 4: Commit**

```bash
git add bootstrap
git commit -m "feat: add bootstrap project inspection"
```

## Task 2: Add scaffold template output in dry-run mode

**Files:**
- Create: `bootstrap/templates/telemetry-config-example.txt`
- Create: `bootstrap/templates/integration-snippet-swiftui.txt`
- Create: `bootstrap/templates/integration-snippet-appkit.txt`
- Modify: `bootstrap/install.sh`

- [ ] **Step 1: Write the failing scaffold check**

Run:

```bash
bash bootstrap/install.sh --project . --dry-run | grep 'SCAFFOLD:'
```

Expected: FAIL because no scaffold suggestions are emitted yet.

- [ ] **Step 2: Implement additive scaffold reporting**

The script should:

- point to the example config template
- recommend the SwiftUI snippet when `@main ... App` exists
- recommend the AppKit snippet when an app delegate file pattern is found

Expected report lines:

```text
SCAFFOLD: telemetry-config-example.txt
SCAFFOLD: integration-snippet-swiftui.txt
```

- [ ] **Step 3: Run the dry-run again**

Run:

```bash
bash bootstrap/install.sh --project . --dry-run
```

Expected: PASS with `SCAFFOLD:` lines.

- [ ] **Step 4: Commit**

```bash
git add bootstrap
git commit -m "feat: add bootstrap scaffold suggestions"
```

## Task 3: Add target output directory generation

**Files:**
- Modify: `bootstrap/install.sh`

- [ ] **Step 1: Write the failing apply-mode check**

Run:

```bash
rm -rf .mactelemetry-bootstrap
bash bootstrap/install.sh --project . | grep '.mactelemetry-bootstrap'
```

Expected: FAIL because the script does not yet generate output files for non-dry-run execution.

- [ ] **Step 2: Implement safe additive generation**

On non-dry-run execution the script should create:

- `.mactelemetry-bootstrap/telemetry-config-example.txt`
- `.mactelemetry-bootstrap/integration-snippet-swiftui.txt`
- `.mactelemetry-bootstrap/integration-snippet-appkit.txt`

No destructive edits. No touching project files directly.

- [ ] **Step 3: Run verification**

Run:

```bash
rm -rf .mactelemetry-bootstrap
bash bootstrap/install.sh --project .
find .mactelemetry-bootstrap -maxdepth 1 -type f | sort
```

Expected: generated scaffold files exist.

- [ ] **Step 4: Commit**

```bash
git add bootstrap .gitignore
git commit -m "feat: generate bootstrap scaffold output"
```

## Self-Review

### Spec coverage

- guarded script: covered
- environment verification: covered
- additive scaffold generation: covered
- destructive project editing: intentionally deferred

### Placeholder scan

- No placeholder markers remain.

### Type consistency

- Script terminology remains consistent: `CHECK`, `SCAFFOLD`, `PASS`, `FAIL`.

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-08-mac-telemetry-phase3-bootstrap.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**

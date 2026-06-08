# MacTelemetry Host Integration Demo Design

**Goal:** Add a realistic example of how a separate macOS host app would consume `MacTelemetryKit`, and make that flow verifiable with a repeatable script.

## Scope

- Add a second executable target that behaves like a simple host app using the published package surfaces.
- Add a small fixture directory that represents a standalone SwiftUI host project for `bootstrap/install.sh`.
- Add one repeatable verification script that checks the host demo build/run path and the bootstrap dry-run path.

## Out of Scope

- editing arbitrary host project files automatically
- `.xcodeproj` mutation
- dependency injection into external target graphs
- broad installer automation beyond inspection and scaffold output

## Recommended Approach

### Option 1: Host demo target only

Fastest, but it does not exercise the bootstrap script against a realistic host-project layout.

### Option 2: Fixture project only

Good for installer checks, but it does not prove the package is being consumed by a second macOS app target.

### Option 3: Combined host demo target + fixture + verification script

Recommended. This gives one real app-consumer path and one installer path, both runnable from the repo without introducing risky project mutation.

## Design

### Host app target

Add `MacTelemetryHostDemo` as a second executable SwiftPM target. It should:

- import `MacTelemetryKit` and `MacTelemetryKitUI`
- create telemetry via `TelemetryBootstrap.start(...)`
- attach the AppKit observer
- render `TelemetryPanelView(store: telemetry.store)`
- emit a host-specific `app_started` lifecycle event
- support a `--smoke-log` mode for scriptable log verification

This target should feel like a consuming app, not like an internal framework test.

### Host fixture

Add a small standalone folder that looks like a host SwiftUI package project:

- its own `Package.swift`
- `Sources/<AppName>/<AppName>.swift`

This fixture exists only so `bootstrap/install.sh` can scan a realistic host layout during dry-run and scaffold generation.

### Verification

Add a repo-local shell script that:

1. builds `MacTelemetryHostDemo`
2. runs `MacTelemetryHostDemo --smoke-log`
3. verifies the unified log for the host demo subsystem
4. runs `bootstrap/install.sh --project <fixture> --dry-run`
5. runs `bootstrap/install.sh --project <fixture>`
6. verifies expected scaffold output exists under the fixture

## Success Criteria

- `swift run MacTelemetryHostDemo --smoke-log` works
- host demo emits a unified log entry under its own subsystem
- bootstrap dry-run against the fixture reports the expected `CHECK:` and `SCAFFOLD:` lines
- bootstrap apply-mode generates additive scaffold files for the fixture
- verification is repeatable from one shell script

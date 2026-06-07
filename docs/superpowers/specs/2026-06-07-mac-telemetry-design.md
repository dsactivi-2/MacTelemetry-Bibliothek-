# MacTelemetry Design

## Goal

Build a reusable macOS telemetry starter that can be embedded into arbitrary apps with low integration effort.

The solution should provide:

- a reusable `Swift Package` as the stable implementation core
- a bootstrap script for fast installation into existing projects
- an embedded debug UI inside the host macOS app
- low-code standard event capture out of the box
- compatibility with both `SwiftUI` and `AppKit`

## Non-Goals

- no iOS, iPadOS, tvOS, or watchOS support in the first version
- no external backend, analytics SaaS, or network transport in the first version
- no secret capture, payload dumps, or document-content logging
- no invasive runtime swizzling as a primary mechanism
- no fully automatic modification of every possible Xcode project shape
- no undo history for `Clear` in the MVP
- no multi-select or inline event expansion in the MVP

## Product Shape

The project consists of three deliverables:

1. `MacTelemetryKit`
   A reusable Swift package containing the event model, logger integration, in-memory session store, filtering, export, and public APIs.
2. `TelemetryPanel`
   A built-in macOS debug UI that the host app can embed in a window, sheet, settings pane, or debug surface.
3. `bootstrap/install.sh`
   A guarded script that prepares a host project for integration by generating starter files and setup instructions, while avoiding destructive project rewrites.

## Architecture

### 1. Package Core

`MacTelemetryKit` is the source of truth for all telemetry behavior.

Core responsibilities:

- define stable telemetry event types
- emit high-signal unified logs via `OSLog.Logger`
- maintain a local in-memory event buffer for the current app session
- expose APIs for manual event logging
- expose adapters for standard auto-capture flows
- export a filtered local trace file for debugging sessions

The package should be usable even without the debug UI.

### 2. Auto-Capture Layer

The package provides opt-in auto-capture for common macOS app events with minimal app code.

SwiftUI coverage:

- app/session start
- scene phase changes
- window or scene appearance hooks where available
- navigation or selection changes through provided wrappers/modifiers
- command invocation through provided helper APIs
- explicit action wrappers for buttons and menu actions

AppKit coverage:

- app launch and termination notifications
- window open, become key, resign key, close
- menu and command wrappers
- selection-change notifications where host code uses provided adapters
- explicit action wrappers for controls

Out-of-the-box means `TelemetryBootstrap.start(...)` should enable a meaningful baseline without the app author instrumenting every event manually. It does not mean magic capture of all possible control actions in all app architectures.

### 3. Embedded Debug UI

The host app can embed a telemetry panel powered by the package.

MVP panel scope:

- three-column macOS utility layout: filter sidebar, event list, detail pane
- live event list
- filter by category
- filter by level
- filter by source framework
- text search
- session summary counters
- export trace action
- clear local session buffer action
- empty, no-results, error, and live-session states

The panel is intended for local development and QA, not end users.

### 4. Bootstrap Script

The script is a convenience layer, not the core product.

Responsibilities:

- verify required files and environment before making changes
- create a small host integration scaffold if missing
- generate a config file or example integration snippet
- write timestamped logs and a structured pass/warn/fail report
- avoid exposing secrets
- stop on ambiguity instead of guessing

The script should prefer safe additive changes. If project automation is too risky, it should fall back to generating files plus explicit next steps instead of force-patching the Xcode project.

## Public API Direction

The initial API should optimize for low friction.

Likely entry points:

- `TelemetryBootstrap.start(...)`
- `Telemetry.log(...)`
- `Telemetry.action(...)`
- `TelemetryPanelView`
- `TelemetryExportService`

Configuration should include:

- subsystem override
- enabled categories
- minimum log level for local buffer
- whether auto-capture is enabled
- whether panel features are enabled

## Event Model

Each event should have a small, stable schema:

- timestamp
- level
- category
- name
- message
- source framework (`SwiftUI`, `AppKit`, `Manual`)
- session identifier
- event identifier
- optional safe metadata dictionary
- optional duration or latency
- optional error code

Metadata rules:

- no secrets
- no tokens
- no raw document contents
- no personally identifying payloads by default
- no unsafe file paths in default examples or preview content
- identifiers must be intentionally marked safe before logging

## Logging Strategy

Use `OSLog.Logger` as the primary sink.

Rules:

- `info` for durable high-signal lifecycle and action events
- `debug` only for noisy local diagnostics
- `error` for user-visible or flow-breaking failures
- stable subsystem/category naming so `log stream` predicates stay reusable

Default categories:

- `Lifecycle`
- `Windowing`
- `Navigation`
- `Commands`
- `Actions`
- `Errors`

## UI Layout Direction

Use a native macOS inspector or utility visual language, not a web dashboard.

MVP layout constraints:

- left filter sidebar fixed at `260px`
- center event list flexible with `min-width: 420px`
- right detail pane fixed at `360px`
- event table row height `32px`
- body type `13pt`, monospace metadata and IDs `11pt`, header `15pt semibold`
- breakpoints:
  - `< 900px`: hide right detail pane and show selected event detail as sheet or expandable panel
  - `900px-1300px`: keep all three columns with reduced center flexibility
  - `> 1300px`: full three-column layout

The right detail pane is the only detail surface in the MVP.

## Integration Model

### SwiftUI Host

Expected integration:

- add package dependency
- call bootstrap at app startup
- place `TelemetryPanelView` in a debug route, settings pane, or dedicated window
- optionally adopt helper wrappers/modifiers for richer action capture

### AppKit Host

Expected integration:

- add package dependency
- call bootstrap in app delegate startup path
- register window lifecycle observers or use package-provided delegate adapters
- open the panel from an existing debug menu, preferences surface, or developer window

## Testing Strategy

The project should follow TDD during implementation.

Initial test layers:

- unit tests for event model, filtering, session buffer, export formatting
- unit tests for bootstrap configuration behavior
- unit tests for auto-capture adapters where deterministic
- lightweight UI tests for the telemetry panel if a host demo target exists
- manual verification using `log stream` predicates against a demo macOS app

## Demo and Verification

The repo should include a small demo macOS app that proves the package works in practice.

The demo should:

- start telemetry automatically
- expose the embedded panel
- trigger representative SwiftUI and AppKit events
- support manual verification through unified logs

Verification artifacts to produce during implementation:

- exact `log stream` predicate
- one or two representative log lines
- optional saved local trace file for longer sessions

## Delivery Phases

### Phase 1

- package skeleton
- event model
- logger integration
- session buffer
- telemetry panel baseline
- SwiftUI demo integration

### Phase 2

- AppKit adapters
- richer auto-capture wrappers
- export polish
- bootstrap script

### Phase 3

- project-integration hardening
- more panel filters and UX improvements
- documentation and examples

## Risks and Constraints

- automatic Xcode project mutation is brittle, so the script must fail safely
- some actions cannot be captured generically without explicit wrapper adoption
- AppKit and SwiftUI lifecycle models differ, so the API surface must avoid pretending they are identical
- the embedded panel must not become a production dependency by accident
- event throughput may exceed what a plain SwiftUI list handles smoothly, so the list abstraction must be replaceable

## Recommended First Implementation Slice

Start with the smallest end-to-end proof:

- one Swift package target
- one session buffer
- one `Logger` abstraction
- one SwiftUI panel
- one demo app
- one verified `log stream` flow

This provides a concrete backbone before broadening AppKit coverage and installer automation.

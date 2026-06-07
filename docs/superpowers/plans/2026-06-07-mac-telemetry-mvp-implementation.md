# MacTelemetry MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Phase 1 MacTelemetry MVP: a Swift package with event modeling, unified logging, an in-memory session store, a SwiftUI telemetry panel, and a demo macOS app that proves logs and UI work end to end.

**Architecture:** Use a Swift Package as the system of record. Keep core telemetry types and services in `MacTelemetryKit`, keep the UI in a small set of focused SwiftUI files, and host the MVP demo in a package executable target so the whole project stays in one repo with `swift build` and `swift test`.

**Tech Stack:** Swift Package Manager, SwiftUI, Observation, OSLog, XCTest

---

## Planned File Structure

### Create

- `Package.swift`
- `Sources/MacTelemetryKit/TelemetryLevel.swift`
- `Sources/MacTelemetryKit/TelemetryCategory.swift`
- `Sources/MacTelemetryKit/TelemetrySource.swift`
- `Sources/MacTelemetryKit/TelemetryEvent.swift`
- `Sources/MacTelemetryKit/TelemetryStore.swift`
- `Sources/MacTelemetryKit/TelemetryFilter.swift`
- `Sources/MacTelemetryKit/TelemetryLogger.swift`
- `Sources/MacTelemetryKit/TelemetryExportService.swift`
- `Sources/MacTelemetryKit/TelemetryConfiguration.swift`
- `Sources/MacTelemetryKit/TelemetryBootstrap.swift`
- `Sources/MacTelemetryKit/TelemetryClient.swift`
- `Sources/MacTelemetryKitUI/TelemetryPanelViewModel.swift`
- `Sources/MacTelemetryKitUI/TelemetryPanelView.swift`
- `Sources/MacTelemetryKitUI/TelemetryPanelComponents.swift`
- `Sources/MacTelemetryDemo/TelemetryDemoApp.swift`
- `Tests/MacTelemetryKitTests/TelemetryEventTests.swift`
- `Tests/MacTelemetryKitTests/TelemetryStoreTests.swift`
- `Tests/MacTelemetryKitTests/TelemetryExportServiceTests.swift`
- `Tests/MacTelemetryKitUITests/TelemetryPanelViewModelTests.swift`

### Modify

- `docs/superpowers/specs/2026-06-07-mac-telemetry-design.md`
  This is already updated and serves as the implementation reference.

### Defer To Phase 2

- `bootstrap/install.sh`
- `Sources/MacTelemetryKit/AppKit/…`
- `Sources/MacTelemetryKit/AutoCapture/…`

## Task 1: Create the package skeleton and prove test execution

**Files:**
- Create: `Package.swift`
- Create: `Tests/MacTelemetryKitTests/TelemetryEventTests.swift`

- [ ] **Step 1: Write the failing package-level test**

```swift
import XCTest
@testable import MacTelemetryKit

final class TelemetryEventTests: XCTestCase {
    func test_event_initializes_with_required_fields() {
        let event = TelemetryEvent(
            level: .info,
            category: .lifecycle,
            name: "app_started",
            message: "App started",
            source: .manual
        )

        XCTAssertEqual(event.level, .info)
        XCTAssertEqual(event.category, .lifecycle)
        XCTAssertEqual(event.name, "app_started")
        XCTAssertEqual(event.message, "App started")
        XCTAssertEqual(event.source, .manual)
        XCTAssertFalse(event.sessionID.isEmpty)
        XCTAssertFalse(event.eventID.isEmpty)
    }
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `swift test --filter TelemetryEventTests/test_event_initializes_with_required_fields`

Expected: FAIL because `Package.swift` and the `MacTelemetryKit` module do not exist yet.

- [ ] **Step 3: Write the minimal package manifest and placeholder module**

```swift
// Package.swift
// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MacTelemetry",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "MacTelemetryKit", targets: ["MacTelemetryKit"]),
        .library(name: "MacTelemetryKitUI", targets: ["MacTelemetryKitUI"]),
        .executable(name: "MacTelemetryDemo", targets: ["MacTelemetryDemo"])
    ],
    targets: [
        .target(name: "MacTelemetryKit"),
        .target(
            name: "MacTelemetryKitUI",
            dependencies: ["MacTelemetryKit"]
        ),
        .executableTarget(
            name: "MacTelemetryDemo",
            dependencies: ["MacTelemetryKit", "MacTelemetryKitUI"]
        ),
        .testTarget(
            name: "MacTelemetryKitTests",
            dependencies: ["MacTelemetryKit"]
        ),
        .testTarget(
            name: "MacTelemetryKitUITests",
            dependencies: ["MacTelemetryKit", "MacTelemetryKitUI"]
        )
    ]
)
```

```swift
// Sources/MacTelemetryKit/TelemetryEvent.swift
import Foundation

public struct TelemetryEvent: Sendable, Equatable {
    public let level: TelemetryLevel
    public let category: TelemetryCategory
    public let name: String
    public let message: String
    public let source: TelemetrySource
    public let sessionID: String
    public let eventID: String

    public init(
        level: TelemetryLevel,
        category: TelemetryCategory,
        name: String,
        message: String,
        source: TelemetrySource,
        sessionID: String = UUID().uuidString.lowercased(),
        eventID: String = "evt_\(UUID().uuidString.lowercased())"
    ) {
        self.level = level
        self.category = category
        self.name = name
        self.message = message
        self.source = source
        self.sessionID = sessionID
        self.eventID = eventID
    }
}
```

```swift
// Sources/MacTelemetryKit/TelemetryLevel.swift
public enum TelemetryLevel: String, Sendable, Equatable, CaseIterable {
    case info
    case warning
    case error
    case debug
}
```

```swift
// Sources/MacTelemetryKit/TelemetryCategory.swift
public enum TelemetryCategory: String, Sendable, Equatable, CaseIterable {
    case lifecycle
    case windowing
    case navigation
    case commands
    case actions
    case errors
}
```

```swift
// Sources/MacTelemetryKit/TelemetrySource.swift
public enum TelemetrySource: String, Sendable, Equatable, CaseIterable {
    case swiftUI = "SwiftUI"
    case appKit = "AppKit"
    case manual = "Manual"
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `swift test --filter TelemetryEventTests/test_event_initializes_with_required_fields`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Package.swift Sources/MacTelemetryKit Tests/MacTelemetryKitTests/TelemetryEventTests.swift
git commit -m "feat: scaffold MacTelemetry package"
```

## Task 2: Implement the full event model and session store

**Files:**
- Modify: `Sources/MacTelemetryKit/TelemetryEvent.swift`
- Create: `Sources/MacTelemetryKit/TelemetryStore.swift`
- Create: `Sources/MacTelemetryKit/TelemetryFilter.swift`
- Test: `Tests/MacTelemetryKitTests/TelemetryStoreTests.swift`

- [ ] **Step 1: Write the failing store tests**

```swift
import XCTest
@testable import MacTelemetryKit

final class TelemetryStoreTests: XCTestCase {
    func test_append_keeps_newest_event_last() {
        let store = TelemetryStore()

        store.append(.fixture(name: "first"))
        store.append(.fixture(name: "second"))

        XCTAssertEqual(store.events.map(\.name), ["first", "second"])
    }

    func test_clear_removes_all_events() {
        let store = TelemetryStore()

        store.append(.fixture(name: "first"))
        store.clear()

        XCTAssertTrue(store.events.isEmpty)
    }

    func test_filter_matches_category_level_source_and_search() {
        let filter = TelemetryFilter(
            categories: [.errors],
            levels: [.error],
            sources: [.manual],
            searchText: "missing"
        )

        let matching = TelemetryEvent.fixture(
            level: .error,
            category: .errors,
            name: "file_missing",
            message: "Missing config file",
            source: .manual
        )

        let nonMatching = TelemetryEvent.fixture(
            level: .info,
            category: .lifecycle,
            name: "app_started",
            message: "App started",
            source: .swiftUI
        )

        XCTAssertTrue(filter.matches(matching))
        XCTAssertFalse(filter.matches(nonMatching))
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `swift test --filter TelemetryStoreTests`

Expected: FAIL because `TelemetryStore`, `TelemetryFilter`, and `.fixture` do not exist yet.

- [ ] **Step 3: Write the minimal implementation**

```swift
// Sources/MacTelemetryKit/TelemetryEvent.swift
import Foundation

public struct TelemetryEvent: Sendable, Equatable, Identifiable {
    public let timestamp: Date
    public let level: TelemetryLevel
    public let category: TelemetryCategory
    public let name: String
    public let message: String
    public let source: TelemetrySource
    public let sessionID: String
    public let eventID: String
    public let metadata: [String: String]
    public let durationMilliseconds: Int?
    public let errorCode: String?

    public var id: String { eventID }

    public init(
        timestamp: Date = .now,
        level: TelemetryLevel,
        category: TelemetryCategory,
        name: String,
        message: String,
        source: TelemetrySource,
        sessionID: String = UUID().uuidString.lowercased(),
        eventID: String = "evt_\(UUID().uuidString.lowercased())",
        metadata: [String: String] = [:],
        durationMilliseconds: Int? = nil,
        errorCode: String? = nil
    ) {
        self.timestamp = timestamp
        self.level = level
        self.category = category
        self.name = name
        self.message = message
        self.source = source
        self.sessionID = sessionID
        self.eventID = eventID
        self.metadata = metadata
        self.durationMilliseconds = durationMilliseconds
        self.errorCode = errorCode
    }
}

public extension TelemetryEvent {
    static func fixture(
        level: TelemetryLevel = .info,
        category: TelemetryCategory = .lifecycle,
        name: String,
        message: String? = nil,
        source: TelemetrySource = .manual,
        metadata: [String: String] = [:]
    ) -> TelemetryEvent {
        TelemetryEvent(
            level: level,
            category: category,
            name: name,
            message: message ?? name,
            source: source,
            sessionID: "session_fixture",
            eventID: "evt_\(name)",
            metadata: metadata
        )
    }
}
```

```swift
// Sources/MacTelemetryKit/TelemetryStore.swift
import Foundation
import Observation

@Observable
public final class TelemetryStore {
    public private(set) var events: [TelemetryEvent] = []

    public init() {}

    public func append(_ event: TelemetryEvent) {
        events.append(event)
    }

    public func clear() {
        events.removeAll()
    }
}
```

```swift
// Sources/MacTelemetryKit/TelemetryFilter.swift
public struct TelemetryFilter: Sendable, Equatable {
    public var categories: Set<TelemetryCategory>
    public var levels: Set<TelemetryLevel>
    public var sources: Set<TelemetrySource>
    public var searchText: String

    public init(
        categories: Set<TelemetryCategory> = Set(TelemetryCategory.allCases),
        levels: Set<TelemetryLevel> = Set(TelemetryLevel.allCases),
        sources: Set<TelemetrySource> = Set(TelemetrySource.allCases),
        searchText: String = ""
    ) {
        self.categories = categories
        self.levels = levels
        self.sources = sources
        self.searchText = searchText
    }

    public func matches(_ event: TelemetryEvent) -> Bool {
        guard categories.contains(event.category) else { return false }
        guard levels.contains(event.level) else { return false }
        guard sources.contains(event.source) else { return false }

        if searchText.isEmpty { return true }

        let haystack = "\(event.name) \(event.message) \(event.eventID) \(event.metadata.values.joined(separator: " "))"
            .lowercased()
        return haystack.contains(searchText.lowercased())
    }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `swift test --filter TelemetryStoreTests`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/MacTelemetryKit Tests/MacTelemetryKitTests/TelemetryStoreTests.swift
git commit -m "feat: add telemetry event model and store"
```

## Task 3: Add unified logging, export, and the public client API

**Files:**
- Create: `Sources/MacTelemetryKit/TelemetryLogger.swift`
- Create: `Sources/MacTelemetryKit/TelemetryExportService.swift`
- Create: `Sources/MacTelemetryKit/TelemetryConfiguration.swift`
- Create: `Sources/MacTelemetryKit/TelemetryBootstrap.swift`
- Create: `Sources/MacTelemetryKit/TelemetryClient.swift`
- Test: `Tests/MacTelemetryKitTests/TelemetryExportServiceTests.swift`

- [ ] **Step 1: Write the failing export and client tests**

```swift
import XCTest
@testable import MacTelemetryKit

final class TelemetryExportServiceTests: XCTestCase {
    func test_export_json_contains_safe_event_fields() throws {
        let service = TelemetryExportService()
        let data = try service.exportJSON([
            .fixture(
                level: .error,
                category: .errors,
                name: "file_missing",
                message: "Missing config file",
                source: .manual,
                metadata: ["window_id": "main"]
            )
        ])

        let json = try XCTUnwrap(String(data: data, encoding: .utf8))
        XCTAssertTrue(json.contains("\"name\" : \"file_missing\""))
        XCTAssertTrue(json.contains("\"window_id\" : \"main\""))
    }

    func test_client_log_appends_to_store() {
        let store = TelemetryStore()
        let client = TelemetryClient(
            store: store,
            logger: TelemetryLogger(subsystem: "com.example.test")
        )

        client.log(
            level: .info,
            category: .lifecycle,
            name: "app_started",
            message: "App started",
            source: .swiftUI
        )

        XCTAssertEqual(store.events.count, 1)
        XCTAssertEqual(store.events.first?.name, "app_started")
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `swift test --filter TelemetryExportServiceTests`

Expected: FAIL because `TelemetryExportService`, `TelemetryLogger`, `TelemetryClient`, and `TelemetryBootstrap` do not exist yet.

- [ ] **Step 3: Write the minimal implementation**

```swift
// Sources/MacTelemetryKit/TelemetryConfiguration.swift
public struct TelemetryConfiguration: Sendable, Equatable {
    public var subsystem: String
    public var isAutoCaptureEnabled: Bool
    public var enabledCategories: Set<TelemetryCategory>

    public init(
        subsystem: String,
        isAutoCaptureEnabled: Bool = true,
        enabledCategories: Set<TelemetryCategory> = Set(TelemetryCategory.allCases)
    ) {
        self.subsystem = subsystem
        self.isAutoCaptureEnabled = isAutoCaptureEnabled
        self.enabledCategories = enabledCategories
    }
}
```

```swift
// Sources/MacTelemetryKit/TelemetryLogger.swift
import OSLog

public struct TelemetryLogger: Sendable {
    private let lifecycle: Logger
    private let windowing: Logger
    private let navigation: Logger
    private let commands: Logger
    private let actions: Logger
    private let errors: Logger

    public init(subsystem: String) {
        lifecycle = Logger(subsystem: subsystem, category: "Lifecycle")
        windowing = Logger(subsystem: subsystem, category: "Windowing")
        navigation = Logger(subsystem: subsystem, category: "Navigation")
        commands = Logger(subsystem: subsystem, category: "Commands")
        actions = Logger(subsystem: subsystem, category: "Actions")
        errors = Logger(subsystem: subsystem, category: "Errors")
    }

    public func write(_ event: TelemetryEvent) {
        let message = "\(event.name): \(event.message)"
        switch event.category {
        case .lifecycle: log(event.level, message: message, logger: lifecycle)
        case .windowing: log(event.level, message: message, logger: windowing)
        case .navigation: log(event.level, message: message, logger: navigation)
        case .commands: log(event.level, message: message, logger: commands)
        case .actions: log(event.level, message: message, logger: actions)
        case .errors: log(event.level, message: message, logger: errors)
        }
    }

    private func log(_ level: TelemetryLevel, message: String, logger: Logger) {
        switch level {
        case .info: logger.info("\(message, privacy: .public)")
        case .warning: logger.warning("\(message, privacy: .public)")
        case .error: logger.error("\(message, privacy: .public)")
        case .debug: logger.debug("\(message, privacy: .public)")
        }
    }
}
```

```swift
// Sources/MacTelemetryKit/TelemetryExportService.swift
import Foundation

public struct TelemetryExportService: Sendable {
    public init() {}

    public func exportJSON(_ events: [TelemetryEvent]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(events)
    }
}
```

```swift
// Sources/MacTelemetryKit/TelemetryClient.swift
public final class TelemetryClient: Sendable {
    public let store: TelemetryStore
    private let logger: TelemetryLogger
    public let configuration: TelemetryConfiguration
    public let exportService: TelemetryExportService
    private let sessionID: String

    public init(
        store: TelemetryStore,
        logger: TelemetryLogger,
        configuration: TelemetryConfiguration = .init(subsystem: "com.example.app"),
        exportService: TelemetryExportService = .init(),
        sessionID: String = UUID().uuidString.lowercased()
    ) {
        self.store = store
        self.logger = logger
        self.configuration = configuration
        self.exportService = exportService
        self.sessionID = sessionID
    }

    public func log(
        level: TelemetryLevel,
        category: TelemetryCategory,
        name: String,
        message: String,
        source: TelemetrySource,
        metadata: [String: String] = [:],
        durationMilliseconds: Int? = nil,
        errorCode: String? = nil
    ) {
        guard configuration.enabledCategories.contains(category) else { return }

        let event = TelemetryEvent(
            level: level,
            category: category,
            name: name,
            message: message,
            source: source,
            sessionID: sessionID,
            metadata: metadata,
            durationMilliseconds: durationMilliseconds,
            errorCode: errorCode
        )

        store.append(event)
        logger.write(event)
    }
}
```

```swift
// Sources/MacTelemetryKit/TelemetryBootstrap.swift
public enum TelemetryBootstrap {
    @MainActor
    public static func start(subsystem: String) -> TelemetryClient {
        let store = TelemetryStore()
        let logger = TelemetryLogger(subsystem: subsystem)
        let configuration = TelemetryConfiguration(subsystem: subsystem)
        return TelemetryClient(
            store: store,
            logger: logger,
            configuration: configuration
        )
    }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `swift test --filter TelemetryExportServiceTests`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/MacTelemetryKit Tests/MacTelemetryKitTests/TelemetryExportServiceTests.swift
git commit -m "feat: add telemetry client logging and export"
```

## Task 4: Build the SwiftUI panel view model and state handling

**Files:**
- Create: `Sources/MacTelemetryKitUI/TelemetryPanelViewModel.swift`
- Test: `Tests/MacTelemetryKitUITests/TelemetryPanelViewModelTests.swift`

- [ ] **Step 1: Write the failing view-model tests**

```swift
import XCTest
@testable import MacTelemetryKit
@testable import MacTelemetryKitUI

final class TelemetryPanelViewModelTests: XCTestCase {
    @MainActor
    func test_filtered_events_respects_search_and_selected_filters() {
        let store = TelemetryStore()
        store.append(.fixture(level: .info, category: .lifecycle, name: "app_started", message: "App started", source: .swiftUI))
        store.append(.fixture(level: .error, category: .errors, name: "file_missing", message: "Missing config file", source: .manual))

        let viewModel = TelemetryPanelViewModel(store: store)
        viewModel.filter = TelemetryFilter(
            categories: [.errors],
            levels: [.error],
            sources: [.manual],
            searchText: "missing"
        )

        XCTAssertEqual(viewModel.filteredEvents.map(\.name), ["file_missing"])
    }

    @MainActor
    func test_clear_removes_all_events_from_store() {
        let store = TelemetryStore()
        store.append(.fixture(name: "app_started"))
        let viewModel = TelemetryPanelViewModel(store: store)

        viewModel.clearEvents()

        XCTAssertTrue(store.events.isEmpty)
    }
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `swift test --filter TelemetryPanelViewModelTests`

Expected: FAIL because `TelemetryPanelViewModel` does not exist yet.

- [ ] **Step 3: Write the minimal implementation**

```swift
// Sources/MacTelemetryKitUI/TelemetryPanelViewModel.swift
import Foundation
import Observation
import MacTelemetryKit

@Observable
@MainActor
public final class TelemetryPanelViewModel {
    public let store: TelemetryStore
    public var filter: TelemetryFilter
    public var selectedEventID: TelemetryEvent.ID?

    public init(
        store: TelemetryStore,
        filter: TelemetryFilter = .init()
    ) {
        self.store = store
        self.filter = filter
    }

    public var filteredEvents: [TelemetryEvent] {
        store.events.filter(filter.matches)
    }

    public var selectedEvent: TelemetryEvent? {
        filteredEvents.first { $0.id == selectedEventID }
    }

    public func select(_ event: TelemetryEvent) {
        selectedEventID = event.id
    }

    public func clearEvents() {
        store.clear()
        selectedEventID = nil
    }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `swift test --filter TelemetryPanelViewModelTests`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/MacTelemetryKitUI Tests/MacTelemetryKitUITests/TelemetryPanelViewModelTests.swift
git commit -m "feat: add telemetry panel view model"
```

## Task 5: Build the MVP three-column SwiftUI panel

**Files:**
- Create: `Sources/MacTelemetryKitUI/TelemetryPanelView.swift`
- Create: `Sources/MacTelemetryKitUI/TelemetryPanelComponents.swift`
- Test: `Tests/MacTelemetryKitUITests/TelemetryPanelViewModelTests.swift`

- [ ] **Step 1: Extend the tests with view-state expectations**

```swift
@MainActor
func test_selected_event_tracks_current_selection() {
    let store = TelemetryStore()
    let event = TelemetryEvent.fixture(name: "app_started", message: "App started", source: .swiftUI)
    store.append(event)

    let viewModel = TelemetryPanelViewModel(store: store)
    viewModel.select(event)

    XCTAssertEqual(viewModel.selectedEvent?.id, event.id)
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `swift test --filter TelemetryPanelViewModelTests/test_selected_event_tracks_current_selection`

Expected: FAIL until the selection flow is fully wired and compiling against the UI target.

- [ ] **Step 3: Write the minimal UI implementation**

```swift
// Sources/MacTelemetryKitUI/TelemetryPanelView.swift
import SwiftUI
import MacTelemetryKit

public struct TelemetryPanelView: View {
    @State private var viewModel: TelemetryPanelViewModel

    public init(store: TelemetryStore) {
        _viewModel = State(initialValue: TelemetryPanelViewModel(store: store))
    }

    public var body: some View {
        NavigationSplitView {
            TelemetryFilterSidebar(viewModel: viewModel)
                .frame(minWidth: 260, idealWidth: 260, maxWidth: 260)
        } content: {
            TelemetryEventTable(viewModel: viewModel)
                .frame(minWidth: 420)
        } detail: {
            TelemetryEventDetailPane(event: viewModel.selectedEvent)
                .frame(minWidth: 360, idealWidth: 360, maxWidth: 360)
        }
        .navigationSplitViewStyle(.balanced)
    }
}
```

```swift
// Sources/MacTelemetryKitUI/TelemetryPanelComponents.swift
import SwiftUI
import MacTelemetryKit

struct TelemetryFilterSidebar: View {
    @Bindable var viewModel: TelemetryPanelViewModel

    var body: some View {
        Form {
            Section("Categories") {
                ForEach(TelemetryCategory.allCases, id: \.self) { category in
                    Toggle(category.rawValue.capitalized, isOn: binding(for: category))
                }
            }
            Section("Levels") {
                ForEach(TelemetryLevel.allCases, id: \.self) { level in
                    Toggle(level.rawValue.capitalized, isOn: levelBinding(for: level))
                }
            }
            Section("Frameworks") {
                ForEach(TelemetrySource.allCases, id: \.self) { source in
                    Toggle(source.rawValue, isOn: sourceBinding(for: source))
                }
            }
        }
        .formStyle(.grouped)
    }

    private func binding(for category: TelemetryCategory) -> Binding<Bool> {
        Binding(
            get: { viewModel.filter.categories.contains(category) },
            set: { isOn in
                if isOn { viewModel.filter.categories.insert(category) }
                else { viewModel.filter.categories.remove(category) }
            }
        )
    }

    private func levelBinding(for level: TelemetryLevel) -> Binding<Bool> {
        Binding(
            get: { viewModel.filter.levels.contains(level) },
            set: { isOn in
                if isOn { viewModel.filter.levels.insert(level) }
                else { viewModel.filter.levels.remove(level) }
            }
        )
    }

    private func sourceBinding(for source: TelemetrySource) -> Binding<Bool> {
        Binding(
            get: { viewModel.filter.sources.contains(source) },
            set: { isOn in
                if isOn { viewModel.filter.sources.insert(source) }
                else { viewModel.filter.sources.remove(source) }
            }
        )
    }
}

struct TelemetryEventTable: View {
    @Bindable var viewModel: TelemetryPanelViewModel

    var body: some View {
        VStack(spacing: 0) {
            TextField("Filter events…", text: $viewModel.filter.searchText)
                .textFieldStyle(.roundedBorder)
                .padding(12)

            if viewModel.filteredEvents.isEmpty {
                ContentUnavailableView("No events yet", systemImage: "waveform.path.ecg")
            } else {
                List(viewModel.filteredEvents, selection: $viewModel.selectedEventID) { event in
                    Button {
                        viewModel.select(event)
                    } label: {
                        HStack {
                            Text(event.timestamp, format: .dateTime.hour().minute().second())
                                .font(.system(.caption, design: .monospaced))
                                .frame(width: 78, alignment: .leading)
                            Circle()
                                .fill(levelColor(event.level))
                                .frame(width: 8, height: 8)
                            Text(event.category.rawValue.capitalized)
                                .frame(width: 82, alignment: .leading)
                            Text(event.message)
                                .lineLimit(1)
                            Spacer()
                            Text(event.durationMilliseconds.map { "\($0) ms" } ?? "—")
                                .font(.system(.caption, design: .monospaced))
                            Text(event.eventID)
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
    }

    private func levelColor(_ level: TelemetryLevel) -> Color {
        switch level {
        case .info: .blue
        case .warning: .orange
        case .error: .red
        case .debug: .gray
        }
    }
}

struct TelemetryEventDetailPane: View {
    let event: TelemetryEvent?

    var body: some View {
        if let event {
            List {
                Section("Event") {
                    detailRow("Message", event.message)
                    detailRow("Category", event.category.rawValue.capitalized)
                    detailRow("Source", event.source.rawValue)
                    detailRow("Event ID", event.eventID)
                }
                Section("Safe Metadata") {
                    ForEach(event.metadata.keys.sorted(), id: \.self) { key in
                        detailRow(key, event.metadata[key] ?? "")
                    }
                }
            }
        } else {
            ContentUnavailableView("Select an event", systemImage: "sidebar.right")
        }
    }

    @ViewBuilder
    private func detailRow(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(.caption, design: .monospaced))
        }
    }
}
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `swift test --filter TelemetryPanelViewModelTests`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Sources/MacTelemetryKitUI Tests/MacTelemetryKitUITests/TelemetryPanelViewModelTests.swift
git commit -m "feat: add swiftui telemetry panel"
```

## Task 6: Add the demo app and verify logs end to end

**Files:**
- Create: `Sources/MacTelemetryDemo/TelemetryDemoApp.swift`

- [ ] **Step 1: Write the failing manual verification target**

```swift
// Verification target for this task:
// Build and run the demo app, confirm it logs app launch and UI actions,
// and render the panel with sample events.
```

- [ ] **Step 2: Run the demo target to verify it fails before the app exists**

Run: `swift run MacTelemetryDemo`

Expected: FAIL because the executable target entry point does not exist yet.

- [ ] **Step 3: Write the minimal demo app implementation**

```swift
import SwiftUI
import MacTelemetryKit
import MacTelemetryKitUI

@main
struct TelemetryDemoApp: App {
    @State private var telemetry = TelemetryBootstrap.start(subsystem: "com.activi.MacTelemetryDemo")

    var body: some Scene {
        WindowGroup("Telemetry Demo") {
            VStack(spacing: 16) {
                HStack {
                    Button("Log Window Event") {
                        telemetry.log(
                            level: .info,
                            category: .windowing,
                            name: "window_opened",
                            message: "Main window opened",
                            source: .swiftUI,
                            metadata: ["window_id": "main"]
                        )
                    }

                    Button("Log Error Event") {
                        telemetry.log(
                            level: .error,
                            category: .errors,
                            name: "file_missing",
                            message: "Missing config file",
                            source: .manual,
                            metadata: ["event_count": "\(telemetry.store.events.count)"],
                            errorCode: "ENOENT"
                        )
                    }
                }

                TelemetryPanelView(store: telemetry.store)
            }
            .padding()
            .onAppear {
                telemetry.log(
                    level: .info,
                    category: .lifecycle,
                    name: "app_started",
                    message: "App started",
                    source: .swiftUI
                )
            }
        }
    }
}
```

- [ ] **Step 4: Run build, tests, and manual log verification**

Run:

```bash
swift build
swift test
log stream --style compact --predicate 'subsystem == "com.activi.MacTelemetryDemo" AND (category == "Lifecycle" OR category == "Windowing" OR category == "Errors")'
```

Expected:

- `swift build`: PASS
- `swift test`: PASS
- `log stream`: shows lines for `app_started`, `window_opened`, and `file_missing` after you click the demo buttons

- [ ] **Step 5: Commit**

```bash
git add Sources/MacTelemetryDemo
git commit -m "feat: add telemetry demo app"
```

## Task 7: Final verification and docs pass

**Files:**
- Modify: `docs/superpowers/specs/2026-06-07-mac-telemetry-design.md` if implementation forces a spec correction

- [ ] **Step 1: Run the full verification suite**

Run:

```bash
swift build
swift test
```

Expected: PASS

- [ ] **Step 2: Verify the MVP spec coverage**

Check these items against the implementation:

```text
- three-column SwiftUI panel exists
- filters cover category, level, and source
- event list shows time, category, message, duration, and event ID
- right detail pane is the only detail surface
- export service exists
- clear action exists in the view model
- demo app emits log lines visible in unified logging
```

Expected: every bullet maps to a concrete file in `Sources/`.

- [ ] **Step 3: Record the exact verification predicate in project notes**

```text
log stream --style compact --predicate 'subsystem == "com.activi.MacTelemetryDemo" AND (category == "Lifecycle" OR category == "Windowing" OR category == "Errors")'
```

- [ ] **Step 4: Re-run a clean test pass**

Run: `swift test`

Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Package.swift Sources Tests docs/superpowers/specs/2026-06-07-mac-telemetry-design.md
git commit -m "chore: verify MacTelemetry MVP"
```

## Self-Review

### Spec coverage

- Phase 1 package skeleton: covered by Tasks 1-3
- event model, logger, store, export: covered by Tasks 2-3
- SwiftUI panel MVP: covered by Tasks 4-5
- demo app and unified log verification: covered by Tasks 6-7
- AppKit adapters: intentionally deferred to Phase 2
- bootstrap installer script: intentionally deferred to Phase 2

### Placeholder scan

- No `TODO`, `TBD`, or “similar to previous task” placeholders remain.
- All code-touching steps include concrete file targets and code snippets.

### Type consistency

- Core public names are consistent across tasks: `TelemetryEvent`, `TelemetryStore`, `TelemetryFilter`, `TelemetryLogger`, `TelemetryClient`, `TelemetryBootstrap`, `TelemetryPanelView`, `TelemetryPanelViewModel`.

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-06-07-mac-telemetry-mvp-implementation.md`. Two execution options:

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?**

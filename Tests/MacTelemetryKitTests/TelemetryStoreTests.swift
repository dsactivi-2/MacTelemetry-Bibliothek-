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

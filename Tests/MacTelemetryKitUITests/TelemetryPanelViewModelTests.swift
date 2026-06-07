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

import XCTest
@testable import MacTelemetryKit

final class TelemetrySelectionTests: XCTestCase {
    func test_capture_selection_logs_selection_container_and_state_metadata() {
        let store = TelemetryStore()
        let client = TelemetryClient(
            store: store,
            logger: TelemetryLogger(subsystem: "com.example.test")
        )

        TelemetrySelection.capture(
            client: client,
            name: "file_selected",
            message: "User selected a file",
            source: .manual,
            selection: "report.pdf",
            container: "sidebar",
            selectionState: "single"
        )

        XCTAssertEqual(store.events.last?.category, .navigation)
        XCTAssertEqual(store.events.last?.metadata["selection"], "report.pdf")
        XCTAssertEqual(store.events.last?.metadata["container"], "sidebar")
        XCTAssertEqual(store.events.last?.metadata["selection_state"], "single")
    }
}

import XCTest
@testable import MacTelemetryKit

final class TelemetryNavigationTests: XCTestCase {
    func test_capture_navigation_logs_from_to_and_surface_metadata() {
        let store = TelemetryStore()
        let client = TelemetryClient(
            store: store,
            logger: TelemetryLogger(subsystem: "com.example.test")
        )

        TelemetryNavigation.capture(
            client: client,
            name: "sidebar_transition",
            message: "Sidebar selection changed",
            source: .manual,
            from: "home",
            to: "settings",
            surface: "sidebar"
        )

        XCTAssertEqual(store.events.last?.category, .navigation)
        XCTAssertEqual(store.events.last?.metadata["from"], "home")
        XCTAssertEqual(store.events.last?.metadata["to"], "settings")
        XCTAssertEqual(store.events.last?.metadata["surface"], "sidebar")
    }
}

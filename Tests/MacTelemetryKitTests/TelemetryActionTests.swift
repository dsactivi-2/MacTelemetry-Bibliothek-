import XCTest
@testable import MacTelemetryKit

final class TelemetryActionTests: XCTestCase {
    func test_capture_action_logs_before_running_body() {
        let store = TelemetryStore()
        let client = TelemetryClient(
            store: store,
            logger: TelemetryLogger(subsystem: "com.example.test")
        )
        var didRun = false

        TelemetryAction.capture(
            client: client,
            name: "refresh_button",
            message: "Refresh button tapped",
            source: .manual
        ) {
            didRun = true
        }

        XCTAssertTrue(didRun)
        XCTAssertEqual(store.events.last?.name, "refresh_button")
        XCTAssertEqual(store.events.last?.category, .actions)
    }
}

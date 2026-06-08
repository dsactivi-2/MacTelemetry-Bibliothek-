import XCTest
@testable import MacTelemetryKit

final class TelemetryCommandTests: XCTestCase {
    func test_capture_command_logs_before_running_body() {
        let store = TelemetryStore()
        let client = TelemetryClient(
            store: store,
            logger: TelemetryLogger(subsystem: "com.example.test")
        )
        var didRun = false

        TelemetryCommand.capture(
            client: client,
            name: "open_settings",
            message: "Open Settings command executed",
            source: .manual,
            commandGroup: "app"
        ) {
            didRun = true
        }

        XCTAssertTrue(didRun)
        XCTAssertEqual(store.events.last?.category, .commands)
        XCTAssertEqual(store.events.last?.metadata["command_group"], "app")
    }
}

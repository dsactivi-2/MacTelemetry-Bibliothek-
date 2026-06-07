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

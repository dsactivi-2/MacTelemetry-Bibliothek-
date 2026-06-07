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

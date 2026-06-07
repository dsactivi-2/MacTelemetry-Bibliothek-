import AppKit
import XCTest
@testable import MacTelemetryKit

final class TelemetryAppKitObserverTests: XCTestCase {
    @MainActor
    func test_application_launch_notification_logs_lifecycle_event() {
        let store = TelemetryStore()
        let client = TelemetryClient(
            store: store,
            logger: TelemetryLogger(subsystem: "com.example.test")
        )
        let center = NotificationCenter()
        let observer = TelemetryAppKitObserver(
            client: client,
            notificationCenter: center
        )

        center.post(name: NSApplication.didFinishLaunchingNotification, object: nil)

        XCTAssertEqual(store.events.last?.name, "appkit_app_did_finish_launching")
        XCTAssertEqual(store.events.last?.category, .lifecycle)
        _ = observer
    }

    @MainActor
    func test_window_key_notification_logs_windowing_event() {
        let store = TelemetryStore()
        let client = TelemetryClient(
            store: store,
            logger: TelemetryLogger(subsystem: "com.example.test")
        )
        let center = NotificationCenter()
        let observer = TelemetryAppKitObserver(
            client: client,
            notificationCenter: center
        )

        center.post(
            name: NSWindow.didBecomeKeyNotification,
            object: nil,
            userInfo: [TelemetryAppKitObserver.windowIDUserInfoKey: "main"]
        )

        XCTAssertEqual(store.events.last?.name, "window_did_become_key")
        XCTAssertEqual(store.events.last?.metadata["window_id"], "main")
        _ = observer
    }
}

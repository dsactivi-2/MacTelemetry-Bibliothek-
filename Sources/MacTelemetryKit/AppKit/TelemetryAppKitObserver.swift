import AppKit
import Foundation

@MainActor
public final class TelemetryAppKitObserver: NSObject {
    public static let windowIDUserInfoKey = "window_id"

    private let client: TelemetryClient
    private let notificationCenter: NotificationCenter

    public init(
        client: TelemetryClient,
        notificationCenter: NotificationCenter = .default
    ) {
        self.client = client
        self.notificationCenter = notificationCenter
        super.init()
        register()
    }

    deinit {
        notificationCenter.removeObserver(self)
    }

    private func register() {
        notificationCenter.addObserver(
            self,
            selector: #selector(handleApplicationDidFinishLaunching(_:)),
            name: NSApplication.didFinishLaunchingNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(handleWindowDidBecomeKey(_:)),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )
    }

    @objc
    private func handleApplicationDidFinishLaunching(_ notification: Notification) {
        client.log(
            level: .info,
            category: .lifecycle,
            name: "appkit_app_did_finish_launching",
            message: "AppKit application finished launching",
            source: .appKit
        )
    }

    @objc
    private func handleWindowDidBecomeKey(_ notification: Notification) {
        let windowID = notification.userInfo?[Self.windowIDUserInfoKey] as? String ?? "unknown"
        client.log(
            level: .info,
            category: .windowing,
            name: "window_did_become_key",
            message: "AppKit window became key",
            source: .appKit,
            metadata: ["window_id": windowID]
        )
    }
}

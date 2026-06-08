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
            selector: #selector(handleApplicationDidBecomeActive(_:)),
            name: NSApplication.didBecomeActiveNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(handleApplicationDidResignActive(_:)),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(handleWindowDidBecomeKey(_:)),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(handleWindowDidResignKey(_:)),
            name: NSWindow.didResignKeyNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(handleWindowWillClose(_:)),
            name: NSWindow.willCloseNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(handleWindowDidMiniaturize(_:)),
            name: NSWindow.didMiniaturizeNotification,
            object: nil
        )

        notificationCenter.addObserver(
            self,
            selector: #selector(handleWindowDidDeminiaturize(_:)),
            name: NSWindow.didDeminiaturizeNotification,
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
    private func handleApplicationDidBecomeActive(_ notification: Notification) {
        client.log(
            level: .info,
            category: .lifecycle,
            name: "appkit_app_did_become_active",
            message: "AppKit application became active",
            source: .appKit
        )
    }

    @objc
    private func handleApplicationDidResignActive(_ notification: Notification) {
        client.log(
            level: .info,
            category: .lifecycle,
            name: "appkit_app_did_resign_active",
            message: "AppKit application resigned active state",
            source: .appKit
        )
    }

    @objc
    private func handleWindowDidBecomeKey(_ notification: Notification) {
        logWindowEvent(
            notification: notification,
            name: "window_did_become_key",
            message: "AppKit window became key"
        )
    }

    @objc
    private func handleWindowDidResignKey(_ notification: Notification) {
        logWindowEvent(
            notification: notification,
            name: "window_did_resign_key",
            message: "AppKit window resigned key"
        )
    }

    @objc
    private func handleWindowWillClose(_ notification: Notification) {
        logWindowEvent(
            notification: notification,
            name: "window_will_close",
            message: "AppKit window will close"
        )
    }

    @objc
    private func handleWindowDidMiniaturize(_ notification: Notification) {
        logWindowEvent(
            notification: notification,
            name: "window_did_miniaturize",
            message: "AppKit window did miniaturize"
        )
    }

    @objc
    private func handleWindowDidDeminiaturize(_ notification: Notification) {
        logWindowEvent(
            notification: notification,
            name: "window_did_deminiaturize",
            message: "AppKit window did deminiaturize"
        )
    }

    private func logWindowEvent(
        notification: Notification,
        name: String,
        message: String
    ) {
        let windowID = notification.userInfo?[Self.windowIDUserInfoKey] as? String ?? "unknown"
        client.log(
            level: .info,
            category: .windowing,
            name: name,
            message: message,
            source: .appKit,
            metadata: ["window_id": windowID]
        )
    }
}

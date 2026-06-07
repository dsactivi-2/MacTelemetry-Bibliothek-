import SwiftUI
import MacTelemetryKit
import MacTelemetryKitUI
import Darwin

@main
struct TelemetryDemoApp: App {
    private let telemetry: TelemetryClient

    init() {
        let telemetry = TelemetryBootstrap.start(subsystem: "com.activi.MacTelemetryDemo")
        self.telemetry = telemetry
        telemetry.log(
            level: .info,
            category: .lifecycle,
            name: "app_started",
            message: "App started",
            source: .swiftUI
        )

        if CommandLine.arguments.contains("--smoke-log") {
            exit(0)
        }
    }

    var body: some Scene {
        WindowGroup("Telemetry Demo") {
            TelemetryDemoRootView(telemetry: telemetry)
        }
    }
}

private struct TelemetryDemoRootView: View {
    let telemetry: TelemetryClient
    @State private var appKitObserver: TelemetryAppKitObserver?

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Log Window Event") {
                    telemetry.log(
                        level: .info,
                        category: .windowing,
                        name: "window_opened",
                        message: "Main window opened",
                        source: .swiftUI,
                        metadata: ["window_id": "main"]
                    )
                }

                Button("Log Error Event") {
                    telemetry.log(
                        level: .error,
                        category: .errors,
                        name: "file_missing",
                        message: "Missing config file",
                        source: .manual,
                        metadata: ["event_count": "\(telemetry.store.events.count)"],
                        errorCode: "ENOENT"
                    )
                }

                Button("Capture Refresh Action") {
                    TelemetryAction.capture(
                        client: telemetry,
                        name: "refresh_button",
                        message: "Refresh button tapped",
                        source: .swiftUI
                    ) {}
                }
            }

            TelemetryPanelView(store: telemetry.store)
        }
        .padding()
        .frame(minWidth: 1200, minHeight: 720)
        .onAppear {
            if appKitObserver == nil {
                appKitObserver = telemetry.attachAppKitObserver()
            }
        }
    }
}

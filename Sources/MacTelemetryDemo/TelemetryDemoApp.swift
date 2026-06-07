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
                }

                TelemetryPanelView(store: telemetry.store)
            }
            .padding()
            .frame(minWidth: 1200, minHeight: 720)
        }
    }
}

import SwiftUI
import MacTelemetryKit
import MacTelemetryKitUI
import Darwin

@main
struct TelemetryHostDemoApp: App {
    private let telemetry: TelemetryClient

    init() {
        let telemetry = TelemetryBootstrap.start(subsystem: "com.activi.MacTelemetryHostDemo")
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
        WindowGroup("Host Integration Demo") {
            HostDemoRootView(telemetry: telemetry)
        }
    }
}

private struct HostDemoRootView: View {
    let telemetry: TelemetryClient
    @State private var appKitObserver: TelemetryAppKitObserver?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This app simulates a separate macOS host integrating MacTelemetryKit.")
                .font(.headline)

            Button("Log Host Action") {
                TelemetryAction.capture(
                    client: telemetry,
                    name: "host_refresh",
                    message: "Host app refresh action",
                    source: .swiftUI
                ) {}
            }

            TelemetryPanelView(store: telemetry.store)
        }
        .padding()
        .frame(minWidth: 1100, minHeight: 720)
        .onAppear {
            if appKitObserver == nil {
                appKitObserver = telemetry.attachAppKitObserver()
            }
        }
    }
}

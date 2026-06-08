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
    @State private var currentRoute = "home"
    @State private var selectedDocument = "report.pdf"

    private let routes = ["home", "settings", "logs"]
    private let documents = ["report.pdf", "notes.txt", "trace.json"]

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

                Button("Run Open Settings Command") {
                    TelemetryCommand.capture(
                        client: telemetry,
                        name: "open_settings",
                        message: "Open Settings command executed",
                        source: .swiftUI,
                        commandGroup: "app"
                    ) {}
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Picker("Route", selection: $currentRoute) {
                    ForEach(routes, id: \.self) { route in
                        Text(route.capitalized).tag(route)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Selected File", selection: $selectedDocument) {
                    ForEach(documents, id: \.self) { document in
                        Text(document).tag(document)
                    }
                }

                Text("Current route: \(currentRoute)")
                    .font(.headline)
                Text("Selected file: \(selectedDocument)")
                    .foregroundStyle(.secondary)
            }

            TelemetryPanelView(store: telemetry.store)
        }
        .padding()
        .frame(minWidth: 1200, minHeight: 720)
        .onChange(of: currentRoute) { oldValue, newValue in
            guard oldValue != newValue else {
                return
            }

            TelemetryNavigation.capture(
                client: telemetry,
                name: "route_changed",
                message: "Navigation route changed",
                source: .swiftUI,
                from: oldValue,
                to: newValue,
                surface: "demo_route_picker"
            )
        }
        .onChange(of: selectedDocument) { oldValue, newValue in
            guard oldValue != newValue else {
                return
            }

            TelemetrySelection.capture(
                client: telemetry,
                name: "document_selected",
                message: "Document selection changed",
                source: .swiftUI,
                selection: newValue,
                container: "demo_document_picker",
                selectionState: "single",
                metadata: ["previous_selection": oldValue]
            )
        }
        .onAppear {
            if appKitObserver == nil {
                appKitObserver = telemetry.attachAppKitObserver()
            }
        }
    }
}

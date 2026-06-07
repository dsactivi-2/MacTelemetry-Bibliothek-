import Foundation

public final class TelemetryClient {
    public let store: TelemetryStore
    private let logger: TelemetryLogger
    public let configuration: TelemetryConfiguration
    public let exportService: TelemetryExportService
    private let sessionID: String

    public init(
        store: TelemetryStore,
        logger: TelemetryLogger,
        configuration: TelemetryConfiguration = .init(subsystem: "com.example.app"),
        exportService: TelemetryExportService = .init(),
        sessionID: String = UUID().uuidString.lowercased()
    ) {
        self.store = store
        self.logger = logger
        self.configuration = configuration
        self.exportService = exportService
        self.sessionID = sessionID
    }

    public func log(
        level: TelemetryLevel,
        category: TelemetryCategory,
        name: String,
        message: String,
        source: TelemetrySource,
        metadata: [String: String] = [:],
        durationMilliseconds: Int? = nil,
        errorCode: String? = nil
    ) {
        guard configuration.enabledCategories.contains(category) else {
            return
        }

        let event = TelemetryEvent(
            level: level,
            category: category,
            name: name,
            message: message,
            source: source,
            sessionID: sessionID,
            metadata: metadata,
            durationMilliseconds: durationMilliseconds,
            errorCode: errorCode
        )

        store.append(event)
        logger.write(event)
    }

    @MainActor
    @discardableResult
    public func attachAppKitObserver(
        notificationCenter: NotificationCenter = .default
    ) -> TelemetryAppKitObserver {
        TelemetryAppKitObserver(
            client: self,
            notificationCenter: notificationCenter
        )
    }
}

@MainActor
public enum TelemetryBootstrap {
    public static func start(subsystem: String) -> TelemetryClient {
        let store = TelemetryStore()
        let logger = TelemetryLogger(subsystem: subsystem)
        let configuration = TelemetryConfiguration(subsystem: subsystem)
        return TelemetryClient(
            store: store,
            logger: logger,
            configuration: configuration
        )
    }
}

public enum TelemetryAction {
    public static func capture(
        client: TelemetryClient,
        level: TelemetryLevel = .info,
        category: TelemetryCategory = .actions,
        name: String,
        message: String,
        source: TelemetrySource,
        metadata: [String: String] = [:],
        body: () -> Void
    ) {
        client.log(
            level: level,
            category: category,
            name: name,
            message: message,
            source: source,
            metadata: metadata
        )
        body()
    }
}

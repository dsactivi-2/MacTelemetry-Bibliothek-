public enum TelemetryNavigation {
    public static func capture(
        client: TelemetryClient,
        level: TelemetryLevel = .info,
        name: String,
        message: String,
        source: TelemetrySource,
        from: String,
        to: String,
        surface: String? = nil,
        metadata: [String: String] = [:]
    ) {
        var mergedMetadata = metadata
        mergedMetadata["from"] = from
        mergedMetadata["to"] = to
        if let surface {
            mergedMetadata["surface"] = surface
        }

        client.log(
            level: level,
            category: .navigation,
            name: name,
            message: message,
            source: source,
            metadata: mergedMetadata
        )
    }
}

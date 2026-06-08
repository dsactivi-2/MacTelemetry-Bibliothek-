public enum TelemetryCommand {
    public static func capture(
        client: TelemetryClient,
        level: TelemetryLevel = .info,
        name: String,
        message: String,
        source: TelemetrySource,
        commandGroup: String? = nil,
        metadata: [String: String] = [:],
        body: () -> Void
    ) {
        var mergedMetadata = metadata
        if let commandGroup {
            mergedMetadata["command_group"] = commandGroup
        }

        client.log(
            level: level,
            category: .commands,
            name: name,
            message: message,
            source: source,
            metadata: mergedMetadata
        )
        body()
    }
}

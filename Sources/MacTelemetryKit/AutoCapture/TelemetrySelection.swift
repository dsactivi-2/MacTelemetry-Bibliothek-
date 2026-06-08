public enum TelemetrySelection {
    public static func capture(
        client: TelemetryClient,
        level: TelemetryLevel = .info,
        name: String,
        message: String,
        source: TelemetrySource,
        selection: String,
        container: String? = nil,
        selectionState: String? = nil,
        metadata: [String: String] = [:]
    ) {
        var mergedMetadata = metadata
        mergedMetadata["selection"] = selection
        if let container {
            mergedMetadata["container"] = container
        }
        if let selectionState {
            mergedMetadata["selection_state"] = selectionState
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

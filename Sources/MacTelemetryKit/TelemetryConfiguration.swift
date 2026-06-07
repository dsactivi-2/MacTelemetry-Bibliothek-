public struct TelemetryConfiguration: Sendable, Equatable {
    public var subsystem: String
    public var isAutoCaptureEnabled: Bool
    public var enabledCategories: Set<TelemetryCategory>

    public init(
        subsystem: String,
        isAutoCaptureEnabled: Bool = true,
        enabledCategories: Set<TelemetryCategory> = Set(TelemetryCategory.allCases)
    ) {
        self.subsystem = subsystem
        self.isAutoCaptureEnabled = isAutoCaptureEnabled
        self.enabledCategories = enabledCategories
    }
}

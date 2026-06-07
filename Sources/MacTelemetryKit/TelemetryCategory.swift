public enum TelemetryCategory: String, Sendable, Equatable, CaseIterable {
    case lifecycle
    case windowing
    case navigation
    case commands
    case actions
    case errors
}

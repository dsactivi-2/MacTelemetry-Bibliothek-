public enum TelemetryCategory: String, Sendable, Equatable, CaseIterable, Codable {
    case lifecycle
    case windowing
    case navigation
    case commands
    case actions
    case errors
}

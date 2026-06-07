public enum TelemetrySource: String, Sendable, Equatable, CaseIterable, Codable {
    case swiftUI = "SwiftUI"
    case appKit = "AppKit"
    case manual = "Manual"
}

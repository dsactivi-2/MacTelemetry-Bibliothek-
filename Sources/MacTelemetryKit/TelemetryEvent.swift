import Foundation

public struct TelemetryEvent: Sendable, Equatable {
    public let level: TelemetryLevel
    public let category: TelemetryCategory
    public let name: String
    public let message: String
    public let source: TelemetrySource
    public let sessionID: String
    public let eventID: String

    public init(
        level: TelemetryLevel,
        category: TelemetryCategory,
        name: String,
        message: String,
        source: TelemetrySource,
        sessionID: String = UUID().uuidString.lowercased(),
        eventID: String = "evt_\(UUID().uuidString.lowercased())"
    ) {
        self.level = level
        self.category = category
        self.name = name
        self.message = message
        self.source = source
        self.sessionID = sessionID
        self.eventID = eventID
    }
}

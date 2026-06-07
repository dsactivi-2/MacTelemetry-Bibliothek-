import Foundation

public struct TelemetryEvent: Sendable, Equatable, Identifiable, Codable {
    public let timestamp: Date
    public let level: TelemetryLevel
    public let category: TelemetryCategory
    public let name: String
    public let message: String
    public let source: TelemetrySource
    public let sessionID: String
    public let eventID: String
    public let metadata: [String: String]
    public let durationMilliseconds: Int?
    public let errorCode: String?

    public var id: String { eventID }

    public init(
        timestamp: Date = .now,
        level: TelemetryLevel,
        category: TelemetryCategory,
        name: String,
        message: String,
        source: TelemetrySource,
        sessionID: String = UUID().uuidString.lowercased(),
        eventID: String = "evt_\(UUID().uuidString.lowercased())",
        metadata: [String: String] = [:],
        durationMilliseconds: Int? = nil,
        errorCode: String? = nil
    ) {
        self.timestamp = timestamp
        self.level = level
        self.category = category
        self.name = name
        self.message = message
        self.source = source
        self.sessionID = sessionID
        self.eventID = eventID
        self.metadata = metadata
        self.durationMilliseconds = durationMilliseconds
        self.errorCode = errorCode
    }
}

public extension TelemetryEvent {
    static func fixture(
        level: TelemetryLevel = .info,
        category: TelemetryCategory = .lifecycle,
        name: String,
        message: String? = nil,
        source: TelemetrySource = .manual,
        metadata: [String: String] = [:]
    ) -> TelemetryEvent {
        TelemetryEvent(
            level: level,
            category: category,
            name: name,
            message: message ?? name,
            source: source,
            sessionID: "session_fixture",
            eventID: "evt_\(name)",
            metadata: metadata
        )
    }
}

import Foundation

public struct TelemetryExportService: Sendable {
    public init() {}

    public func exportJSON(_ events: [TelemetryEvent]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(events)
    }
}

import Foundation
import Observation
import MacTelemetryKit

@Observable
@MainActor
public final class TelemetryPanelViewModel {
    public let store: TelemetryStore
    public var filter: TelemetryFilter
    public var selectedEventID: TelemetryEvent.ID?

    public init(
        store: TelemetryStore,
        filter: TelemetryFilter = .init()
    ) {
        self.store = store
        self.filter = filter
    }

    public var filteredEvents: [TelemetryEvent] {
        store.events.filter(filter.matches)
    }

    public var selectedEvent: TelemetryEvent? {
        filteredEvents.first { $0.id == selectedEventID }
    }

    public var lastEventTimestamp: Date? {
        store.events.last?.timestamp
    }

    public func select(_ event: TelemetryEvent) {
        selectedEventID = event.id
    }

    public func count(for category: TelemetryCategory) -> Int {
        store.events.filter { $0.category == category }.count
    }

    public func exportTraceToTemporaryFile() throws -> URL {
        let data = try TelemetryExportService().exportJSON(filteredEvents)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("telemetry-\(UUID().uuidString.lowercased()).json")
        try data.write(to: url)
        return url
    }

    public func clearEvents() {
        store.clear()
        selectedEventID = nil
    }
}

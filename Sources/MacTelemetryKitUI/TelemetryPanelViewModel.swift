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

    public func select(_ event: TelemetryEvent) {
        selectedEventID = event.id
    }

    public func clearEvents() {
        store.clear()
        selectedEventID = nil
    }
}

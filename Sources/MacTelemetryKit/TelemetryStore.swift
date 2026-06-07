import Observation

@Observable
public final class TelemetryStore {
    public private(set) var events: [TelemetryEvent] = []

    public init() {}

    public func append(_ event: TelemetryEvent) {
        events.append(event)
    }

    public func clear() {
        events.removeAll()
    }
}

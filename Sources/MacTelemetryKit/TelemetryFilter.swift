public struct TelemetryFilter: Sendable, Equatable {
    public var categories: Set<TelemetryCategory>
    public var levels: Set<TelemetryLevel>
    public var sources: Set<TelemetrySource>
    public var searchText: String

    public init(
        categories: Set<TelemetryCategory> = Set(TelemetryCategory.allCases),
        levels: Set<TelemetryLevel> = Set(TelemetryLevel.allCases),
        sources: Set<TelemetrySource> = Set(TelemetrySource.allCases),
        searchText: String = ""
    ) {
        self.categories = categories
        self.levels = levels
        self.sources = sources
        self.searchText = searchText
    }

    public func matches(_ event: TelemetryEvent) -> Bool {
        guard categories.contains(event.category) else { return false }
        guard levels.contains(event.level) else { return false }
        guard sources.contains(event.source) else { return false }

        if searchText.isEmpty {
            return true
        }

        let haystack = "\(event.name) \(event.message) \(event.eventID) \(event.metadata.values.joined(separator: " "))"
            .lowercased()
        return haystack.contains(searchText.lowercased())
    }
}

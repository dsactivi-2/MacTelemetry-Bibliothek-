import OSLog

public struct TelemetryLogger: Sendable {
    private let lifecycle: Logger
    private let windowing: Logger
    private let navigation: Logger
    private let commands: Logger
    private let actions: Logger
    private let errors: Logger

    public init(subsystem: String) {
        lifecycle = Logger(subsystem: subsystem, category: "Lifecycle")
        windowing = Logger(subsystem: subsystem, category: "Windowing")
        navigation = Logger(subsystem: subsystem, category: "Navigation")
        commands = Logger(subsystem: subsystem, category: "Commands")
        actions = Logger(subsystem: subsystem, category: "Actions")
        errors = Logger(subsystem: subsystem, category: "Errors")
    }

    public func write(_ event: TelemetryEvent) {
        let message = "\(event.name): \(event.message)"
        switch event.category {
        case .lifecycle:
            log(event.level, message: message, logger: lifecycle)
        case .windowing:
            log(event.level, message: message, logger: windowing)
        case .navigation:
            log(event.level, message: message, logger: navigation)
        case .commands:
            log(event.level, message: message, logger: commands)
        case .actions:
            log(event.level, message: message, logger: actions)
        case .errors:
            log(event.level, message: message, logger: errors)
        }
    }

    private func log(_ level: TelemetryLevel, message: String, logger: Logger) {
        switch level {
        case .info:
            logger.info("\(message, privacy: .public)")
        case .warning:
            logger.warning("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        case .debug:
            logger.debug("\(message, privacy: .public)")
        }
    }
}

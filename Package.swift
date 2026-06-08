// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "MacTelemetry",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "MacTelemetryKit", targets: ["MacTelemetryKit"]),
        .library(name: "MacTelemetryKitUI", targets: ["MacTelemetryKitUI"]),
        .executable(name: "MacTelemetryDemo", targets: ["MacTelemetryDemo"]),
        .executable(name: "MacTelemetryHostDemo", targets: ["MacTelemetryHostDemo"])
    ],
    targets: [
        .target(name: "MacTelemetryKit"),
        .target(
            name: "MacTelemetryKitUI",
            dependencies: ["MacTelemetryKit"]
        ),
        .executableTarget(
            name: "MacTelemetryDemo",
            dependencies: ["MacTelemetryKit", "MacTelemetryKitUI"]
        ),
        .executableTarget(
            name: "MacTelemetryHostDemo",
            dependencies: ["MacTelemetryKit", "MacTelemetryKitUI"]
        ),
        .testTarget(
            name: "MacTelemetryKitTests",
            dependencies: ["MacTelemetryKit"]
        ),
        .testTarget(
            name: "MacTelemetryKitUITests",
            dependencies: ["MacTelemetryKit", "MacTelemetryKitUI"]
        )
    ]
)

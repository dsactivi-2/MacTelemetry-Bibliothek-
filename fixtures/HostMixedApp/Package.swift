// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "HostMixedApp",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "HostMixedApp", targets: ["HostMixedApp"])
    ],
    targets: [
        .executableTarget(name: "HostMixedApp")
    ]
)

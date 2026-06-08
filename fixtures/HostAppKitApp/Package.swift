// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "HostAppKitApp",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "HostAppKitApp", targets: ["HostAppKitApp"])
    ],
    targets: [
        .executableTarget(name: "HostAppKitApp")
    ]
)
